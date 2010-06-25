# Ohm - Open Hosting Manager <http://ohmanager.sourceforge.net>
# Database installer - SQLite3
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

def setup_database cfg, dialog
  # Put details in rails and migrate
  dbyml = "production:
             adapter: sqlite3
             database: db/production.sqlite3
             pool: 5
             timeout: 5000"
  File.open("#{cfg["panel_path"]}/config/database.yml", "w") { |f| f.print dbyml }
end

