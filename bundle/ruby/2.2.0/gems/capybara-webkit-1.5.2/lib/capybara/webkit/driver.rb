require "capybara"
require "capybara/webkit/version"
require "capybara/webkit/node"
require "capybara/webkit/connection"
require "capybara/webkit/browser"
require "capybara/webkit/socket_debugger"
require "capybara/webkit/cookie_jar"
require "capybara/webkit/errors"

module Capybara::Webkit
  class Driver < Capybara::Driver::Base
    attr_reader :browser

    def initialize(app, options={})
      @app = app
      @options = options
      @browser = options[:browser] || Browser.new(Connection.new(options))
    end

    def enable_logging
      browser.enable_logging
    end

    def allow_url(url)
      browser.allow_url(url)
    end

    def block_url(url)
      browser.block_url(url)
    end

    def block_unknown_urls
      browser.block_unknown_urls
    end

    def current_url
      browser.current_url
    end

    def visit(path)
      browser.visit(path)
    end

    def find_xpath(xpath)
      browser.find_xpath(xpath).map { |native| Node.new(self, native) }
    end

    alias_method :find, :find_xpath

    def find_css(selector)
      browser.find_css(selector).map { |native| Node.new(self, native) }
    end

    def html
      browser.body
    end

    def header(key, value)
      browser.header(key, value)
    end

    def title
      browser.title
    end

    def execute_script(script)
      value = browser.execute_script script
      value.empty? ? nil : value
    end

    def evaluate_script(script)
      browser.evaluate_script script
    end

    def console_messages
      browser.console_messages
    end

    def error_messages
      browser.error_messages
    end

    def alert_messages
      warn '[DEPRECATION] Capybara::Webkit::Driver#alert_messages ' \
        'is deprecated. Please use Capybara::Session#accept_alert instead.'
      browser.alert_messages
    end

    def confirm_messages
      warn '[DEPRECATION] Capybara::Webkit::Driver#confirm_messages ' \
        'is deprecated. Please use Capybara::Session#accept_confirm ' \
        'or Capybara::Session#dismiss_confirm instead.'
      browser.confirm_messages
    end

    def prompt_messages
      warn '[DEPRECATION] Capybara::Webkit::Driver#prompt_messages ' \
        'is deprecated. Please use Capybara::Session#accept_prompt ' \
        'or Capybara::Session#dismiss_prompt instead.'
      browser.prompt_messages
    end

    def response_headers
      browser.response_headers
    end

    def status_code
      browser.status_code
    end

    def resize_window(width, height)
      warn '[DEPRECATION] Capybara::Webkit::Driver#resize_window ' \
        'is deprecated. Please use Capybara::Window#resize_to instead.'
      resize_window_to(current_window_handle, width, height)
    end

    def resize_window_to(handle, width, height)
      browser.window_resize(handle, width, height)
    end

    def window_size(handle)
      browser.window_size(handle)
    end

    def within_frame(selector)
      browser.frame_focus(selector)
      begin
        yield
      ensure
        browser.frame_focus
      end
    end

    def within_window(selector)
      current_window = current_window_handle
      switch_to_window(selector)
      begin
        yield
      ensure
        browser.window_focus(current_window)
      end
    end

    def switch_to_window(selector)
      browser.window_focus(selector)
    end

    def window_handles
      browser.get_window_handles
    end

    def current_window_handle
      browser.get_window_handle
    end

    def open_new_window
      browser.window_open
    end

    def close_window(selector)
      browser.window_close(selector)
    end

    def maximize_window(selector)
      browser.window_maximize(selector)
    end

    def accept_js_confirms!
      warn '[DEPRECATION] Capybara::Webkit::Driver#accept_js_confirms! ' \
        'is deprecated. Please use Capybara::Session#accept_confirm instead.'
      browser.accept_js_confirms
    end

    def dismiss_js_confirms!
      warn '[DEPRECATION] Capybara::Webkit::Driver#dismiss_js_confirms! ' \
        'is deprecated. Please use Capybara::Session#dismiss_confirm instead.'
      browser.reject_js_confirms
    end

    def accept_js_prompts!
      warn '[DEPRECATION] Capybara::Webkit::Driver#accept_js_prompts! ' \
        'is deprecated. Please use Capybara::Session#accept_prompt instead.'
      browser.accept_js_prompts
    end

    def dismiss_js_prompts!
      warn '[DEPRECATION] Capybara::Webkit::Driver#dismiss_js_prompts! ' \
        'is deprecated. Please use Capybara::Session#dismiss_prompt instead.'
      browser.reject_js_prompts
    end

    def js_prompt_input=(value)
      warn '[DEPRECATION] Capybara::Webkit::Driver#js_prompt_input= ' \
        'is deprecated. Please use Capybara::Session#accept_prompt instead.'
      if value.nil?
        browser.clear_prompt_text
      else
        browser.set_prompt_text_to(value)
      end
    end

    def go_back
      browser.go_back
    end

    def go_forward
      browser.go_forward
    end

    def accept_modal(type, options={})
      options = modal_action_options_for_browser(options)

      case type
      when :confirm
        id = browser.accept_confirm(options)
      when :prompt
        id = browser.accept_prompt(options)
      else
        id = browser.accept_alert(options)
      end

      yield

      find_modal(type, id, options)
    end

    def dismiss_modal(type, options={})
      options = modal_action_options_for_browser(options)

      case type
      when :confirm
        id = browser.reject_confirm(options)
      else
        id = browser.reject_prompt(options)
      end

      yield

      find_modal(type, id, options)
    end

    def wait?
      true
    end

    def needs_server?
      true
    end

    def reset!
      browser.reset!
    end

    def has_shortcircuit_timeout?
      false
    end

    def save_screenshot(path, options={})
      options[:width]  ||= 1000
      options[:height] ||= 10

      browser.render path, options[:width], options[:height]
    end

    def cookies
      @cookie_jar ||= CookieJar.new(browser)
    end

    def invalid_element_errors
      [Capybara::Webkit::ClickFailed]
    end

    def no_such_window_error
      Capybara::Webkit::NoSuchWindowError
    end

    def version
      [
        "Capybara: #{Capybara::VERSION}",
        "capybara-webkit: #{Capybara::Driver::Webkit::VERSION}",
        browser.version
      ].join("\n")
    end

    private

    def modal_action_options_for_browser(options)
      if options[:text].is_a?(Regexp)
        options.merge(text: options[:text].source)
      else
        options.merge(text: Regexp.escape(options[:text].to_s))
      end.merge(original_text: options[:text])
    end

    def find_modal(type, id, options)
      Timeout::timeout(options[:wait] || Capybara.default_wait_time) do
        browser.find_modal(id)
      end
    rescue ModalNotFound
      raise Capybara::ModalNotFound,
        "Unable to find modal dialog#{" with #{options[:original_text]}" if options[:original_text]}"
    rescue Timeout::Error
      raise Capybara::ModalNotFound,
        "Timed out waiting for modal dialog#{" with #{options[:original_text]}" if options[:original_text]}"
    end
  end
end
