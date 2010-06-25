# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Application helper
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

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

