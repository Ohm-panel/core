require 'digest/sha2'

class User < ActiveRecord::Base
  belongs_to :parent, :class_name => "User"
  has_many :users, :foreign_key => "parent_id"

  has_and_belongs_to_many :services

  has_many :domains

  validates_presence_of :username, :password # email would be useless here because of format
  validates_uniqueness_of :username
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i


  # Password change
  def self.digest_password password
    Digest::SHA512.hexdigest(password)
  end

  attr_accessor :new_password, :new_password_confirmation
  validate :passwords_must_match

  def passwords_must_match
    errors.add(:password, "incorrect") if new_password && User.digest_password(password) != User.find(id).password
    errors.add(:new_password, "and confirmation don't match") if new_password && new_password_confirmation != new_password
  end

  def before_save
    self.password = User.digest_password(new_password) if new_password
  end
end

