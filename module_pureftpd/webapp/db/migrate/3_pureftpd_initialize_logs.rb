class PureftpdInitializeLogs < ActiveRecord::Migration
  def self.up
    LogFile.create :name => "FTP transfers", :path => "/var/log/pure-ftpd/transfer.log"
  end

  def self.down
  end
end
