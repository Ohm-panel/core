class Domain < ActiveRecord::Base
  belongs_to :user

  has_many :subdomains

  has_and_belongs_to_many :services

  validates_uniqueness_of :domain
end

