# -*- encoding: utf-8 -*-
# stub: resque-sentry 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "resque-sentry"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Harry Marr"]
  s.date = "2014-03-20"
  s.email = ["harry@gocardless.com"]
  s.homepage = "https://github.com/gocardless/resque-sentry"
  s.rubygems_version = "2.4.8"
  s.summary = "A failure backend for Resque that sends events to Sentry"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<resque>, [">= 1.18.0"])
      s.add_runtime_dependency(%q<sentry-raven>, [">= 0.4.6"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6"])
      s.add_development_dependency(%q<mocha>, ["~> 0.11.0"])
    else
      s.add_dependency(%q<resque>, [">= 1.18.0"])
      s.add_dependency(%q<sentry-raven>, [">= 0.4.6"])
      s.add_dependency(%q<rspec>, ["~> 2.6"])
      s.add_dependency(%q<mocha>, ["~> 0.11.0"])
    end
  else
    s.add_dependency(%q<resque>, [">= 1.18.0"])
    s.add_dependency(%q<sentry-raven>, [">= 0.4.6"])
    s.add_dependency(%q<rspec>, ["~> 2.6"])
    s.add_dependency(%q<mocha>, ["~> 0.11.0"])
  end
end
