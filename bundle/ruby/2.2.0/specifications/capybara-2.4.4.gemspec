# -*- encoding: utf-8 -*-
# stub: capybara 2.4.4 ruby lib

Gem::Specification.new do |s|
  s.name = "capybara"
  s.version = "2.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jonas Nicklas"]
  s.cert_chain = ["gem-public_cert.pem"]
  s.date = "2014-10-13"
  s.description = "Capybara is an integration testing tool for rack based web applications. It simulates how a user would interact with a website"
  s.email = ["jonas.nicklas@gmail.com"]
  s.homepage = "http://github.com/jnicklas/capybara"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubyforge_project = "capybara"
  s.rubygems_version = "2.4.8"
  s.summary = "Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
      s.add_runtime_dependency(%q<rack>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<rack-test>, [">= 0.5.4"])
      s.add_runtime_dependency(%q<xpath>, ["~> 2.0"])
      s.add_development_dependency(%q<selenium-webdriver>, ["~> 2.0"])
      s.add_development_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_development_dependency(%q<rspec>, [">= 2.2.0"])
      s.add_development_dependency(%q<launchy>, [">= 2.0.4"])
      s.add_development_dependency(%q<yard>, [">= 0.5.8"])
      s.add_development_dependency(%q<fuubar>, [">= 0.0.1"])
      s.add_development_dependency(%q<cucumber>, [">= 0.10.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
      s.add_dependency(%q<mime-types>, [">= 1.16"])
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<rack-test>, [">= 0.5.4"])
      s.add_dependency(%q<xpath>, ["~> 2.0"])
      s.add_dependency(%q<selenium-webdriver>, ["~> 2.0"])
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
      s.add_dependency(%q<rspec>, [">= 2.2.0"])
      s.add_dependency(%q<launchy>, [">= 2.0.4"])
      s.add_dependency(%q<yard>, [">= 0.5.8"])
      s.add_dependency(%q<fuubar>, [">= 0.0.1"])
      s.add_dependency(%q<cucumber>, [">= 0.10.5"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 1.3.3"])
    s.add_dependency(%q<mime-types>, [">= 1.16"])
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<rack-test>, [">= 0.5.4"])
    s.add_dependency(%q<xpath>, ["~> 2.0"])
    s.add_dependency(%q<selenium-webdriver>, ["~> 2.0"])
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    s.add_dependency(%q<rspec>, [">= 2.2.0"])
    s.add_dependency(%q<launchy>, [">= 2.0.4"])
    s.add_dependency(%q<yard>, [">= 0.5.8"])
    s.add_dependency(%q<fuubar>, [">= 0.0.1"])
    s.add_dependency(%q<cucumber>, [">= 0.10.5"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
  end
end
