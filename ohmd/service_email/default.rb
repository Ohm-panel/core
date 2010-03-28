class Ohmd_service_email
  def self.exec
    # Dovecot config
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

  end
end

