# -*- encoding: utf-8 -*-
# stub: analytics-ruby 2.0.13 ruby lib

Gem::Specification.new do |s|
  s.name = "analytics-ruby"
  s.version = "2.0.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Segment.io"]
  s.date = "2015-09-10"
  s.description = "The Segment.io ruby analytics library"
  s.email = "friends@segment.io"
  s.homepage = "https://github.com/segmentio/analytics-ruby"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Segment.io analytics library"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, ["~> 10.3"])
      s.add_development_dependency(%q<wrong>, ["~> 0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<tzinfo>, ["= 1.2.1"])
      s.add_development_dependency(%q<activesupport>, ["< 4.0.0", ">= 3.0.0"])
    else
      s.add_dependency(%q<rake>, ["~> 10.3"])
      s.add_dependency(%q<wrong>, ["~> 0.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<tzinfo>, ["= 1.2.1"])
      s.add_dependency(%q<activesupport>, ["< 4.0.0", ">= 3.0.0"])
    end
  else
    s.add_dependency(%q<rake>, ["~> 10.3"])
    s.add_dependency(%q<wrong>, ["~> 0.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<tzinfo>, ["= 1.2.1"])
    s.add_dependency(%q<activesupport>, ["< 4.0.0", ">= 3.0.0"])
  end
end
