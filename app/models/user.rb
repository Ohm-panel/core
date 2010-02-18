require 'digest/sha2'

class User < ActiveRecord::Base
  belongs_to :parent, :class_name => "User"
  has_many :users, :foreign_key => "parent_id"

  has_and_belongs_to_many :services

  has_many :domains

  def root?
    self.id == 1
  end

  def subdomains_count
    subdomains_count = 0
    self.domains.each do |dom|
      subdomains_count += dom.subdomains.count
    end
    subdomains_count
  end


  validates_presence_of :username
  validates_uniqueness_of :username
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validate :check_quota, :check_services

  def check_quota
    # Fill blank quotas
    self.max_space = -1 if !self.max_space or self.max_space < 0
    self.max_subdomains = -1 if !self.max_subdomains or self.max_subdomains < 0
    self.max_subusers = -1 if !self.max_subusers or self.max_subusers < 0

    # Root can do anything
    return if self.parent.root?

    # Compute quotas to take from parent
    oldme = self.id ? User.find(self.id) : nil
    space_to_take = self.max_space - (oldme ? oldme.max_space : 0)
    subdomains_to_take = self.max_subdomains - (oldme ? oldme.max_subdomains : 0)
    subusers_to_take = self.max_subusers - (oldme ? oldme.max_subusers : 0)

    # See if we can take that much
    errors.add(:max_space, "is more than you can give") if self.parent.max_space != -1 \
      and space_to_take > self.parent.max_space - self.parent.used_space
    errors.add(:max_subdomains, "is more than you can give") if self.parent.max_subdomains != -1 \
      and subdomains_to_take > self.parent.max_subdomains - self.parent.subdomains_count
    errors.add(:max_subusers, "is more than you can give") if self.parent.max_subusers != -1 \
      and subusers_to_take > self.parent.max_subusers - self.parent.users.count

    # Take it
    self.parent.max_space -= space_to_take
    self.parent.max_subdomains -= subdomains_to_take
    self.parent.max_subusers -= subusers_to_take
    self.parent.save false
  end

  def check_services
    illegal_services = self.services - parent.services
    illegal_services.each do |is|
      errors.add("Can't add service " +is.name+", you don't have it!")
    end
  end

  # Password change
  def self.digest_password password
    Digest::SHA512.hexdigest(password)
  end

  attr_accessor :new_password, :new_password_confirmation

  validate :passwords_must_match
  def passwords_must_match
    if self.id and new_password and new_password != ''
      # We're in password change
      errors.add(:password, "incorrect") if User.digest_password(password) != User.find(id).password
      errors.add(:password, "and confirmation don't match") if new_password_confirmation != new_password
    elsif not self.id and new_password
      # We're in new user
      errors.add(:password, "and confirmation don't match") if new_password_confirmation != new_password
    end
  end

  def before_save
    if new_password and new_password != ''
      self.password = User.digest_password(new_password)
    else
      self.password = User.find(id).password
    end
  end
end

