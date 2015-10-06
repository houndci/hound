# -*- encoding: utf-8 -*-
# stub: rails_12factor 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_12factor"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Richard Schneeman", "Terence Lee"]
  s.date = "2014-10-14"
  s.description = "Run Rails the 12factor way"
  s.email = ["richard@heroku.com", "terence@heroku.com"]
  s.homepage = "https://github.com/heroku/rails_12factor"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Following best practices from http://12factor.net run a maintainable, clean, and scalable app on Rails"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<rails_serve_static_assets>, [">= 0"])
      s.add_runtime_dependency(%q<rails_stdout_logging>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rails_serve_static_assets>, [">= 0"])
      s.add_dependency(%q<rails_stdout_logging>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rails_serve_static_assets>, [">= 0"])
    s.add_dependency(%q<rails_stdout_logging>, [">= 0"])
  end
end
