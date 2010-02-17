class Subdomain < ActiveRecord::Base
  belongs_to :domain

  validate :max_one_mainsub, :path_not_empty

  def max_one_mainsub
    if self.mainsub
      curmain = Subdomain.find(:first, :conditions=>{:domain_id => self.domain_id, :mainsub => true})
      if curmain && curmain != self
        curmain.mainsub = false
        curmain.save
      end
    end
  end

  def path_not_empty
    self.path = self.url if self.path == ""
  end
end

