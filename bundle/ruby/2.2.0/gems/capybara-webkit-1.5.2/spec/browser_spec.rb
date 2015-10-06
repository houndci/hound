require 'spec_helper'
require 'self_signed_ssl_cert'
require 'stringio'
require 'capybara/webkit/driver'
require 'socket'
require 'base64'

describe Capybara::Webkit::Browser do

  let(:connection) { Capybara::Webkit::Connection.new }
  let(:browser) { Capybara::Webkit::Browser.new(connection) }
  let(:browser_ignore_ssl_err) do
    Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
      browser.ignore_ssl_errors
    end
  end
  let(:browser_skip_images) do
    Capybara::Webkit::Browser.new(Capybara::Webkit::Connection.new).tap do |browser|
      browser.set_skip_image_loading(true)
    end
  end

  context 'handling of SSL validation errors' do
    before do
      # set up minimal HTTPS server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      # set up SSL layer
      ssl_serv = OpenSSL::SSL::SSLServer.new(@server, $openssl_self_signed_ctx)

      @server_thread = Thread.new(ssl_serv) do |serv|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          # write response
          html = "<html><body>D'oh!</body></html>"
          conn.write "HTTP/1.1 200 OK\r\n"
          conn.write "Content-Type:text/html\r\n"
          conn.write "Content-Length: %i\r\n" % html.size
          conn.write "\r\n"
          conn.write html
          conn.close
        end
      end
    end

    after do
      @server_thread.kill
      @server.close
    end

    it "doesn't accept a self-signed certificate by default" do
      lambda { browser.visit "https://#{@host}:#{@port}/" }.should raise_error
    end

    it 'accepts a self-signed certificate if configured to do so' do
      browser_ignore_ssl_err.visit "https://#{@host}:#{@port}/"
    end

    it "doesn't accept a self-signed certificate in a new window by default" do
      browser.execute_script("window.open('about:blank')")
      browser.window_focus(browser.get_window_handles.last)
      lambda { browser.visit "https://#{@host}:#{@port}/" }.should raise_error
    end

    it 'accepts a self-signed certificate in a new window if configured to do so' do
      browser_ignore_ssl_err.execute_script("window.open('about:blank')")
      browser_ignore_ssl_err.window_focus(browser_ignore_ssl_err.get_window_handles.last)
      browser_ignore_ssl_err.visit "https://#{@host}:#{@port}/"
    end
  end

  context "skip image loading" do
    before(:each) do
      # set up minimal HTTP server
      @host = "127.0.0.1"
      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]
      @received_requests = []

      @server_thread = Thread.new do
        while conn = @server.accept
          Thread.new(conn) do |thread_conn|
            # read request
            request = []
            until (line = thread_conn.readline.strip).empty?
              request << line
            end

            @received_requests << request.join("\n")

            # write response
            html = <<-HTML
            <html>
              <head>
                <style>
                  body {
                    background-image: url(/path/to/bgimage);
                  }
                </style>
              </head>
              <body>
                <img src="/path/to/image"/>
              </body>
            </html>
            HTML
            thread_conn.write "HTTP/1.1 200 OK\r\n"
            thread_conn.write "Content-Type:text/html\r\n"
            thread_conn.write "Content-Length: %i\r\n" % html.size
            thread_conn.write "\r\n"
            thread_conn.write html
            thread_conn.write("\r\n\r\n")
            thread_conn.close
          end
        end
      end
    end

    after(:each) do
      @server_thread.kill
      @server.close
    end

    it "should load images in image tags by default" do
      browser.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/image}   }.should_not be_nil
    end

    it "should load images in css by default" do
      browser.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/image}   }.should_not be_nil
    end

    it "should not load images in image tags when skip_image_loading is true" do
      browser_skip_images.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/image} }.should be_nil
    end

    it "should not load images in css when skip_image_loading is true" do
      browser_skip_images.visit("http://#{@host}:#{@port}/")
      @received_requests.find {|r| r =~ %r{/path/to/bgimage} }.should be_nil
    end
  end

  describe "forking", skip_on_windows: true, skip_on_jruby: true do
    it "only shuts down the server from the main process" do
      browser.reset!
      pid = fork {}
      Process.wait(pid)
      expect { browser.reset! }.not_to raise_error
    end
  end

  describe '#set_proxy' do
    before do
      @host = '127.0.0.1'
      @user = 'user'
      @pass = 'secret'
      @url  = "http://example.org/"

      @server = TCPServer.new(@host, 0)
      @port = @server.addr[1]

      @proxy_requests = []
      @proxy = Thread.new(@server, @proxy_requests) do |serv, proxy_requests|
        while conn = serv.accept do
          # read request
          request = []
          until (line = conn.readline.strip).empty?
            request << line
          end

          # send response
          auth_header = request.find { |h| h =~ /Authorization:/i }
          if auth_header || request[0].split(/\s+/)[1] =~ /^\//
            html = "<html><body>D'oh!</body></html>"
            conn.write "HTTP/1.1 200 OK\r\n"
            conn.write "Content-Type:text/html\r\n"
            conn.write "Content-Length: %i\r\n" % html.size
            conn.write "\r\n"
            conn.write html
            conn.close
            proxy_requests << request if auth_header
          else
            conn.write "HTTP/1.1 407 Proxy Auth Required\r\n"
            conn.write "Proxy-Authenticate: Basic realm=\"Proxy\"\r\n"
            conn.write "\r\n"
            conn.close
            proxy_requests << request
          end
        end
      end

      browser.set_proxy(:host => @host,
                        :port => @port,
                        :user => @user,
                        :pass => @pass)
      browser.visit @url
      @proxy_requests.size.should eq 2
      @request = @proxy_requests[-1]
    end

    after do
      @proxy.kill
      @server.close
    end

    it 'uses the HTTP proxy correctly' do
      @request[0].should match(/^GET\s+http:\/\/example.org\/\s+HTTP/i)
      @request.find { |header|
        header =~ /^Host:\s+example.org$/i }.should_not be nil
    end

    it 'sends correct proxy authentication' do
      auth_header = @request.find { |header|
        header =~ /^Proxy-Authorization:\s+/i }
      auth_header.should_not be nil

      user, pass = Base64.decode64(auth_header.split(/\s+/)[-1]).split(":")
      user.should eq @user
      pass.should eq @pass
    end

    it "uses the proxies' response" do
      browser.body.should include "D'oh!"
    end

    it 'uses original URL' do
      browser.current_url.should eq @url
    end

    it 'uses URLs changed by javascript' do
      browser.execute_script "window.history.pushState('', '', '/blah')"
      browser.current_url.should eq 'http://example.org/blah'
    end

    it 'is possible to disable proxy again' do
      @proxy_requests.clear
      browser.clear_proxy
      browser.visit "http://#{@host}:#{@port}/"
      @proxy_requests.size.should eq 0
    end
  end

  it "doesn't try to read an empty response" do
    connection = double("connection")
    connection.stub(:puts)
    connection.stub(:print)
    connection.stub(:gets).and_return("ok\n", "0\n")
    connection.stub(:read).and_raise(StandardError.new("tried to read empty response"))

    browser = Capybara::Webkit::Browser.new(connection)

    expect { browser.visit("/") }.not_to raise_error
  end

  describe '#command' do
    context 'non-ok response' do
      it 'raises an error of given class' do
        error_json = '{"class": "ClickFailed"}'

        connection.should_receive(:gets).ordered.and_return 'error'
        connection.should_receive(:gets).ordered.and_return error_json.bytesize
        connection.stub read: error_json

        expect { browser.command 'blah', 'meh' }.to raise_error(Capybara::Webkit::ClickFailed)
      end
    end
  end
end
