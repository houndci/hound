# -*- encoding: utf-8 -*-
# stub: coffeelint 1.11.0 ruby lib

Gem::Specification.new do |s|
  s.name = "coffeelint"
  s.version = "1.11.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Zachary Bush"]
  s.date = "2015-08-19"
  s.description = "Ruby bindings for coffeelint"
  s.email = ["zach@zmbush.com"]
  s.executables = ["coffeelint.rb"]
  s.files = ["bin/coffeelint.rb"]
  s.homepage = "https://github.com/zipcodeman/coffeelint-ruby"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Ruby bindings for coffeelint along with railtie to add rake task to rails"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<coffee-script>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<execjs>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<coffee-script>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<execjs>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.1.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<coffee-script>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<execjs>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.1.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
