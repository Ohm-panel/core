class Domain < ActiveRecord::Base
  belongs_to :user

  has_many :subdomains, :dependent => :destroy

  has_and_belongs_to_many :services

  validates_presence_of :domain, :user
  validates_uniqueness_of :domain
end

