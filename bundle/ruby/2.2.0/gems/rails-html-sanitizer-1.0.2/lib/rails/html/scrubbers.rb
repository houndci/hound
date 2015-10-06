module Rails
  module Html
    # === Rails::Html::PermitScrubber
    #
    # Rails::Html::PermitScrubber allows you to permit only your own tags and/or attributes.
    #
    # Rails::Html::PermitScrubber can be subclassed to determine:
    # - When a node should be skipped via +skip_node?+.
    # - When a node is allowed via +allowed_node?+.
    # - When an attribute should be scrubbed via +scrub_attribute?+.
    #
    # Subclasses don't need to worry if tags or attributes are set or not.
    # If tags or attributes are not set, Loofah's behavior will be used.
    # If you override +allowed_node?+ and no tags are set, it will not be called.
    # Instead Loofahs behavior will be used.
    # Likewise for +scrub_attribute?+ and attributes respectively.
    #
    # Text and CDATA nodes are skipped by default.
    # Unallowed elements will be stripped, i.e. element is removed but its subtree kept.
    # Supplied tags and attributes should be Enumerables.
    #
    # +tags=+
    # If set, elements excluded will be stripped.
    # If not, elements are stripped based on Loofahs +HTML5::Scrub.allowed_element?+.
    #
    # +attributes=+
    # If set, attributes excluded will be removed.
    # If not, attributes are removed based on Loofahs +HTML5::Scrub.scrub_attributes+.
    #
    # class CommentScrubber < Html::PermitScrubber
    #   def allowed_node?(node)
    #     !%w(form script comment blockquote).include?(node.name)
    #   end
    #
    #   def skip_node?(node)
    #     node.text?
    #   end
    #
    #   def scrub_attribute?(name)
    #     name == "style"
    #   end
    # end
    #
    # See the documentation for Nokogiri::XML::Node to understand what's possible
    # with nodes: http://nokogiri.org/Nokogiri/XML/Node.html
    class PermitScrubber < Loofah::Scrubber
      attr_reader :tags, :attributes

      def initialize
        @direction = :bottom_up
        @tags, @attributes = nil, nil
      end

      def tags=(tags)
        @tags = validate!(tags, :tags)
      end

      def attributes=(attributes)
        @attributes = validate!(attributes, :attributes)
      end

      def scrub(node)
        return CONTINUE if skip_node?(node)

        unless keep_node?(node)
          return STOP if scrub_node(node) == STOP
        end

        scrub_attributes(node)
      end

      protected

      def allowed_node?(node)
        @tags.include?(node.name)
      end

      def skip_node?(node)
        node.text? || node.cdata?
      end

      def scrub_attribute?(name)
        !@attributes.include?(name)
      end

      def keep_node?(node)
        if @tags
          allowed_node?(node)
        else
          Loofah::HTML5::Scrub.allowed_element?(node.name)
        end
      end

      def scrub_node(node)
        node.before(node.children) # strip
        node.remove
      end

      def scrub_attributes(node)
        if @attributes
          node.attribute_nodes.each do |attr|
            attr.remove if scrub_attribute?(attr.name)
          end

          scrub_css_attribute(node)
        else
          Loofah::HTML5::Scrub.scrub_attributes(node)
        end
      end

      def scrub_css_attribute(node)
        if Loofah::HTML5::Scrub.respond_to?(:scrub_css_attribute)
          Loofah::HTML5::Scrub.scrub_css_attribute(node)
        else
          style = node.attributes['style']
          style.value = Loofah::HTML5::Scrub.scrub_css(style.value) if style
        end
      end

      def validate!(var, name)
        if var && !var.is_a?(Enumerable)
          raise ArgumentError, "You should pass :#{name} as an Enumerable"
        end
        var
      end
    end

    # === Rails::Html::TargetScrubber
    #
    # Where Rails::Html::PermitScrubber picks out tags and attributes to permit in
    # sanitization, Rails::Html::TargetScrubber targets them for removal.
    #
    # +tags=+
    # If set, elements included will be stripped.
    #
    # +attributes=+
    # If set, attributes included will be removed.
    class TargetScrubber < PermitScrubber
      def allowed_node?(node)
        !@tags.include?(node.name)
      end

      def scrub_attribute?(name)
        @attributes.include?(name)
      end
    end
  end
end
