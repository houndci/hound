require "inline_svg/version"
require "inline_svg/action_view/helpers"
require "inline_svg/asset_file"
require "inline_svg/finds_asset_paths"
require "inline_svg/transform_pipeline"

require "inline_svg/railtie" if defined?(Rails)
require 'active_support/core_ext/string'
require 'nokogiri'

module InlineSvg
  class Configuration
    class Invalid < ArgumentError; end

    attr_reader :asset_finder, :custom_transformations

    def initialize
      @custom_transformations = {}
    end

    def asset_finder=(finder)
      if finder.respond_to?(:find_asset)
        @asset_finder = finder
      else
        raise InlineSvg::Configuration::Invalid.new("Asset Finder should implement the #find_asset method")
      end
      asset_finder
    end

    def add_custom_transformation(options)
      if incompatible_transformation?(options.fetch(:transform))
        raise InlineSvg::Configuration::Invalid.new("#{options.fetch(:transform)} should implement the .create_with_value and #transform methods")
      end
      @custom_transformations.merge!(Hash[ *[options.fetch(:attribute, :no_attribute), options.fetch(:transform, no_transform)] ])
    end

    private

    def incompatible_transformation?(klass)
      !klass.is_a?(Class) || !klass.respond_to?(:create_with_value) || !klass.instance_methods.include?(:transform)
    end

    def no_transform
      InlineSvg::TransformPipeline::Transformations::NullTransformation
    end
  end

  @configuration = InlineSvg::Configuration.new

  class << self
    attr_reader :configuration

    def configure
      if block_given?
        yield configuration
      else
        raise InlineSvg::Configuration::Invalid.new('Please set configuration options with a block')
      end
    end

    def reset_configuration!
      @configuration = InlineSvg::Configuration.new
    end
  end
end
