# -*- encoding: utf-8 -*-
# stub: rails_serve_static_assets 0.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_serve_static_assets"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Pedro Belo", "Jonathan Dance"]
  s.date = "2015-01-29"
  s.description = "Force Rails to serve static assets"
  s.email = ["pedro@heroku.com", "jd@heroku.com"]
  s.homepage = "https://github.com/heroku/rails_serve_static_assets"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Sets serve_static_assets to true so Rails will sere your static assets"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rails>, [">= 3.1"])
      s.add_development_dependency(%q<capybara>, [">= 0"])
      s.add_development_dependency(%q<sprockets>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.1"])
      s.add_dependency(%q<capybara>, [">= 0"])
      s.add_dependency(%q<sprockets>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.1"])
    s.add_dependency(%q<capybara>, [">= 0"])
    s.add_dependency(%q<sprockets>, [">= 0"])
  end
end
