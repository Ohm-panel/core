def setup_database cfg, dialog
  # Put details in rails and migrate
  dbyml = "production:
             adapter: sqlite3
             database: db/production.sqlite3
             pool: 5
             timeout: 5000"
  File.open("#{cfg["panel_path"]}/config/database.yml", "w") { |f| f.print dbyml }
end

