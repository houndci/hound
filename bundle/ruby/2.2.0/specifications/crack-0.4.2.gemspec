# -*- encoding: utf-8 -*-
# stub: crack 0.4.2 ruby lib

Gem::Specification.new do |s|
  s.name = "crack"
  s.version = "0.4.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["John Nunemaker"]
  s.date = "2014-02-02"
  s.description = "Really simple JSON and XML parsing, ripped from Merb and Rails."
  s.email = ["nunemaker@gmail.com"]
  s.homepage = "http://github.com/jnunemaker/crack"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Really simple JSON and XML parsing, ripped from Merb and Rails."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<safe_yaml>, ["~> 1.0.0"])
    else
      s.add_dependency(%q<safe_yaml>, ["~> 1.0.0"])
    end
  else
    s.add_dependency(%q<safe_yaml>, ["~> 1.0.0"])
  end
end
