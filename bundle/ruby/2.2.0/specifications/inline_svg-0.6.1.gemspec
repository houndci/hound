# -*- encoding: utf-8 -*-
# stub: inline_svg 0.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "inline_svg"
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["James Martin"]
  s.date = "2015-08-05"
  s.description = "Get an SVG into your view and then style it with CSS."
  s.email = ["inline_svg@jmrtn.com"]
  s.homepage = "https://github.com/jamesmartin/inline_svg"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Embeds an SVG document, inline."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 4.0.4"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_runtime_dependency(%q<loofah>, [">= 2.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.5"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.2"])
      s.add_dependency(%q<activesupport>, [">= 4.0.4"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<loofah>, [">= 2.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.5"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.2"])
    s.add_dependency(%q<activesupport>, [">= 4.0.4"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<loofah>, [">= 2.0"])
  end
end
