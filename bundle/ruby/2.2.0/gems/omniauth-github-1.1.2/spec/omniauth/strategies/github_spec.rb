require 'spec_helper'

describe OmniAuth::Strategies::GitHub do
  let(:access_token) { stub('AccessToken', :options => {}) }
  let(:parsed_response) { stub('ParsedResponse') }
  let(:response) { stub('Response', :parsed => parsed_response) }

  let(:enterprise_site)          { 'https://some.other.site.com/api/v3' }
  let(:enterprise_authorize_url) { 'https://some.other.site.com/login/oauth/authorize' }
  let(:enterprise_token_url)     { 'https://some.other.site.com/login/oauth/access_token' }
  let(:enterprise) do
    OmniAuth::Strategies::GitHub.new('GITHUB_KEY', 'GITHUB_SECRET',
        {
            :client_options => {
                :site => enterprise_site,
                :authorize_url => enterprise_authorize_url,
                :token_url => enterprise_token_url
            }
        }
    )
  end

  subject do
    OmniAuth::Strategies::GitHub.new({})
  end

  before(:each) do
    subject.stub!(:access_token).and_return(access_token)
  end

  context "client options" do
    it 'should have correct site' do
      subject.options.client_options.site.should eq("https://api.github.com")
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://github.com/login/oauth/authorize')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('https://github.com/login/oauth/access_token')
    end

    describe "should be overrideable" do
      it "for site" do
        enterprise.options.client_options.site.should eq(enterprise_site)
      end

      it "for authorize url" do
        enterprise.options.client_options.authorize_url.should eq(enterprise_authorize_url)
      end

      it "for token url" do
        enterprise.options.client_options.token_url.should eq(enterprise_token_url)
      end
    end
  end

  context "#email_access_allowed?" do
    it "should not allow email if scope is nil" do
      subject.options['scope'].should be_nil
      subject.should_not be_email_access_allowed
    end

    it "should allow email if scope is user" do
      subject.options['scope'] = 'user'
      subject.should be_email_access_allowed
    end

    it "should allow email if scope is a bunch of stuff including user" do
      subject.options['scope'] = 'public_repo,user,repo,delete_repo,gist'
      subject.should be_email_access_allowed
    end

    it "should not allow email if scope is other than user" do
      subject.options['scope'] = 'repo'
      subject.should_not be_email_access_allowed
    end

    it "should assume email access not allowed if scope is something currently not documented " do
      subject.options['scope'] = 'currently_not_documented'
      subject.should_not be_email_access_allowed
    end
  end

  context "#email" do
    it "should return email from raw_info if available" do
      subject.stub!(:raw_info).and_return({'email' => 'you@example.com'})
      subject.email.should eq('you@example.com')
    end

    it "should return nil if there is no raw_info and email access is not allowed" do
      subject.stub!(:raw_info).and_return({})
      subject.email.should be_nil
    end

    it "should return the primary email if there is no raw_info and email access is allowed" do
      emails = [
        { 'email' => 'secondary@example.com', 'primary' => false },
        { 'email' => 'primary@example.com',   'primary' => true }
      ]
      subject.stub!(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      subject.stub!(:emails).and_return(emails)
      subject.email.should eq('primary@example.com')
    end

    it "should return the first email if there is no raw_info and email access is allowed" do
      emails = [
        { 'email' => 'first@example.com',   'primary' => false },
        { 'email' => 'second@example.com',  'primary' => false }
      ]
      subject.stub!(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      subject.stub!(:emails).and_return(emails)
      subject.email.should eq('first@example.com')
    end
  end

  context "#raw_info" do
    it "should use relative paths" do
      access_token.should_receive(:get).with('user').and_return(response)
      subject.raw_info.should eq(parsed_response)
    end
  end

  context "#emails" do
    it "should use relative paths" do
      access_token.should_receive(:get).with('user/emails', :headers=>{"Accept"=>"application/vnd.github.v3"}).and_return(response)
      subject.options['scope'] = 'user'
      subject.emails.should eq(parsed_response)
    end
  end

end
