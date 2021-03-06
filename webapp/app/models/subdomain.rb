# Subdomain
class Subdomain < ActiveRecord::Base
  belongs_to :domain

  validates_presence_of :url, :domain
  validates_uniqueness_of :url, :scope => :domain_id
  validates_uniqueness_of :path, :scope => :domain_id

  validate :max_one_mainsub, :min_one_mainsub

  def max_one_mainsub
    if self.mainsub
      curmain = Subdomain.find(:first, :conditions=>{:domain_id => self.domain_id, :mainsub => true})
      if curmain && curmain != self
        curmain.mainsub = false
        curmain.save false
      end
    end
  end

  def min_one_mainsub
    if !self.mainsub and self.id and Subdomain.find(self.id).mainsub
      self.mainsub = true
    end
  end

  def before_save
    self.mainsub = false if self.mainsub.nil?
    self.path = self.url if self.path == ""
  end
end

