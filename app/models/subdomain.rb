class Subdomain < ActiveRecord::Base
  belongs_to :domain

  validate :max_one_mainsub

  def max_one_mainsub
    if self.mainsub
      curmain = Subdomain.find(:first, :conditions=>{:domain_id => self.domain_id, :mainsub => true})
      if curmain && curmain != self
        curmain.mainsub = false
        curmain.save
      end
    end
  end
end

