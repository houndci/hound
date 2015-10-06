module Raven

  INTERFACES = {}

  class Interface
    def initialize(attributes = nil)
      attributes.each do |attr, value|
        public_send "#{attr}=", value
      end if attributes

      yield self if block_given?
    end

    def self.name(value = nil)
      @interface_name ||= value
    end

    def to_hash
      Hash[instance_variables.map { |name| [name[1..-1].to_sym, instance_variable_get(name)] } ]
    end
  end

  def self.register_interface(mapping)
    mapping.each_pair do |key, klass|
      INTERFACES[key.to_s] = klass
      INTERFACES[klass.name] = klass
    end
  end

  def self.find_interface(name)
    INTERFACES[name.to_s]
  end
end
