class Ohmd_bind9
  def self.exec
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
    ips = self.getips
    domains.each do |d|
      File.open("/etc/bind/db.#{d.domain}", "w") { |f|
        f.puts "$TTL\t7200"
        f.puts "@\tIN\tSOA\tns1.#{d.domain}.\twebmaster.#{d.domain}. ("
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
      }
    end

    system "service bind9 reload"
  end

  def self.getips
    `ifconfig | grep "inet addr"`.split("\n").
    collect { |line| line.split(":")[1].split(" ")[0] }.
    #select { |ip| !( ip.start_with?("127") || ip.start_with?("192.168") || ip.start_with?("10") || ip.start_with?("172.16") ) }
    select { |ip| !( ip.start_with?("127") || ip.start_with?("10") || ip.start_with?("172.16") ) }  ### KEEP 192.168 FOR TESTING ONLY !!!
  end

  def self.put_static f, ips
    ips.each do |ip|
      f.puts "@\tIN\tA\t#{ip}"
      f.puts "\tIN\tA\t#{ip}"
      f.puts "ns1\tIN\tA\t#{ip}"
      f.puts "@\tIN\tMX 5\t#{ip}"
    end
  end

  def self.put_record f, ips, url
    ips.each do |ip|
      f.puts "#{url}\tIN\tA\t#{ip}"
    end
  end
end

