require 'ftools'

class Ohmd_service_email
  DES_CHARS = [('a'..'z'),('A'..'Z'),(0..9),'-','_'].inject([]) {|s,r| s+Array(r)}

  def self.install
    # Install Dovecot/Postfix, ClamAV, SpamAssassin, Amavis
    system "apt-get install -y dovecot-postfix amavisd-new spamassassin clamav-daemon pyzor razor \
                               arj cabextract cpio lha nomarch pax rar unrar unrar-free unzip zip lzop zoo ripole" \
      or return false

    # Add user that will have sudo on deliver (Dovecot's LDA)
    system "useradd dovelda"

    # Copy/edit configuration files
    begin
      # Dovecot
      File.copy "service_email/dovecot-postfix.conf", "/etc/dovecot/dovecot-postfix.conf"
      # Postfix
      File.copy "service_email/master.cf", "/etc/postfix/master.cf"
      File.open("/etc/sudoers", "a") { |f|
        f.puts "Defaults:dovelda !syslog"
        f.puts "dovelda ALL=NOPASSWD:/usr/lib/dovecot/deliver"
      }
      File.open("/etc/postfix/main.cf", "a") { |f|
        f.puts "smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unknown_sender_domain, reject_unknown_recipient_domain, reject_unauth_pipelining, reject_unauth_destination"
        f.puts "smtpd_tls_auth_only = no"
        f.puts "dovecot_destination_recipient_limit = 1"
        f.puts "virtual_transport = dovecot"
        f.puts "virtual_mailbox_maps = hash:/etc/postfix/vmailbox"
        f.puts "virtual_alias_maps = hash:/etc/postfix/virtual"
        f.puts "content_filter = smtp-amavis:[127.0.0.1]:10024"
      }
      # Create empty mailboxes/aliases/password files to prevent crashes
      File.open("/etc/ohm_email.passwd", "w") { |f| f.puts "" }
      File.open("/etc/postfix/virtual", "w") { |f| f.puts "" }
      system "postmap /etc/postfix/virtual"
      File.open("/etc/postfix/vmailbox", "w") { |f| f.puts "" }
      system "postmap /etc/postfix/vmailbox"
      # SpamAssassin
      File.copy "service_email/spamassassin", "/etc/default/spamassassin"
      # Amavis
      File.copy "service_email/amavis-15-content_filter_mode", "/etc/amavis/conf.d/15-content_filter_mode"
      # ClamAV
      newclamconf = File.read("/etc/clamav/clamd.conf").split("User clamav").join("User amavis")
      File.open("/etc/clamav/clamd.conf", "w") { |f| f.puts newclamconf }
    rescue Exception
      return false
    end

    # (Re)start services
    system "service postfix restart" or return false
    system "service dovecot restart" or return false
    system "service spamassassin start" or return false
    system "service clamav-daemon start" or return false
    system "service amavis restart" or return false

    # Install roundcube
    system "apt-get -y install php-pear php5-mcrypt php-mdb2 php-mdb2-driver-sqlite php-mail-mime php-net-smtp sqlite php5-sqlite php5-gd" or return false
    system "tar -xf service_email/roundcube.tar.bz2 -C /var/www" or return false
    des_key = Array.new(24) { DES_CHARS[ rand(DES_CHARS.size) ] }
    begin
      maininc = File.read("/var/www/roundcube/config/main.inc.php").split("?>")[0]
      File.open("/var/www/roundcube/config/main.inc.php", "w") { |f|
        f.puts maininc
        f.puts "$rcmail_config['des_key'] = '#{des_key}';"
        f.print "?>"
      }
    rescue Exception
      return false
    end
    system "chown -R www-data:www-data /var/www/roundcube" or return false
    system "chmod -R o-rwx /var/www/roundcube" or return false

    # All ok, remove install files
    File.delete "service_email/roundcube.tar.bz2"
    File.delete "service_email/dovecot-postfix.conf"
    File.delete "service_email/master.cf"
    File.delete "service_email/spamassassin"
    File.delete "service_email/amavis-15-content_filter_mode"

    true
  end


  def self.remove
    # Remove DNS entries
    DnsEntry.all.select { |e| e.creator=="service_email" }.each do |d|
      d.destroy
    end
  end


  def self.exec
    # Check for orphan users first
    ServiceEmailUser.all.select { |u| u.user.nil? }.each do |orphan|
      orphan.destroy
    end
    ServiceEmailMailbox.all.select { |m| m.domain.nil? }.each do |orphan|
      orphan.destroy
    end

    # Dovecot auth config
    mboxes = ServiceEmailMailbox.all.select { |m| !m.forward_only }
    newpasswd = ""
    mboxes.each do |m|
      username = m.domain.user.username
      userinfo = File.read("/etc/passwd").split("\n").select { |p| p.split(":")[0] == username }
      uid = userinfo[0].split(":")[2]
      gid = userinfo[0].split(":")[3]
      maildir = "/home/#{username}/mail/#{m.domain.domain}/#{m.address}"
      File.makedirs maildir
      system "chown -R #{username}:#{username} /home/#{username}/mail/"
      system "setfacl -m u:postfix:rwx /home/#{username}"
      system "setfacl -m u:dovecot:rwx /home/#{username}"
      system "setfacl -R -m u:postfix:rwx /home/#{username}/mail/"
      system "setfacl -R -m u:dovecot:rwx /home/#{username}/mail/"
      system "setfacl -m d:u:postfix:rwx /home/#{username}/mail/"
      system "setfacl -m d:u:dovecot:rwx /home/#{username}/mail/"

      newpasswd << "#{m.full_address}:#{m.password}:#{uid}:#{gid}::#{maildir}\n"
    end
    File.open("/etc/ohm_email.passwd", "w") { |f| f.print newpasswd }


    # Add domains to postfix
    maincf = ""
    File.read("/etc/postfix/main.cf").each_line do |line|
      unless line.match(/\A\s*virtual_mailbox_domains/)
        maincf << line
      end
    end
    doms = "virtual_mailbox_domains = " + ServiceEmailMailbox.all.collect { |m| m.domain.domain }.uniq.join(", ")
    File.open("/etc/postfix/main.cf", "w") { |f|
      f.puts maincf
      f.puts doms
    }

    # Add mailboxes to postfix
    File.open("/etc/postfix/vmailbox", "w") { |f|
      mboxes.each do |m|
        f.puts "#{m.full_address} ohm"
      end
    }
    system "postmap /etc/postfix/vmailbox"

    # Add aliases
    aliases = ServiceEmailMailbox.all.select { |m| m.forward.length > 0 }
    File.open("/etc/postfix/virtual", "w") { |f|
      aliases.each do |a|
        forward = a.forward.split(/\r?\n/).join(", ").squeeze(" ")
        f.puts "#{a.full_address} #{forward}"
      end
    }
    system "postmap /etc/postfix/virtual"

    # Add webmail.*
    prev_file = (File.read("/etc/apache2/sites-available/ohm_webmail") or "")
    File.open("/etc/apache2/sites-available/ohm_webmail", "w") { |f|
      Domain.all.each do |d|
        f.puts "<VirtualHost *:80>"
        f.puts "  ServerName webmail.#{d.domain}"
        f.puts "  DocumentRoot /var/www/roundcube"
        f.puts "  <Directory /var/www/roundcube>"
        f.puts "    Allow from all"
        f.puts "    Options FollowSymLinks -Indexes"
        f.puts "  </Directory>"
        f.puts "</VirtualHost>"
      end
    }
    if prev_file != File.read("/etc/apache2/sites-available/ohm_webmail")
      system "a2ensite ohm_webmail"
      system "service apache2 reload"
    end

  end

end

