require 'minitest/autorun'
require 'locked_down'

class LockedDownTest < Minitest::Test
  def setup
    @files_and_contents = []
    @files_and_contents << ['file1', 'contents of file1']
    @files_and_contents << ['file2', 'contents of file2']

    `mkdir tmp`
    `mkdir tmp/subdir`
    @files_and_contents.each do |(file, contents)|
      File.write "tmp/#{file}", contents
    end

    @passphrase = "supersecret"
  end

  def test_lockdown
    LockedDown.lockdown("tmp", @passphrase)
    assert_encrypted_directory_only
  end

  def test_unlock
    LockedDown.lockdown("tmp", @passphrase)
    LockedDown.unlock("tmp.zip.encrypted", @passphrase)
    assert_original_contents
  end

  def test_with_unlocked
    LockedDown.lockdown("tmp", @passphrase)
    LockedDown.with_unlocked("tmp.zip.encrypted", @passphrase) do
      assert_original_contents
    end
    assert_encrypted_directory_only
  end

  def assert_original_contents
    assert Dir.exist?('tmp')
    assert Dir.exist?('tmp/subdir')
    @files_and_contents.each do |(file, contents)|
      assert_equal File.read("tmp/#{file}"), contents
    end
    assert !File.exists?('tmp.zip')
    assert !File.exists?('tmp.zip.encrypted')
  end

  def assert_encrypted_directory_only
    assert File.exists?('tmp.zip.encrypted')
    assert !Dir.exist?('tmp')
  end

  def teardown
    @files_and_contents.each do |(file)|
      if File.exists? "tmp/#{file}"
        File.delete "tmp/#{file}"
      end
    end
    delete_if_exists 'tmp'
    delete_if_exists 'tmp.zip.encrypted'
  end

  def delete_if_exists file
    FileUtils.rm_r(file)  if Dir.exists?(file)
  end
end
