class LoggedUser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :session, :session_ts, :ip, :user_id
  validates_format_of :ip, :with => /((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/
end

