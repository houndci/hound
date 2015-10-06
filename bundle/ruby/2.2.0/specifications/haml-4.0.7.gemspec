# -*- encoding: utf-8 -*-
# stub: haml 4.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "haml"
  s.version = "4.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Nathan Weizenbaum", "Hampton Catlin", "Norman Clarke"]
  s.date = "2015-08-10"
  s.description = "Haml (HTML Abstraction Markup Language) is a layer on top of HTML or XML that's\ndesigned to express the structure of documents in a non-repetitive, elegant, and\neasy way by using indentation rather than closing tags and allowing Ruby to be\nembedded with ease. It was originally envisioned as a plugin for Ruby on Rails,\nbut it can function as a stand-alone templating engine.\n"
  s.email = ["haml@googlegroups.com", "norman@njclarke.com"]
  s.executables = ["haml"]
  s.files = ["bin/haml"]
  s.homepage = "http://haml.info/"
  s.licenses = ["MIT"]
  s.post_install_message = "\nHEADS UP! Haml 4.0 has many improvements, but also has changes that may break\nyour application:\n\n* Support for Ruby 1.8.6 dropped\n* Support for Rails 2 dropped\n* Sass filter now always outputs <style> tags\n* Data attributes are now hyphenated, not underscored\n* html2haml utility moved to the html2haml gem\n* Textile and Maruku filters moved to the haml-contrib gem\n\nFor more info see:\n\nhttp://rubydoc.info/github/haml/haml/file/CHANGELOG.md\n\n"
  s.rubygems_version = "2.4.8"
  s.summary = "An elegant, structured (X)HTML/XML templating engine."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tilt>, [">= 0"])
      s.add_development_dependency(%q<rails>, [">= 3.0.0"])
      s.add_development_dependency(%q<rbench>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, ["~> 1.5.10"])
    else
      s.add_dependency(%q<tilt>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 3.0.0"])
      s.add_dependency(%q<rbench>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.5.10"])
    end
  else
    s.add_dependency(%q<tilt>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 3.0.0"])
    s.add_dependency(%q<rbench>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.5.10"])
  end
end
