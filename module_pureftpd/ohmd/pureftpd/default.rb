#require 'ftools'

class Ohmd_pureftpd
  def self.install
    # Install Pure-FTPd
    system "apt-get install -y pure-ftpd" \
      or return false

    # Disable PAM authentication
    begin
      File.open("/etc/pure-ftpd/conf/PAMAuthentication", "w") { |f| f.puts "no" }
    rescue Exception
      return false
    end
    
    # Enable PureDB auth (virtual users)
    system "ln -fs ../conf/PureDB /etc/pure-ftpd/auth/75pdb" \
      or return false
      
    # Generate initial PureDB, or else server refuses to start
    File.open("/etc/pure-ftpd/pureftpd.passwd", "w") { |f| f.puts "" }
    system "pure-pw mkdb" \
      or return false
      
    # Restart FTP server
    system "service pure-ftpd restart" \
      or return false

    true
  end


  def self.remove
    # Remove Pure-FTPd
    system "apt-get remove -y pure-ftpd"
  end


  def self.exec
    # Check for orphan users and accounts first
    PureftpdUser.all.select { |u| u.user.nil? }.each do |orphan|
      orphan.destroy
    end
    PureftpdAccount.all.select { |a| a.domain.nil? }.each do |orphan|
      orphan.destroy
    end

    # passwd format: FTP_USERNAME:FTP_PASSWORD:REAL_UID:REAL_GID::FTP_ROOT/./::::::::::::
    # "/./" forces chrooting in the FTP_ROOT to limit user's access to the filesystem
    # http://download.pureftpd.org/pub/pure-ftpd/doc/README.Virtual-Users
    newpasswd = ""

    PureftpdUser.all.each do |u|
      # Extract UID and GID
      username = u.user.username
      userinfo = File.read("/etc/passwd").split("\n").select { |p| p.split(":")[0] == username }
      uid = userinfo[0].split(":")[2]
      gid = userinfo[0].split(":")[3]
      
      # Add a default account for user
      newpasswd << "#{username}:#{u.user.ohmd_password}:#{uid}:#{gid}::/home/#{username}/./::::::::::::\n"
      
      # Add one line per account
      u.pureftpd_accounts.each do |a|
        newpasswd << "#{a.full_username}:#{a.password}:#{uid}:#{gid}::/home/#{username}/#{a.root}/./::::::::::::\n"
      end
    end
    File.open("/etc/pure-ftpd/pureftpd.passwd", "w") { |f| f.puts newpasswd }
    
    # Add DNS entries
    PureftpdAccount.all.collect { |a| a.domain }.uniq.each do |dom|
      unless dom.dns_entries.select { |e| e.creator=="pureftpd" }.count > 0
        ["ftp"].each do |sub|
          DnsEntry.new(:line => "#{sub}\tIN\tA",
                       :add_ip => true,
                       :creator => "pureftpd",
                       :domain_id => dom.id).save
        end
      end
    end
    
    # Generate PureDB
    system "pure-pw mkdb"
  end
end

