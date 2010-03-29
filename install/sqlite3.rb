def setup_database cfg, dialog
  # Put details in rails and migrate
  dbyml = "production:
             adapter: sqlite3
             database: db/production.sqlite3
             pool: 5
             timeout: 5000"
  File.open("#{cfg["panel_path"]}/config/database.yml", "w") { |f| f.print dbyml }
  exec "cd #{cfg["panel_path"]}; rake db:migrate RAILS_ENV=production"
end

