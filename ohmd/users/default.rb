class Ohmd_users
  QUOTA_HARD_MULT = 1.2

  def self.exec
    config = Configuration.all.first
    shell = config.enable_ssh ? "/bin/bash" : "/bin/false"
  
    users = User.all
    users_on_system = File.read("/etc/passwd").split("\n").
                      select { |u| u.split(":")[2].to_i >= 1000 && u.split(":")[0] != "nobody" }.
                      collect { |u| u.split(":")[0] }

    # Find users to add
    users_to_add = users.select { |u| !u.deleted? && !users_on_system.include?(u.username) }
    users_to_add.each do |u|
      log "[users] Creating user: #{u.username}"
      system "useradd --create-home --user-group --shell #{shell} --comment \"#{u.full_name},,,\" --password \"#{u.ohmd_password}\" #{u.username}" \
        or logerror "[users] Error adding user: #{u.username}"
      (system "setquota #{u.username} #{u.space_for_me*1024} #{(u.space_for_me*1024*QUOTA_HARD_MULT).to_i} 0 0 -a" \
        or logerror "[users] Error setting quota for #{u.username}") unless u.max_space == -1
      # Make sure nobody has access to the home folder
      system "chmod -R o-rwx /home/#{u.username}/"
    end

    # Find users to del
    users_to_del = users.select { |u| u.deleted? }
    users_to_del.each do |u|
      next unless users_on_system.include? u.username

      log "[users] Removing user: #{u.username}"
      delok = system "userdel #{u.username}"
      if delok
        u.destroy
        system "mv /home/#{u.username} /home/#{u.username}.bak.#{Time.new.to_i.to_s}"
      else
        logerror "[users] Error removing user: #{u.username}"
      end
    end

    # Modify all other users, just in case
    users_to_mod = users.select { |u| !users_to_add.include?(u) && !users_to_del.include?(u) }
    users_to_mod.each do |u|
      log "[users] Modify user: #{u.username}"
      system "usermod --shell #{shell} --comment \"#{u.full_name},,,\" --password \"#{u.ohmd_password}\" #{u.username}" \
        or logerror "[users] Error modifying user: #{u.username}"
      (system "setquota #{u.username} #{u.space_for_me*1024} #{(u.space_for_me*1024*QUOTA_HARD_MULT).to_i} 0 0 -a" \
        or logerror "[users] Error setting quota for #{u.username}") unless u.max_space == -1
      # Make sure nobody has access to the home folder
      system "chmod -R o-rwx /home/#{u.username}/"
    end

    # Root can always use SSH
    root = users.select { |u| u.root? }.first
    system "usermod --shell /bin/bash #{root.username}" \
        or logerror "[users] Error modifying user: #{root.username}"

    # Upload disk usage for all users
    users.each do |u|
      next if u.deleted?
      u.update_attribute(:used_space, (`du -s /home/#{u.username}/`.split("\t")[0].to_i / 1024).to_i) \
        or logerror "[users] Error updating usage for #{u.username}"
    end
  end
end

