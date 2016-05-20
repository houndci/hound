require 'generators/haml/controller/controller_generator'

module Haml
  module Generators
    class MailerGenerator < ControllerGenerator
      source_root File.expand_path("../templates", __FILE__)

      def copy_view_files
        view_base_path = File.join("app/views", class_path, file_name)
        empty_directory view_base_path

        if self.behavior == :invoke
          formats.each do |format|
            layout_path = File.join("app/views/layouts", filename_with_extensions("mailer", format))
            template filename_with_extensions(:layout, format), layout_path
          end
        end

        actions.each do |action|
          @action = action

          formats.each do |format|
            @path = File.join(view_base_path, filename_with_extensions(action, format))
            template filename_with_extensions(:view, format), @path
          end
        end
      end

    protected
      def formats
        [:text, :html]
      end

    end
  end
end
