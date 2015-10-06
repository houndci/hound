# Need to load haml before we can reference some Haml modules in our code
require 'haml'

require 'haml_lint/constants'
require 'haml_lint/exceptions'
require 'haml_lint/configuration'
require 'haml_lint/configuration_loader'
require 'haml_lint/document'
require 'haml_lint/haml_visitor'
require 'haml_lint/lint'
require 'haml_lint/linter_registry'
require 'haml_lint/ruby_parser'
require 'haml_lint/linter'
require 'haml_lint/logger'
require 'haml_lint/reporter'
require 'haml_lint/report'
require 'haml_lint/linter_selector'
require 'haml_lint/file_finder'
require 'haml_lint/runner'
require 'haml_lint/utils'
require 'haml_lint/version'

# Load all parse tree node classes
require 'haml_lint/tree/node'
require 'haml_lint/node_transformer'
Dir[File.expand_path('haml_lint/tree/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

# Load all linters
Dir[File.expand_path('haml_lint/linter/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end

# Load all reporters
Dir[File.expand_path('haml_lint/reporter/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
