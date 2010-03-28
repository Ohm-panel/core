require 'digest/sha2'

class ServiceEmailMailbox < ActiveRecord::Base
  belongs_to :domain

  def full_address
    self.address + '@' + self.domain.domain
  end

  validates_presence_of :domain_id, :password
#  validates_format_of :address, :with => /\A([^@\s]+)\Z/i
  validates_format_of :address, :with => /\A([a-zA-Z0-9\._-]+)\Z/i
  validates_uniqueness_of :address, :scope => :domain_id
  validate :passwords_match

  attr_accessor :password_confirmation

  def passwords_match
    errors.add(:password_confirmation, "doesn't match password") if password_confirmation and password_confirmation != password
  end

  def before_save
    self.password = User.shadow_password(password).split("\\$").join("$") if password_confirmation
    self.size = self.domain.user.max_space if self.size.nil?
  end
end

