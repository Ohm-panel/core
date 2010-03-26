class Ohmd_apache2
  PREFIX = "ohm-"

  def self.exec
    # Add/edit all sites from panel
    Domain.all.each do |domain|
      next if domain.user.nil?
      site = "#{PREFIX}#{domain.domain}"
      File.open("/etc/apache2/sites-available/#{site}", "w") do |f|
        domain.subdomains.each do |sub|
          url = "#{sub.url}.#{domain.domain}"
          path = "/home/#{domain.user.username}/#{domain.domain}/#{sub.path}"
          vhost =  "<VirtualHost *:80>\n"
          vhost += "  ServerName #{url}\n"
          vhost += "  ServerAlias #{domain.domain}\n" if sub.mainsub
          vhost += "  DocumentRoot #{path}\n"
          vhost += "  <Directory #{path}>\n"
          vhost += "    Allow from all\n"
          vhost += "    Options FollowSymLinks -Indexes\n"
          vhost += "  </Directory>\n"
          vhost += "</VirtualHost>\n"
          f.print vhost
        end
      end # Close file

      system "a2ensite #{site}"
    end

    # Disable sites not in panel
    psites = Domain.all.collect { |d| "#{PREFIX}#{d.domain}" }
    Dir.new("/etc/apache2/sites-enabled").each do |asite|
      next unless asite.start_with? PREFIX
      unless psites.include? asite
        system "a2dissite #{asite}"
      end
    end

    # Reload Apache
    system "service apache2 force-reload"

  end
end

