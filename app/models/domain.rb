class Domain < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :domain
end

