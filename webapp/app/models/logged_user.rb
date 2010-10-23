### Ohm - Open Hosting Manager <http://joelcogen.com/projects/ohm/> ###
#
# User currently logged in
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
# Copyright (C) 2010 Joel Cogen <http://joelcogen.com>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

class LoggedUser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :session, :session_ts, :user_id
  validates_format_of :ip, :with => /\A((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/
  validate :ts_now_or_past

  def ts_now_or_past
    errors.add(:session_ts, "is in the future") if self.session_ts > Time.now unless self.session_ts.nil?
  end
end

