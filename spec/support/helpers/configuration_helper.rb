module ConfigurationHelper
  def spy_on_file_read
    allow(File).to receive(:read).and_call_original
  end

  def thoughtbot_configuration_file(style_guide_class)
    File.join(
      DefaultConfigFile::THOUGHTBOT_CONFIG_DIR,
      style_guide_class::DEFAULT_CONFIG_FILENAME
    )
  end

  def default_configuration_file(style_guide_class)
    File.join(
      DefaultConfigFile::CONFIG_DIR,
      style_guide_class::DEFAULT_CONFIG_FILENAME
    )
  end
end
