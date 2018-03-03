# frozen_string_literal: true

class BuildConfig
  static_facade :call

  def initialize(hound_config:, name:, owner:)
    @hound_config = hound_config
    @name = name
    @owner = owner
  end

  def call
    config_class.new(hound_config, owner: owner)
  end

  private

  attr_reader :hound_config, :name, :owner

  def config_class
    "Config::#{name.classify}".constantize
  rescue
    Config::Unsupported
  end
end
