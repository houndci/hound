# encoding: UTF-8
require 'spec_helper'

class TestUser < TestModel
  validates :email, :email => true
end

class StrictUser < TestModel
  validates :email, :email => {:strict_mode => true}
end

class TestUserAllowsNil < TestModel
  validates :email, :email => {:allow_nil => true}
end

class TestUserAllowsNilFalse < TestModel
  validates :email, :email => {:allow_nil => false}
end

class TestUserWithMessage < TestModel
  validates :email_address, :email => {:message => 'is not looking very good!'}
end

describe EmailValidator do

  describe "validation" do
    context "given the valid emails" do
      [
        "a+b@plus-in-local.com",
        "a_b@underscore-in-local.com",
        "user@example.com",
        " user@example.com ",
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@letters-in-local.org",
        "01234567890@numbers-in-local.net",
        "a@single-character-in-local.org",
        "one-character-third-level@a.example.com",
        "single-character-in-sld@x.org",
        "local@dash-in-sld.com",
        "letters-in-sld@123.com",
        "one-letter-sld@x.org",
        "uncommon-tld@sld.museum",
        "uncommon-tld@sld.travel",
        "uncommon-tld@sld.mobi",
        "country-code-tld@sld.uk",
        "country-code-tld@sld.rw",
        "local@sld.newTLD",
        "local@sub.domains.com",
        "aaa@bbb.co.jp",
        "nigel.worthington@big.co.uk",
        "f@c.com",
        "areallylongnameaasdfasdfasdfasdf@asdfasdfasdfasdfasdf.ab.cd.ef.gh.co.ca",
        "ящик@яндекс.рф"
      ].each do |email|

        it "#{email.inspect} should be valid" do
          expect(TestUser.new(:email => email)).to be_valid
        end

        it "#{email.inspect} should be valid in strict_mode" do
          expect(StrictUser.new(:email => email)).to be_valid
        end

        it "#{email.inspect} should match the regexp" do
          expect(email =~ EmailValidator.regexp).to be_truthy
        end

        it "#{email.inspect} should match the strict regexp" do
          expect(email =~ EmailValidator.regexp(:strict_mode => true)).to be_truthy
        end

        it "#{email.inspect} should pass the class tester" do
          expect(EmailValidator.valid?(email)).to be_truthy
        end

      end

    end

    context "given the invalid emails" do
      [
        "",
        "f@s",
        "f@s.c",
        "@bar.com",
        "test@example.com@example.com",
        "test@",
        "@missing-local.org",
        "a b@space-in-local.com",
        "! \#$%\`|@invalid-characters-in-local.org",
        "<>@[]\`|@even-more-invalid-characters-in-local.org",
        "missing-sld@.com",
        "invalid-characters-in-sld@! \"\#$%(),/;<>_[]\`|.org",
        "missing-dot-before-tld@com",
        "missing-tld@sld.",
        " ",
        "missing-at-sign.net",
        "unbracketed-IP@127.0.0.1",
        "invalid-ip@127.0.0.1.26",
        "another-invalid-ip@127.0.0.256",
        "IP-and-port@127.0.0.1:25",
        "the-local-part-is-invalid-if-it-is-longer-than-sixty-four-characters@sld.net",
        "user@example.com\n<script>alert('hello')</script>"
      ].each do |email|

        it "#{email.inspect} should not be valid" do
          expect(TestUser.new(:email => email)).not_to be_valid
        end

        it "#{email.inspect} should not be valid in strict_mode" do
          expect(StrictUser.new(:email => email)).not_to be_valid
        end

        it "#{email.inspect} should not match the regexp" do
          expect(email =~ EmailValidator.regexp).to be_falsy
        end

        it "#{email.inspect} should not match the strict regexp" do
          expect(email =~ EmailValidator.regexp(:strict_mode => true)).to be_falsy
        end

        it "#{email.inspect} should fail the class tester" do
          expect(EmailValidator.valid?(email)).to be_falsy
        end

      end
    end

    context "given the emails that should be invalid in strict_mode but valid in normal mode" do
      [
        "hans,peter@example.com",
        "hans(peter@example.com",
        "hans)peter@example.com",
        "partially.\"quoted\"@sld.com",
        "&'*+-./=?^_{}~@other-valid-characters-in-local.net",
        "mixed-1234-in-{+^}-local@sld.net"
      ].each do |email|

        it "#{email.inspect} should be valid" do
          expect(TestUser.new(:email => email)).to be_valid
        end

        it "#{email.inspect} should not be valid in strict_mode" do
          expect(StrictUser.new(:email => email)).not_to be_valid
        end

        it "#{email.inspect} should match the regexp" do
          expect(email =~ EmailValidator.regexp).to be_truthy
        end

        it "#{email.inspect} should not match the strict regexp" do
          expect(email =~ EmailValidator.regexp(:strict_mode => true)).to be_falsy
        end

      end
    end
  end

  describe "error messages" do
    context "when the message is not defined" do
      subject { TestUser.new :email => 'invalidemail@' }
      before { subject.valid? }

      it "should add the default message" do
        expect(subject.errors[:email]).to include "is invalid"
      end
    end

    context "when the message is defined" do
      subject { TestUserWithMessage.new :email_address => 'invalidemail@' }
      before { subject.valid? }

      it "should add the customized message" do
        expect(subject.errors[:email_address]).to include "is not looking very good!"
      end
    end
  end

  describe "nil email" do
    it "should not be valid when :allow_nil option is missing" do
      expect(TestUser.new(:email => nil)).not_to be_valid
    end

    it "should be valid when :allow_nil options is set to true" do
      expect(TestUserAllowsNil.new(:email => nil)).to be_valid
    end

    it "should not be valid when :allow_nil option is set to false" do
      expect(TestUserAllowsNilFalse.new(:email => nil)).not_to be_valid
    end
  end

  describe "default_options" do
    context "when 'email_validator/strict' has been required" do
      before { require 'email_validator/strict' }

      it "should validate using strict mode" do
        expect(TestUser.new(:email => "&'*+-./=?^_{}~@other-valid-characters-in-local.net")).not_to be_valid
      end
    end
  end
end
