module HamlLint::Tree
  # Represents a tag node in a HAML document.
  class TagNode < Node
    # Computed set of attribute hashes code.
    #
    # This is a combination of all dynamically calculated attributes from the
    # different attribute setting syntaxes (`{...}`/`(...)`), converted into
    # Ruby code.
    #
    # @return [Array<String>]
    def dynamic_attributes_sources
      @value[:attributes_hashes]
    end

    # Returns whether this tag contains executable script (e.g. is followed by a
    # `=`).
    #
    # @return [true,false]
    def contains_script?
      @value[:parse] && !@value[:value].strip.empty?
    end

    # Returns whether this tag has a specified attribute.
    #
    # @return [true,false]
    def has_hash_attribute?(attribute)
      hash_attributes? && existing_attributes.include?(attribute)
    end

    # List of classes statically defined for this tag.
    #
    # @example For `%tag.button.button-info{ class: status }`, this returns:
    #   ['button', 'button-info']
    #
    # @return [Array<String>] list of statically defined classes with leading
    #   dot removed
    def static_classes
      @static_classes ||=
        begin
          static_attributes_source.scan(/\.([-:\w]+)/)
        end
    end

    # List of ids statically defined for this tag.
    #
    # @example For `%tag.button#start-button{ id: special_id }`, this returns:
    #   ['start-button']
    #
    # @return [Array<String>] list of statically defined ids with leading `#`
    #   removed
    def static_ids
      @static_ids ||=
        begin
          static_attributes_source.scan(/#([-:\w]+)/)
        end
    end

    # Static element attributes defined after the tag name.
    #
    # @example For `%tag.button#start-button`, this returns:
    #   '.button#start-button'
    #
    # @return [String]
    def static_attributes_source
      attributes_source[:static] || ''
    end

    # Returns the source code for the dynamic attributes defined in `{...}`,
    # `(...)`, or `[...]` after a tag name.
    #
    # @example For `%tag.class{ id: 'hello' }(lang=en)`, this returns:
    #   { :hash => " id: 'hello' ", :html => "lang=en" }
    #
    # @return [Hash]
    def dynamic_attributes_source
      @dynamic_attributes_source ||=
        attributes_source.reject { |key| key == :static }
    end

    # Returns the source code for the static and dynamic attributes
    # of a tag.
    #
    # @example For `%tag.class{ id: 'hello' }(lang=en)`, this returns:
    #   { :static => '.class', :hash => " id: 'hello' ", :html => "lang=en" }
    #
    # @return [Hash]
    def attributes_source
      @attr_source ||=
        begin
          _explicit_tag, static_attrs, rest = source_code
            .scan(/\A\s*(%[-:\w]+)?([-:\w\.\#]*)(.*)/m)[0]

          attr_types = {
            '{' => [:hash, %w[{ }]],
            '(' => [:html, %w[( )]],
            '[' => [:object_ref, %w[[ ]]],
          }

          attr_source = { static: static_attrs }
          while rest
            type, chars = attr_types[rest[0]]
            break unless type # Not an attribute opening character, so we're done

            # Can't define multiple of the same attribute type (e.g. two {...})
            break if attr_source[type]

            attr_source[type], rest = Haml::Util.balance(rest, *chars)
          end

          attr_source
        end
    end

    # Whether this tag node has a set of hash attributes defined via the
    # curly brace syntax (e.g. `%tag{ lang: 'en' }`).
    #
    # @return [true,false]
    def hash_attributes?
      !dynamic_attributes_source[:hash].nil?
    end

    # Attributes defined after the tag name in Ruby hash brackets (`{}`).
    #
    # @example For `%tag.class{ lang: 'en' }`, this returns:
    #   " lang: 'en' "
    #
    # @return [String] source without the surrounding curly braces
    def hash_attributes_source
      dynamic_attributes_source[:hash]
    end

    # Whether this tag node has a set of HTML attributes defined via the
    # parentheses syntax (e.g. `%tag(lang=en)`).
    #
    # @return [true,false]
    def html_attributes?
      !dynamic_attributes_source[:html].nil?
    end

    # Attributes defined after the tag name in parentheses (`()`).
    #
    # @example For `%tag.class(lang=en)`, this returns:
    #   "lang=en"
    #
    # @return [String,nil] source without the surrounding parentheses, or `nil`
    #   if it has not been defined
    def html_attributes_source
      dynamic_attributes_source[:html][/\A\((.*)\)\z/, 1] if html_attributes?
    end

    # Name of the HTML tag.
    #
    # @return [String]
    def tag_name
      @value[:name]
    end

    # Whether this tag node has a set of square brackets (e.g. `%tag[...]`)
    # following it that indicates its class and ID will be to the value of the
    # given object's {#to_key} or {#id} method (in that order).
    #
    # @return [true,false]
    def object_reference?
      @value[:object_ref].to_s != 'nil'
    end

    # Source code for the contents of the node's object reference.
    #
    # @see http://haml.info/docs/yardoc/file.REFERENCE.html#object_reference_
    # @return [String,nil] string source of object reference or `nil` if it has
    #   not been defined
    def object_reference_source
      @value[:object_ref][/\A\[(.*)\]\z/, 1] if object_reference?
    end

    # Whether this node had a `<` after it signifying that outer whitespace
    # should be removed.
    #
    # @return [true,false]
    def remove_inner_whitespace?
      @value[:nuke_inner_whitespace]
    end

    # Whether this node had a `>` after it signifying that outer whitespace
    # should be removed.
    #
    # @return [true,false]
    def remove_outer_whitespace?
      @value[:nuke_outer_whitespace]
    end

    # Returns the script source that will be evaluated to produce this tag's
    # inner content, if any.
    #
    # @return [String]
    def script
      (@value[:value] if @value[:parse]) || ''
    end

    private

    def parsed_attributes
      HamlLint::RubyParser.new.parse(hash_attributes_source)
    end

    def existing_attributes
      parsed_attributes.children.collect do |parsed_attribute|
        parsed_attribute.children.first.to_a.first
      end
    end
  end
end
