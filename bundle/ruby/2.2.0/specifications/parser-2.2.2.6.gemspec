# -*- encoding: utf-8 -*-
# stub: parser 2.2.2.6 ruby lib

Gem::Specification.new do |s|
  s.name = "parser"
  s.version = "2.2.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Peter Zotov"]
  s.date = "2015-06-30"
  s.description = "A Ruby parser written in pure Ruby."
  s.email = ["whitequark@whitequark.org"]
  s.executables = ["ruby-parse", "ruby-rewrite"]
  s.files = ["bin/ruby-parse", "bin/ruby-rewrite"]
  s.homepage = "https://github.com/whitequark/parser"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A Ruby parser written in pure Ruby."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ast>, ["< 3.0", ">= 1.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.2"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<racc>, ["= 1.4.9"])
      s.add_development_dependency(%q<cliver>, ["~> 0.3.0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<kramdown>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 5.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.8.2"])
      s.add_development_dependency(%q<coveralls>, [">= 0"])
      s.add_development_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<mime-types>, ["~> 1.25"])
      s.add_development_dependency(%q<rest-client>, ["~> 1.6.7"])
      s.add_development_dependency(%q<simplecov-sublime-ruby-coverage>, [">= 0"])
      s.add_development_dependency(%q<gauntlet>, [">= 0"])
    else
      s.add_dependency(%q<ast>, ["< 3.0", ">= 1.1"])
      s.add_dependency(%q<bundler>, ["~> 1.2"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<racc>, ["= 1.4.9"])
      s.add_dependency(%q<cliver>, ["~> 0.3.0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<kramdown>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 5.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.8.2"])
      s.add_dependency(%q<coveralls>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<mime-types>, ["~> 1.25"])
      s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
      s.add_dependency(%q<simplecov-sublime-ruby-coverage>, [">= 0"])
      s.add_dependency(%q<gauntlet>, [">= 0"])
    end
  else
    s.add_dependency(%q<ast>, ["< 3.0", ">= 1.1"])
    s.add_dependency(%q<bundler>, ["~> 1.2"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<racc>, ["= 1.4.9"])
    s.add_dependency(%q<cliver>, ["~> 0.3.0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<kramdown>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 5.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.8.2"])
    s.add_dependency(%q<coveralls>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<mime-types>, ["~> 1.25"])
    s.add_dependency(%q<rest-client>, ["~> 1.6.7"])
    s.add_dependency(%q<simplecov-sublime-ruby-coverage>, [">= 0"])
    s.add_dependency(%q<gauntlet>, [">= 0"])
  end
end
