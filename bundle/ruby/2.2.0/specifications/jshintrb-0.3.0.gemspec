# -*- encoding: utf-8 -*-
# stub: jshintrb 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jshintrb"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["stereobooster"]
  s.date = "2015-02-25"
  s.description = "Ruby wrapper for JSHint. The main difference from jshint gem it does not depend on Java. Instead, it uses ExecJS"
  s.email = ["stereobooster@gmail.com"]
  s.homepage = "https://github.com/stereobooster/jshintrb"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Ruby wrapper for JSHint"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<submodule>, [">= 0.0.3"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3"])
      s.add_runtime_dependency(%q<execjs>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<submodule>, [">= 0.0.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 1.3"])
      s.add_dependency(%q<execjs>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<submodule>, [">= 0.0.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 1.3"])
    s.add_dependency(%q<execjs>, [">= 0"])
  end
end
