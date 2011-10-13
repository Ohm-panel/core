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
    DEFAULT_MODULES = [ Service.new(:controller=>'users',   :name=>'Users'),
                        Service.new(:controller=>'apache2', :name=>'Apache'),
                        Service.new(:controller=>'bind9',   :name=>'Bind DNS') ]
    log "Ohmd start"

    # Run modules
    Service.all.concat(DEFAULT_MODULES).each do |service|
      log "Running #{service.name}"
      begin
        Rake::Task["ohmd:#{service.controller}:run"]
      rescue => e
        log_error "Error running #{service.name}: #{e}"
      end
    end
  end
end