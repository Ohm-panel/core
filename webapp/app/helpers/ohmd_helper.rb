module OhmdHelper
  def ohmd_action_line(action, options, target, report_value = nil)
    "#ohm# #{action} #{options}: #{target} #{report_value}"
  end

  def ohmd_file_action(filename, options, data, report_value = nil)
    ohmd_action_line("file", options, filename, report_value) + "\n" + data
  end

  def ohmd_exec_action(command, revert, options, target, report_value = nil)
    action = ohmd_action_line("exec", options, target, report_value) + "\n" + command
    if revert
      action += "\n###\n" + revert
    end
    action
  end

  def ohmd_url_action(url)
    ohmd_action_line("url", nil, url)
  end
end

