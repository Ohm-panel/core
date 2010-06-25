# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Database installer - MySQL
#
# Copyright (C) 2009-2010 UMONS <http://www.umons.ac.be>
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

PWD_CHARS = [('a'..'z'),('A'..'Z'),(0..9)].inject([]) {|s,r| s+Array(r)}

def setup_database cfg, dialog
  # Create db and user
  dbpwd = dialog.passwordbox "Please enter the root password for mysql (root@localhost)"
  dbpwd = nil unless system("mysql -u root -p#{dbpwd} -e exit")
  while(dbpwd.nil?) do
    dbpwd = dialog.passwordbox "Please enter the root password for mysql (root@localhost)\nError. Please try again"
    dbpwd = nil unless system("mysql -u root -p#{dbpwd} -e exit")
  end
  dialog.progress(7)
  dbohmpwd = Array.new(16) { PWD_CHARS[ rand(PWD_CHARS.size) ] }
  mysql_cmds = "CREATE USER 'ohm'@'localhost' IDENTIFIED BY '#{dbohmpwd}'; "
  mysql_cmds += "CREATE DATABASE ohm; "
  mysql_cmds += "GRANT ALL PRIVILEGES ON ohm.* TO 'ohm'@'localhost'; "
  exec "mysql -u root -p#{dbpwd} -e \"#{mysql_cmds}\""

  # Put details in rails and migrate
  dbyml = "production:
             adapter: mysql
             host: localhost
             database: ohm
             username: ohm
             password: #{dbohmpwd}"
  File.open("#{cfg["panel_path"]}/config/database.yml", "w") { |f| f.print dbyml }
end

