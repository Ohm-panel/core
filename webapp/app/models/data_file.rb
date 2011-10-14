# Data file (for uploads)
class DataFile < ActiveRecord::Base
  def self.save(upload)
    return false if upload.nil?

    name = upload['datafile'].original_filename
    directory = "public/data"

    # create the file path
    path = File.join(directory, name)

    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }

    path
  end
end

