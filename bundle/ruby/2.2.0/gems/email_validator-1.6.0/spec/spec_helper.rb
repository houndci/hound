require 'rubygems'
require 'rspec'
require 'active_model'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'email_validator'

class TestModel
  include ActiveModel::Validations

  def initialize(attributes = {})
    @attributes = attributes
  end
  
  def read_attribute_for_validation(key)
    @attributes[key]
  end
end