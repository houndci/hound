# -*- encoding: utf-8 -*-
# stub: mono_logger 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mono_logger"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Steve Klabnik"]
  s.date = "2013-05-19"
  s.description = "A lock-free logger compatible with Ruby 2.0. Ruby does not allow you to request a lock in a trap handler because that could deadlock, so Logger is not sufficient."
  s.email = ["steve@steveklabnik.com"]
  s.homepage = "http://github.com/steveklabnik/mono_logger"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A lock-free logger compatible with Ruby 2.0."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 4.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 4.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 4.0"])
  end
end
