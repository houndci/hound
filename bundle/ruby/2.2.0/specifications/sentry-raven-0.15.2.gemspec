# -*- encoding: utf-8 -*-
# stub: sentry-raven 0.15.2 ruby lib

Gem::Specification.new do |s|
  s.name = "sentry-raven"
  s.version = "0.15.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sentry Team"]
  s.date = "2015-09-22"
  s.description = "A gem that provides a client interface for the Sentry error logger"
  s.email = "getsentry@googlegroups.com"
  s.executables = ["raven"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["LICENSE", "README.md", "bin/raven"]
  s.homepage = "https://github.com/getsentry/raven-ruby"
  s.licenses = ["Apache-2.0"]
  s.rubygems_version = "2.4.8"
  s.summary = "A gem that provides a client interface for the Sentry error logger"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, [">= 0.7.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<mime-types>, ["~> 1.16"])
      s.add_development_dependency(%q<rest-client>, [">= 0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
    else
      s.add_dependency(%q<faraday>, [">= 0.7.6"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<mime-types>, ["~> 1.16"])
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<timecop>, [">= 0"])
    end
  else
    s.add_dependency(%q<faraday>, [">= 0.7.6"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<mime-types>, ["~> 1.16"])
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<timecop>, [">= 0"])
  end
end
