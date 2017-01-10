class MissingOwner
  MissingHoundConfig = Struct.new(:content)

  def hound_config
    MissingHoundConfig.new({})
  end
end
