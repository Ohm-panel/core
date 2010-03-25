class Ohmd_users
  QUOTA_HARD_MULT = 1.2

  def self.exec
    users = User.all
    users_on_system = File.read("/etc/passwd").split("\n").
                      select { |u| u.split(":")[2].to_i >= 1000 && u.split(":")[0] != "nobody" }.
                      collect { |u| u.split(":")[0] }

    # Find users to add
    users_to_add = users.select { |u| ! users_on_system.include? u.username }
    users_to_add.each do |u|
      next if u.root?
      log "[users] Creating user: #{u.username}"
      system "useradd --create-home --user-group --shell /bin/bash --comment \"#{u.full_name},,,\" --password \"#{u.ohmd_password}\" #{u.username}" \
        or raise RuntimeError.new "Error adding user: #{u.username}"
      system "setquota #{u.username} #{u.space_for_me*1024} #{(u.space_for_me*1024*QUOTA_HARD_MULT).to_i} 0 0 -a" unless u.max_space == -1 \
        or raise RuntimeError.new "Error setting quota for #{u.username}"
    end

    # Find users to del
    users_to_del = users_on_system - users.collect { |u| u.username }
    users_to_del.each do |u|
      log "[users] Removing user: #{u}"
      system "userdel #{u}" \
        or raise RuntimeError.new "Error removing user: #{u}"
    end

    # Modify all other users, just in case
    users_to_mod = users.select { |u| !users_to_add.include?(u) && !users_to_del.include?(u.username) }
    users_to_mod.each do |u|
      next if u.root?
      log "[users] Modify user: #{u.username}"
      system "usermod --comment \"#{u.full_name},,,\" --password \"#{u.ohmd_password}\" #{u.username}" \
        or raise RuntimeError.new "Error modifying user: #{u.username}"
      system "setquota #{u.username} #{u.space_for_me*1024} #{(u.space_for_me*1024*QUOTA_HARD_MULT).to_i} 0 0 -a" unless u.max_space == -1 \
        or raise RuntimeError.new "Error setting quota for #{u.username}"
    end

  end
end

