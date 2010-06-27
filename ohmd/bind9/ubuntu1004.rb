# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# BIND daemon for Ubuntu 10.04
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
# Copyright (C) 2010 Joel Cogen <joel@joelcogen.com>
#
# This file is part of Ohm.
#
# Ohm is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ohm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ohm. If not, see <http://www.gnu.org/licenses/>.

class Ohmd_bind9
  def self.exec
    config = Configuration.all.first
    return unless config.enable_dns

    domains = Domain.all

    # Create /etc/bind/named.conf.local
    named_conf_local = ""
    domains.each do |d|
      named_conf_local << "zone \"#{d.domain}\" {\n"
      named_conf_local << "  type master;\n"
      named_conf_local << "  file \"/etc/bind/db.#{d.domain}\";\n"
      named_conf_local << "};\n"
    end
    File.open("/etc/bind/named.conf.local", "w") { |f| f.print named_conf_local }

    # Create databases
    serial = Time.new.to_i
    ips = self.getips config
    domains.each do |d|
      File.open("/etc/bind/db.#{d.domain}", "w") { |f|
        f.puts "$TTL\t7200"
        f.puts "@\tIN\tSOA\tns1.#{d.domain}.\t#{d.user.email.split("@").join(".")}. ("
        f.puts "\t\t\t#{serial}\t; Serial"
        f.puts "\t\t\t2H\t; Refresh"
        f.puts "\t\t\t60M\t; Retry"
        f.puts "\t\t\t1W\t; Expire"
        f.puts "\t\t\t24H )\t; Negative Cache TTL"
        f.puts "@\tIN\tTXT\t\"Ohm | Open Hosting Manager\""
        f.puts "@\tIN\tNS\tns1.#{d.domain}."
        put_static f, ips
        d.subdomains.each do |sub|
          put_record f, ips, sub.url
        end
        d.dns_entries.each do |entry|
          put_entry f, ips, entry
        end
      }
    end

    system "service bind9 reload"
  end

  def self.getips config
    [config.ip_address]
  end

  def self.put_static f, ips
    ips.each do |ip|
      f.puts "@\tIN\tA\t#{ip}"
      f.puts "\tIN\tA\t#{ip}"
      f.puts "ns1\tIN\tA\t#{ip}"
    end
  end

  def self.put_record f, ips, url
    ips.each do |ip|
      f.puts "#{url}\tIN\tA\t#{ip}"
    end
  end

  def self.put_entry f, ips, e
    if e.add_ip
      ips.each do |ip|
        f.puts "#{e.line}\t#{ip}"
      end
    else
      f.puts e.line
    end
  end

end

