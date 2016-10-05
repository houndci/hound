module ConfigurationHelper
  def spy_on_file_read
    allow(File).to receive(:read).and_call_original
  end
end
