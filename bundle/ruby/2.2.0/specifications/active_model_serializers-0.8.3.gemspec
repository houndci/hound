# -*- encoding: utf-8 -*-
# stub: active_model_serializers 0.8.3 ruby lib

Gem::Specification.new do |s|
  s.name = "active_model_serializers"
  s.version = "0.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jos\u{e9} Valim", "Yehuda Katz"]
  s.date = "2014-12-10"
  s.description = "Making it easy to serialize models for client-side use"
  s.email = ["jose.valim@gmail.com", "wycats@gmail.com"]
  s.homepage = "https://github.com/rails-api/active_model_serializers"
  s.rubygems_version = "2.4.8"
  s.summary = "Bringing consistency and object orientation to model serialization. Works great for client-side MVC frameworks!"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activemodel>, [">= 3.0"])
      s.add_development_dependency(%q<rails>, [">= 3.0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
    else
      s.add_dependency(%q<activemodel>, [">= 3.0"])
      s.add_dependency(%q<rails>, [">= 3.0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
    end
  else
    s.add_dependency(%q<activemodel>, [">= 3.0"])
    s.add_dependency(%q<rails>, [">= 3.0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
  end
end
