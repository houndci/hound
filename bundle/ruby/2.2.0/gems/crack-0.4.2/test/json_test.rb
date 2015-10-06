# coding: utf-8
require 'test_helper'

describe "JSON Parsing" do
  TESTS = {
    %q({"data": "G\u00fcnter"})                   => {"data" => "Günter"},
		%q({"html": "\u003Cdiv\\u003E"})              => {"html" => "<div>"},
    %q({"returnTo":{"\/categories":"\/"}})        => {"returnTo" => {"/categories" => "/"}},
    %q({returnTo:{"\/categories":"\/"}})          => {"returnTo" => {"/categories" => "/"}},
    %q({"return\\"To\\":":{"\/categories":"\/"}}) => {"return\"To\":" => {"/categories" => "/"}},
    %q({"returnTo":{"\/categories":1}})           => {"returnTo" => {"/categories" => 1}},
    %({"returnTo":[1,"a"]})                       => {"returnTo" => [1, "a"]},
    %({"returnTo":[1,"\\"a\\",", "b"]})           => {"returnTo" => [1, "\"a\",", "b"]},
    %({"a": "'", "b": "5,000"})                   => {"a" => "'", "b" => "5,000"},
    %({"a": "a's, b's and c's", "b": "5,000"})    => {"a" => "a's, b's and c's", "b" => "5,000"},
    %({"a": "2007-01-01"})                        => {'a' => Date.new(2007, 1, 1)},
    %({"a": "2007-01-01 01:12:34 Z"})             => {'a' => Time.utc(2007, 1, 1, 1, 12, 34)},
    # Handle ISO 8601 date/time format http://en.wikipedia.org/wiki/ISO_8601
    %({"a": "2007-01-01T01:12:34Z"})              => {'a' => Time.utc(2007, 1, 1, 1, 12, 34)},
    # no time zone
    %({"a": "2007-01-01 01:12:34"})               => {'a' => "2007-01-01 01:12:34"},
    %({"bio": "1985-01-29: birthdate"})           => {'bio' => '1985-01-29: birthdate'},
    %({"regex": /foo.*/})                         => {'regex' => /foo.*/},
    %({"regex": /foo.*/i})                        => {'regex' => /foo.*/i},
    %({"regex": /foo.*/mix})                      => {'regex' => /foo.*/mix},
    %([])    => [],
    %({})    => {},
    %(1)     => 1,
    %("")    => "",
    %("\\"") => "\"",
    %(null)  => nil,
    %(true)  => true,
    %(false) => false,
    %q("http:\/\/test.host\/posts\/1") => "http://test.host/posts/1",

    # \u0000 and \x00 escape sequences
    %q({"foo":"bar\u0000"}) => {"foo" => "bar"},
    %q({"foo":"bar\u0000baz"}) => {"foo" => "barbaz"},
    %q(bar\u0000) => "bar",
    %q(bar\u0000baz) => "barbaz",

    %q({"foo":"bar\x00"}) => {"foo" => "bar\x00"},
    %q({"foo":"bar\x00baz"}) => {"foo" => "bar\x00baz"}
  }

  TESTS.each do |json, expected|
    it "decode json (#{json})" do
      Crack::JSON.parse(json).must_equal expected
    end
  end

  it "is not vulnerable to YAML deserialization exploits" do
    class Foo; end
    refute_instance_of(Foo, Crack::JSON.parse("# '---/\n--- !ruby/object:Foo\n  foo: bar"))
  end

  it "raise error for failed decoding" do
    assert_raises(Crack::ParseError) {
      Crack::JSON.parse(%({: 1}))
    }
  end

  it "be able to parse a JSON response from a Twitter search about 'firefox'" do
    data = ''
    File.open(File.dirname(__FILE__) + "/data/twittersearch-firefox.json", "r") { |f|
        data = f.read
    }

    Crack::JSON.parse(data)
  end

  it "be able to parse a JSON response from a Twitter search about 'internet explorer'" do
    data = ''
    File.open(File.dirname(__FILE__) + "/data/twittersearch-ie.json", "r") { |f|
        data = f.read
    }

    Crack::JSON.parse(data)
  end
end
