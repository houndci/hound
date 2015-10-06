# -*- encoding: utf-8 -*-
# stub: faraday 0.9.1 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday"
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Rick Olson"]
  s.date = "2015-01-07"
  s.email = "technoweenie@gmail.com"
  s.homepage = "https://github.com/lostisland/faraday"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "HTTP/REST API client library."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multipart-post>, ["< 3", ">= 1.2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
    else
      s.add_dependency(%q<multipart-post>, ["< 3", ">= 1.2"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<multipart-post>, ["< 3", ">= 1.2"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
  end
end
