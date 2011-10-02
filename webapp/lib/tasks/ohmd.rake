# Ohm master daemon

# Logging
def timestamp
  Time.new.strftime("%Y-%m-%d %H:%M:%S")
end
def log(message)
  puts "#{timestamp} | #{message}"
end
def log_error(message)
  puts "#{timestamp} !!! #{message}"
end

namespace :ohmd do
  desc "Run the Ohm master daemon"
  task :run => :environment do
    DEFAULT_MODULES = [ Service.new(:controller=>'users',   :name=>'Users',    :daemon_installed=>true, :deleted=>false),
                        Service.new(:controller=>'apache2', :name=>'Apache',   :daemon_installed=>true, :deleted=>false),
                        Service.new(:controller=>'bind9',   :name=>'Bind DNS', :daemon_installed=>true, :deleted=>false) ]
    log "Ohmd start"

    # Delete removed modules
    Service.all(:conditions => {:deleted => true}).each do |service|
      log "Removing module #{service.name}"
      begin
        Rake::Task["ohmd:#{service.controller}:remove"] if service.daemon_installed
        service.destroy
      rescue => e
        log_error "Error removing module #{service.name}: #{e}"
      end
    end

    # Run modules
    Service.all(:conditions => {:daemon_installed => true, :deleted => false}).concat(DEFAULT_MODULES).each do |service|
      log "Running #{service.name}"
      begin
        Rake::Task["ohmd:#{service.controller}:run"]
      rescue => e
        log_error "Error running #{service.name}: #{e}"
      end
    end
  end

  desc "Install missing modules"
  task :install_modules => :environment do
    Service.all(:conditions => {:daemon_installed => false, :deleted => false}).each do |service|
      log "Installing #{service.name}"
      begin
        Rake::Task["ohmd:#{service.controller}:install"]
        service.update_attribute :daemon_installed, true
      rescue => e
        log_error "Error installing #{service.name}: #{e}"
      end
    end
  end
end