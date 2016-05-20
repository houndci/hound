require File.expand_path('../../test_helper', __FILE__)

module Stripe
  class AccountTest < Test::Unit::TestCase
    should "be retrievable" do
      resp = make_account({
        :charges_enabled => false,
        :details_submitted => false,
        :email => "test+bindings@stripe.com",
      })
      @mock.expects(:get).
        once.
        with('https://api.stripe.com/v1/account', nil, nil).
        returns(make_response(resp))
      a = Stripe::Account.retrieve
      assert_equal "test+bindings@stripe.com", a.email
      assert !a.charges_enabled
      assert !a.details_submitted
    end

    should "be retrievable via plural endpoint" do
      resp = make_account({
        :charges_enabled => false,
        :details_submitted => false,
        :email => "test+bindings@stripe.com",
      })
      @mock.expects(:get).
        once.
        with('https://api.stripe.com/v1/accounts/acct_foo', nil, nil).
        returns(make_response(resp))
      a = Stripe::Account.retrieve('acct_foo')
      assert_equal "test+bindings@stripe.com", a.email
      assert !a.charges_enabled
      assert !a.details_submitted
    end

    should "be retrievable using an API key as the only argument" do
      account = mock
      Stripe::Account.expects(:new).once.with(nil, {:api_key => 'sk_foobar'}).returns(account)
      account.expects(:refresh).once
      Stripe::Account.retrieve('sk_foobar')
    end

    should "allow access to keys by method" do
      account = Stripe::Account.construct_from(make_account({
        :keys => {
          :publishable => 'publishable-key',
          :secret => 'secret-key',
        }
      }))
      assert_equal 'publishable-key', account.keys.publishable
      assert_equal 'secret-key', account.keys.secret
    end

    should "be updatable" do
      resp = {
        :id => 'acct_foo',
        :legal_entity => {
          :address => {
            :line1 => '1 Two Three'
          }
        }
      }
      @mock.expects(:get).
        once.
        with('https://api.stripe.com/v1/accounts/acct_foo', nil, nil).
        returns(make_response(resp))

      @mock.expects(:post).
        once.
        with('https://api.stripe.com/v1/accounts/acct_foo', nil, 'legal_entity[first_name]=Bob&legal_entity[address][line1]=2%20Three%20Four').
        returns(make_response(resp))

      a = Stripe::Account.retrieve('acct_foo')
      a.legal_entity.first_name = 'Bob'
      a.legal_entity.address.line1 = '2 Three Four'
      a.save
    end

    should 'disallow direct overrides of legal_entity' do
      account = Stripe::Account.construct_from(make_account({
        :keys => {
          :publishable => 'publishable-key',
          :secret => 'secret-key',
        },
        :legal_entity => {
          :first_name => 'Bling'
        }
      }))

      assert_raise NoMethodError do
        account.legal_entity = {:first_name => 'Blah'}
      end

      account.legal_entity.first_name = 'Blah'
    end

    should "be able to deauthorize an account" do
      resp = {:id => 'acct_1234', :email => "test+bindings@stripe.com", :charge_enabled => false, :details_submitted => false}
      @mock.expects(:get).once.returns(make_response(resp))
      a = Stripe::Account.retrieve


      @mock.expects(:post).once.with do |url, api_key, params|
        url == "#{Stripe.connect_base}/oauth/deauthorize" && api_key.nil? && CGI.parse(params) == { 'client_id' => [ 'ca_1234' ], 'stripe_user_id' => [ a.id ]}
      end.returns(make_response({ 'stripe_user_id' => a.id }))
      a.deauthorize('ca_1234', 'sk_test_1234')
    end

    should "reject nil api keys" do
      assert_raise TypeError do
        Stripe::Account.retrieve(nil)
      end
      assert_raise TypeError do
        Stripe::Account.retrieve(:api_key => nil)
      end
    end

    should "be able to create a bank account" do
      resp = {
        :id => 'acct_1234',
        :external_accounts => {
          :object => "list",
          :url => "/v1/accounts/acct_1234/external_accounts",
          :data => [],
        }
      }
      @mock.expects(:get).once.returns(make_response(resp))
      a = Stripe::Account.retrieve

      @mock.expects(:post).
        once.
        with('https://api.stripe.com/v1/accounts/acct_1234/external_accounts', nil, 'external_account=btok_1234').
        returns(make_response(resp))
      a.external_accounts.create({:external_account => 'btok_1234'})
    end

    should "be able to retrieve a bank account" do
      resp = {
        :id => 'acct_1234',
        :external_accounts => {
          :object => "list",
          :url => "/v1/accounts/acct_1234/external_accounts",
          :data => [{
            :id => "ba_1234",
            :object => "bank_account",
          }],
        }
      }
      @mock.expects(:get).once.returns(make_response(resp))
      a = Stripe::Account.retrieve
      assert_equal(BankAccount, a.external_accounts.data[0].class)
    end
  end
end
