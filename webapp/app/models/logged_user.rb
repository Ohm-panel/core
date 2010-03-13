class LoggedUser < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :session, :session_ts, :user_id
  validates_format_of :ip, :with => /\A((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/
  validate :ts_now_or_past

  def ts_now_or_past
    errors.add(:session_ts, "is in the future") if self.session_ts > Time.now unless self.session_ts.nil?
  end
end

