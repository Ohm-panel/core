module OhmdHelper
  def ohmd_action_line(action, options, target)
    "#ohm# #{action} #{options}: #{target}"
  end

  def ohmd_file_action(filename, options, data)
    ohmd_action_line("file", options, filename) + "\n" + data
  end

  def ohmd_exec_action(command, revert, options, target)
    action = ohmd_action_line("exec", options, target) + "\n" + command
    if revert
      action += "\n###\n" + revert
    end
    action
  end

  def ohmd_url_action(url)
    ohmd_action_line("url", nil, url)
  end
end

