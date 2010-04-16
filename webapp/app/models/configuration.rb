class Configuration < ActiveRecord::Base
    validates_format_of :ip_address, :with => /\A((25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/
end
