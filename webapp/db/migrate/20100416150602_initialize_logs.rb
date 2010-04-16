class InitializeLogs < ActiveRecord::Migration
  def self.up
    LogFile.create :name => "Ohm web panel", :path => "log/production.log"
    LogFile.create :name => "Apache error", :path => "/var/log/apache2/error.log"
    LogFile.create :name => "Apache access", :path => "/var/log/apache2/access.log"
    LogFile.create :name => "Syslog", :path => "/var/log/syslog"
  end

  def self.down
  end
end
