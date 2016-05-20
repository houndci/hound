require 'base64'

module ActionMailer
  # Implements a mailer preview interceptor that converts image tag src attributes
  # that use inline cid: style urls to data: style urls so that they are visible
  # when previewing a HTML email in a web browser.
  #
  # This interceptor is not enabled by default, to use it just register it like any
  # other mailer preview interceptor:
  #
  #   ActionMailer::Base.register_preview_interceptor(ActionMailer::InlinePreviewInterceptor)
  #
  class InlinePreviewInterceptor
    PATTERN  = /src=(?:"cid:[^"]+"|'cid:[^']+')/i

    include Base64

    def self.previewing_email(message) #:nodoc:
      new(message).transform!
    end

    def initialize(message) #:nodoc:
      @message = message
    end

    def transform! #:nodoc:
      return message if html_part.blank?

      html_source.gsub!(PATTERN) do |match|
        if part = find_part(match[9..-2])
          %[src="#{data_url(part)}"]
        else
          match
        end
      end

      message
    end

    private
      def message
        @message
      end

      def html_part
        @html_part ||= message.html_part
      end

      def html_source
        html_part.body.raw_source
      end

      def data_url(part)
        "data:#{part.mime_type};base64,#{strict_encode64(part.body.raw_source)}"
      end

      def find_part(cid)
        message.all_parts.find{ |p| p.attachment? && p.cid == cid }
      end
  end
end
