require 'hashie/mash'

module OmniAuth
  # The AuthHash is a normalized schema returned by all OmniAuth
  # strategies. It maps as much user information as the provider
  # is able to provide into the InfoHash (stored as the `'info'`
  # key).
  class AuthHash < Hashie::Mash
    def self.subkey_class
      Hashie::Mash
    end

    # Tells you if this is considered to be a valid
    # OmniAuth AuthHash. The requirements for that
    # are that it has a provider name, a uid, and a
    # valid info hash. See InfoHash#valid? for
    # more details there.
    def valid?
      uid? && provider? && info? && info.valid?
    end

    def regular_writer(key, value)
      if key.to_s == 'info' && !value.is_a?(InfoHash)
        value = InfoHash.new(value)
      end
      super
    end

    class InfoHash < Hashie::Mash
      def self.subkey_class
        Hashie::Mash
      end

      def name
        return self[:name] if self[:name]
        return "#{first_name} #{last_name}".strip if first_name? || last_name?
        return nickname if nickname?
        return email if email?
        nil
      end

      def name?
        !!name # rubocop:disable DoubleNegation
      end
      alias_method :valid?, :name?

      def to_hash
        hash = super
        hash['name'] ||= name
        hash
      end
    end
  end
end
