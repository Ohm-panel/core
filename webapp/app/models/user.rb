require 'digest/sha2'

class User < ActiveRecord::Base
  belongs_to :parent, :class_name => "User"
  has_many :users, :foreign_key => "parent_id"

  has_and_belongs_to_many :services

  has_many :domains


  # Statuses in Ohmd
  OHMD_OK     = 0
  OHMD_TO_ADD = 1
  OHMD_TO_MOD = 2
  OHMD_TO_DEL = 3


  def root?
    self.id and self.id == 1
  end


  def used_subdomains_total
    # What user uses
    used = 0
    self.domains.each do |dom|
      used += dom.subdomains.count
    end
    # What's given to sub-users
    self.users.each do |u|
      used += u.max_subdomains
    end
    used
  end

  def used_space_total
    # What user uses
    used = self.used_space
    # What's given to sub-users
    self.users.each do |u|
      used += u.max_space
    end
    used
  end

  def used_subusers_total
    # What user uses
    used = self.users.count
    # What's given to sub-users
    self.users.each do |u|
      used += u.max_subusers
    end
    used
  end


  def free_space
    return -1 if self.max_space == -1
    self.max_space - self.used_space_total
  end

  def free_subdomains
    return -1 if self.max_subdomains == -1
    self.max_subdomains - self.used_subdomains_total
  end

  def free_subusers
    return -1 if self.max_subusers == -1
    self.max_subusers - self.used_subusers_total
  end


  def self.quota_ok parent_free, to_take
    if parent_free == -1
      true
    elsif to_take == -1
      false
    elsif to_take <= parent_free
      true
    else
      false
    end
  end


  validates_presence_of :parent, :unless => Proc.new { |user| user.root? } # Root has no parent
  validates_presence_of :username, :password
  validates_uniqueness_of :username
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validate :check_quota, :check_services

  def check_quota
    # Fill blank quotas
    self.used_space = 0 if !self.used_space
    self.max_space = -1 if !self.max_space or self.max_space < 0
    self.max_subdomains = -1 if !self.max_subdomains or self.max_subdomains < 0
    self.max_subusers = -1 if !self.max_subusers or self.max_subusers < 0

    # Root can do anything
    return if self.root?
    return if self.parent.root?

    # Compute quotas to take from parent
    oldme = self.id ? User.find(self.id) : nil
    space_to_take = self.max_space - ((oldme and self.max_space!=-1) ? oldme.max_space : 0)
    subdomains_to_take = self.max_subdomains - ((oldme and self.max_subdomains!=-1) ? oldme.max_subdomains : 0)
    subusers_to_take = self.max_subusers - ((oldme and self.max_subusers!=-1) ? oldme.max_subusers : 0)

    # See if we can take that much
    errors.add(:max_space, "is more than you can give") unless User.quota_ok self.parent.free_space, space_to_take
    errors.add(:max_subdomains, "is more than you can give") unless User.quota_ok self.parent.free_subdomains, subdomains_to_take
    errors.add(:max_subusers, "is more than you can give") unless User.quota_ok self.parent.free_subusers, subusers_to_take
  end

  def check_services
    # Skip check on root
    return if self.root?

    illegal_services = self.services - parent.services
    illegal_services.each do |is|
      errors.add("Can't add service " +is.name+", you don't have it!")
    end
  end

  # Crypt password in shadow format
  SALT_CHARS = [('a'..'z'),('A'..'Z'),(0..9),'.','/'].inject([]) {|s,r| s+Array(r)}
  def self.shadow_password password
    salt = Array.new(8) { SALT_CHARS[ rand(SALT_CHARS.size) ] }
    password.crypt("$6$#{salt}").split("$").join("\\$")
  end

  # Password change
  def self.digest_password password
    Digest::SHA512.hexdigest(password)
  end

  attr_accessor :old_password, :password_confirmation

  validate :passwords_must_match
  def passwords_must_match
    errors.add(:old_password, "incorrect") if password_confirmation and old_password and User.digest_password(old_password) != User.find(id).password
    errors.add(:password_confirmation, "and confirmation don't match") if password_confirmation and password_confirmation != password
  end

  def before_save
    # If new user, mark as to be added in Ohmd
    self.ohmd_status = OHMD_TO_ADD if self.ohmd_status.nil? || self.ohmd_status == ""

    # If password was changed, update hashes
    if password_confirmation
      self.ohmd_password = User.shadow_password(password)
      self.ohmd_status = OHMD_TO_MOD unless self.ohmd_status == OHMD_TO_ADD
      self.password = User.digest_password(password)
    end
  end
end
