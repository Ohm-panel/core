PWD_CHARS = [('a'..'z'),('A'..'Z'),(0..9)].inject([]) {|s,r| s+Array(r)}

def setup_database cfg, dialog
  # Create db and user
  dbpwd = nil
  while(dbpwd.nil?) do
    dbpwd = dialog.passwordbox "Please enter the root password for mysql (root@localhost)"
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
  exec "cd #{cfg["panel_path"]}; rake db:migrate RAILS_ENV=production"
end

