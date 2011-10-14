set :output, '/var/log/ohmd.log'

every 5.minutes do
  rake "ohmd:run"
end