require "attr_extras"

class DefaultConfigFile
  CONFIG_DIR = "config/style_guides"
  THOUGHTBOT_CONFIG_DIR = "config/style_guides/thoughtbot"

  pattr_initialize :file_name, :repository_owner_name

  def path
    File.join(directory, file_name)
  end

  private

  def directory
    if thoughtbot_repository?
      THOUGHTBOT_CONFIG_DIR
    else
      CONFIG_DIR
    end
  end

  def thoughtbot_repository?
    repository_owner_name == "thoughtbot"
  end
end
