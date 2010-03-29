class Service < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :domains

  validates_presence_of :name, :controller
  validates_uniqueness_of :name, :controller

  def active?
    self.daemon_installed && !self.deleted
  end

  def before_save
    self.by_domain = false if self.by_domain.nil?
    self.tech_name = self.name if self.tech_name.nil? or self.tech_name==""
  end
end

