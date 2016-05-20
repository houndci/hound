Capybara::SpecHelper.spec '#reset_session!' do
  it "removes cookies" do
    @session.visit('/set_cookie')
    @session.visit('/get_cookie')
    expect(@session).to have_content('test_cookie')

    @session.reset_session!
    @session.visit('/get_cookie')
    expect(@session.body).not_to include('test_cookie')
  end

  it "resets current url, host, path" do
    @session.visit '/foo'
    expect(@session.current_url).not_to be_empty
    expect(@session.current_host).not_to be_empty
    expect(@session.current_path).to eq('/foo')

    @session.reset_session!
    expect([nil, '', 'about:blank']).to include(@session.current_url)
    expect(['', nil]).to include(@session.current_path)
    expect(@session.current_host).to be_nil
  end

  it "resets page body" do
    @session.visit('/with_html')
    expect(@session).to have_content('This is a test')
    expect(@session.find('.//h1').text).to include('This is a test')

    @session.reset_session!
    expect(@session.body).not_to include('This is a test')
    expect(@session).to have_no_selector('.//h1')
  end

  it "is synchronous" do
    @session.visit("/with_html")
    @session.reset_session!
    expect(@session).to have_no_selector :xpath, "/html/body/*", wait: false
  end

  it "raises any errors caught inside the server", :requires => [:server] do
    quietly { @session.visit("/error") }
    expect do
      @session.reset_session!
    end.to raise_error(TestApp::TestAppError)
    @session.visit("/")
    expect(@session.current_path).to eq("/")
  end

  it "ignores server errors when `Capybara.raise_server_errors = false`", :requires => [:server] do
    Capybara.raise_server_errors = false
    quietly { @session.visit("/error") }
    @session.reset_session!
    @session.visit("/")
    expect(@session.current_path).to eq("/")
  end
end
