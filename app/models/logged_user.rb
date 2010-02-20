class LoggedUser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :session, :session_ts, :ip, :user
end

