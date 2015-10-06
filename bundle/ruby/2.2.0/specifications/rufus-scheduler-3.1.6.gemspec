# -*- encoding: utf-8 -*-
# stub: rufus-scheduler 3.1.6 ruby lib

Gem::Specification.new do |s|
  s.name = "rufus-scheduler"
  s.version = "3.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["John Mettraux"]
  s.date = "2015-09-30"
  s.description = "job scheduler for Ruby (at, cron, in and every jobs)."
  s.email = ["jmettraux@gmail.com"]
  s.homepage = "http://github.com/jmettraux/rufus-scheduler"
  s.licenses = ["MIT"]
  s.rubyforge_project = "rufus"
  s.rubygems_version = "2.4.8"
  s.summary = "job scheduler for Ruby (at, cron, in and every jobs)"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.13.0"])
      s.add_development_dependency(%q<chronic>, [">= 0"])
      s.add_development_dependency(%q<tzinfo>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.13.0"])
      s.add_dependency(%q<chronic>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.13.0"])
    s.add_dependency(%q<chronic>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
  end
end
