require 'action_view/base'

module ActionView
  module ViewPaths
    extend ActiveSupport::Concern

    included do
      class_attribute :_view_paths
      self._view_paths = ActionView::PathSet.new
      self._view_paths.freeze
    end

    delegate :template_exists?, :view_paths, :formats, :formats=,
             :locale, :locale=, :to => :lookup_context

    module ClassMethods
      def _prefixes # :nodoc:
        @_prefixes ||= begin
          deprecated_prefixes = handle_deprecated_parent_prefixes
          if deprecated_prefixes
            deprecated_prefixes
          else
            return local_prefixes if superclass.abstract?

            local_prefixes + superclass._prefixes
          end
        end
      end

      private

      # Override this method in your controller if you want to change paths prefixes for finding views.
      # Prefixes defined here will still be added to parents' <tt>._prefixes</tt>.
      def local_prefixes
        [controller_path]
      end

      def handle_deprecated_parent_prefixes # TODO: remove in 4.3/5.0.
        return unless respond_to?(:parent_prefixes)

        ActiveSupport::Deprecation.warn(<<-MSG.squish)
          Overriding `ActionController::Base::parent_prefixes` is deprecated,
          override `.local_prefixes` instead.
        MSG

        local_prefixes + parent_prefixes
      end
    end

    # The prefixes used in render "foo" shortcuts.
    def _prefixes # :nodoc:
      self.class._prefixes
    end

    # LookupContext is the object responsible to hold all information required to lookup
    # templates, i.e. view paths and details. Check ActionView::LookupContext for more
    # information.
    def lookup_context
      @_lookup_context ||=
        ActionView::LookupContext.new(self.class._view_paths, details_for_lookup, _prefixes)
    end

    def details_for_lookup
      { }
    end

    def append_view_path(path)
      lookup_context.view_paths.push(*path)
    end

    def prepend_view_path(path)
      lookup_context.view_paths.unshift(*path)
    end

    module ClassMethods
      # Append a path to the list of view paths for this controller.
      #
      # ==== Parameters
      # * <tt>path</tt> - If a String is provided, it gets converted into
      #   the default view path. You may also provide a custom view path
      #   (see ActionView::PathSet for more information)
      def append_view_path(path)
        self._view_paths = view_paths + Array(path)
      end

      # Prepend a path to the list of view paths for this controller.
      #
      # ==== Parameters
      # * <tt>path</tt> - If a String is provided, it gets converted into
      #   the default view path. You may also provide a custom view path
      #   (see ActionView::PathSet for more information)
      def prepend_view_path(path)
        self._view_paths = ActionView::PathSet.new(Array(path) + view_paths)
      end

      # A list of all of the default view paths for this controller.
      def view_paths
        _view_paths
      end

      # Set the view paths.
      #
      # ==== Parameters
      # * <tt>paths</tt> - If a PathSet is provided, use that;
      #   otherwise, process the parameter into a PathSet.
      def view_paths=(paths)
        self._view_paths = ActionView::PathSet.new(Array(paths))
      end
    end
  end
end
