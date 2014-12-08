require 'fileutils'
module LockedDown
  def self.lockdown directory, passphrase
    containing_directory = File.dirname directory
    directory_name = File.basename directory
    `zip -r #{directory} #{directory}/*`
    FileUtils.rm_r directory
    ziped_directory = "#{directory}.zip"
    encrypted_directory = "#{ziped_directory}.encrypted"
    `openssl aes-256-cbc -a  -pass pass:#{passphrase} -salt -in #{ziped_directory} -out #{encrypted_directory}`
    FileUtils.rm_r ziped_directory
    encrypted_directory[1..-1]
  end

  def self.unlock encrypted_directory, passphrase
    path = File.dirname encrypted_directory
    ziped_file = (path + File.basename(encrypted_directory, '.encrypted'))[1..-1]
    `openssl aes-256-cbc  -pass pass:#{passphrase} -d -a -in #{encrypted_directory} -out #{ziped_file}`
    FileUtils.rm encrypted_directory
    `unzip #{ziped_file}`
    FileUtils.rm ziped_file
    unencrypted_directory = File.basename ziped_file, '.zip'
  end

  def self.with_unlocked encrypted_directory, passphrase
    unencrypted_directory = unlock encrypted_directory, passphrase
    yield
    lockdown unencrypted_directory, passphrase
  end
end
