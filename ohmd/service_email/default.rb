class Ohmd_service_email
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

