require 'digest/sha2'

class ServiceEmailMailbox < ActiveRecord::Base
  belongs_to :domain

  def full_address
    self.address + '@' + self.domain.domain
  end

  def self.digest_password password
    Digest::SHA512.hexdigest(password)
  end

  validates_presence_of :domain_id, :password
  validates_format_of :address, :with => /\A([^@\s]+)/i
  validates_uniqueness_of :address, :scope => :domain_id
  validate :passwords_match

  attr_accessor :password_confirmation

  def passwords_match
    errors.add(:password_confirmation, "doesn't match password") if password_confirmation and password_confirmation != password
  end

  def before_save
    self.password = ServiceEmailMailbox.digest_password(password) if password_confirmation
    self.size = self.domain.user.max_space if self.size.nil?
  end
end

