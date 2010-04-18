class EmailInitializeLogs < ActiveRecord::Migration
  def self.up
    LogFile.create :name => "E-mail error", :path => "/var/log/mail.err"
    LogFile.create :name => "E-mail warning", :path => "/var/log/mail.warn"
    LogFile.create :name => "E-mail info", :path => "/var/log/mail.info"
    LogFile.create :name => "E-mail log", :path => "/var/log/mail.log"
  end

  def self.down
  end
end
