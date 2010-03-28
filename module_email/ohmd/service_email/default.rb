require 'ftools'

class Ohmd_service_email
  def self.install
    system "apt-get install -y --force-yes dovecot-postfix" or return false
    system "useradd dovelda" or return false
    begin
      File.copy "service_email/dovecot-postfix.conf" "/etc/dovecot/dovecot-postfix.conf"
      File.open("/etc/sudoers", "a") { |f|
        f.puts "Defaults:dovelda !syslog"
        f.puts "dovelda ALL=NOPASSWD:/usr/lib/dovecot/deliver"
      }
      File.open("/etc/postfix/master.cf", "a") { |f|
        f.puts "dovecot   unix  -       n       n       -       -       pipe"
        f.puts "  flags=DRhu user=dovelda:mail argv=/usr/bin/sudo /usr/lib/dovecot/deliver -f ${sender} -d ${recipient}"
      }
      File.open("/etc/postfix/main.cf", "a") { |f|
        f.puts "dovecot_destination_recipient_limit = 1"
        #f.puts "virtual_mailbox_domains = localhost.localdomain"
        f.puts "virtual_transport = dovecot"
      }
    rescue Exception
      return false
    end
    true
  end

  def self.exec
    # Dovecot auth config
    mboxes = ServiceEmailMailbox.all.select { |m| !m.forward_only }
    newpasswd = ""
    mboxes.each do |m|
      username = m.domain.user.username
      userinfo = File.read("/etc/passwd").split("\n").select { |p| p.split(":")[0] == username }
      uid = userinfo[0].split(":")[2]
      gid = userinfo[0].split(":")[3]

      newpasswd << "#{m.full_address}:#{m.password}:#{uid}:#{gid}::/home/#{username}\n"
    end
    File.open("/etc/ohm_email.passwd", "w") { |f| f.print newpasswd }


    # Add domains to postfix
    maincf = ""
    dest = nil
    File.read("/etc/postfix/main.cf").each_line do |line|
      if line.match(/\A\s*mydestination/)
        dest = line.split("=")[1].split(",").collect { |d| d.strip }
      else
        maincf << line
      end
    end
    dest.concat ServiceEmailMailbox.all.collect { |m| m.domain.domain }
    newline = "mydestination = " + dest.uniq.join(", ")
    File.open("/etc/postfix/main.cf", "w") { |f|
      f.puts maincf
      f.puts newline
    }
  end
end

