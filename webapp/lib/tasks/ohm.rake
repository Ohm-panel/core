namespace :ohm do
  desc "Setup Ohm after install"
  task :setup => :environment do
    LogFile.create :name => "Ohm web panel", :path => "/var/www/ohm/log/production.log"
    LogFile.create :name => "Ohm daemon", :path => "/var/log/ohmd.log"
    LogFile.create :name => "Apache error", :path => "/var/log/apache2/error.log"
    LogFile.create :name => "Apache access", :path => "/var/log/apache2/access.log"
    LogFile.create :name => "Syslog", :path => "/var/log/syslog"

    Configuration.new(:os => ENV['OHM_OS']).save(false)
  end
end