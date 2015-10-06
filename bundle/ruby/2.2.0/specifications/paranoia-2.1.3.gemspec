# -*- encoding: utf-8 -*-
# stub: paranoia 2.1.3 ruby lib

Gem::Specification.new do |s|
  s.name = "paranoia"
  s.version = "2.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["radarlistener@gmail.com"]
  s.date = "2015-06-17"
  s.description = "Paranoia is a re-implementation of acts_as_paranoid for Rails 3, using much, much, much less code. You would use either plugin / gem if you wished that when you called destroy on an Active Record object that it didn't actually destroy it, but just \"hid\" the record. Paranoia does this by setting a deleted_at field to the current time when you destroy a record, and hides it by scoping all queries on your model to only include records which do not have a deleted_at field."
  s.email = []
  s.homepage = "http://rubygems.org/gems/paranoia"
  s.rubyforge_project = "paranoia"
  s.rubygems_version = "2.4.8"
  s.summary = "Paranoia is a re-implementation of acts_as_paranoid for Rails 3, using much, much, much less code."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["~> 4.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, ["~> 4.0"])
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 4.0"])
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
