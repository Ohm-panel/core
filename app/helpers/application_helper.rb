# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def current_controller? *names
    names.each do |name|
      return true if controller.controller_name.rindex(name) == 0
    end
    false
  end

  def print_quota usage, limit, unit
    qs = (limit!=-1 && usage>limit) ? '<span class="overquota">' : ''
    qs += usage>0 ? usage.to_s : '0'
    qs += (limit!=-1 && usage>limit) ? '</span>' : ''
    qs += ' / ' + (limit==-1 ? 'Unlimited' : limit.to_s )
    qs += ' ' + unit unless unit == ''
    qs
  end
end

