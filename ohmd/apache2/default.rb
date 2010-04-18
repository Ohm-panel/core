require 'ftools'

class Ohmd_apache2
  PREFIX = "ohm-"

  def self.exec
    # Make sure we can read the logs from the panel
    system "setfacl -R -m u:www-data:rx /var/log"
    system "setfacl -R -m d:u:www-data:rx /var/log"
    LogFile.all.each do |l|
      system "setfacl -m u:www-data:r #{l.path}"
    end

    # Stop here if we don't want a web server
    config = Configuration.all.first
    return unless config.enable_www
    
    changes = false

    # Add/edit all sites from panel
    Domain.all.each do |domain|
      next if domain.user.nil?
      site = "#{PREFIX}#{domain.domain}"
      user = domain.user.username
      path = "/home/#{user}/#{domain.domain}"
      file = "/etc/apache2/sites-available/#{site}"

      # Do a backup
      newfile = true
      if File.file? "/etc/apache2/sites-enabled/#{site}"
        File.copy(file, "/tmp/#{site}.bak")
        newfile = false
      end

      # Write new config
      File.open(file, "w") do |f|
        domain.subdomains.each do |sub|
          url = "#{sub.url}.#{domain.domain}"
          subpath = "#{path}/#{sub.path}"

          # Apache VHost
          vhost =  "<VirtualHost *:80>\n"
          vhost += "  ServerName #{url}\n"
          vhost += "  ServerAlias #{domain.domain}\n" if sub.mainsub
          vhost += "  DocumentRoot #{subpath}\n"
          vhost += "  <Directory #{subpath}>\n"
          vhost += "    Allow from all\n"
          vhost += "    Options FollowSymLinks -Indexes\n"
          vhost += "  </Directory>\n"
          vhost += "</VirtualHost>\n"
          f.print vhost

          # Create directory
          File.makedirs subpath

          # Add placeholder if empty
          if Dir.entries(subpath).count == 2
            system "cp apache2/placeholder/* #{subpath}/"
          end
        end
      end # Close file

      # Enable new site
      if newfile
        system "a2ensite #{site}"
        log "[apache2] Adding site #{domain.domain}"
      end

      # Check the configuration and revert if error
      unless system "apache2ctl configtest"
        if newfile
          logerror "[apache2] Error adding #{domain.domain}, removing"
          system "a2dissite #{site}"
        else
          logerror "[apache2] Error modifying #{domain.domain}, restoring"
          File.copy("/tmp/#{site}.bak", file)
        end
      end

      # Check permissions are correct
      system "chown -R #{user}:#{user} #{path}"
      system "setfacl -m u:www-data:rwx /home/#{user}"
      system "setfacl -R -m u:www-data:rwx #{path}"
      system "setfacl -m d:u:www-data:rwx #{path}"

      # Did we do anything?
      changes ||= newfile || File.read(file) != File.read("/tmp/#{site}.bak")
    end

    # Disable sites not in panel
    psites = Domain.all.collect { |d| "#{PREFIX}#{d.domain}" }
    Dir.new("/etc/apache2/sites-enabled").each do |asite|
      next unless asite.start_with? PREFIX
      unless psites.include? asite
        system "a2dissite #{asite}"
        changes = true
      end
    end

    # Reload Apache
    system "service apache2 reload" if changes

  end
end

