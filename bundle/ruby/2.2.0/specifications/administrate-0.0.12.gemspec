# -*- encoding: utf-8 -*-
# stub: administrate 0.0.12 ruby lib

Gem::Specification.new do |s|
  s.name = "administrate"
  s.version = "0.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Grayson Wright"]
  s.date = "2015-09-26"
  s.description = "Administrate is heavily inspired by projects like Rails Admin and ActiveAdmin,\nbut aims to provide a better user experience for site admins,\nand to be easier for developers to customize.\n\nTo do that, we're following a few simple rules:\n\n- No DSLs (domain-specific languages)\n- Support the simplest use cases,\n  and let the user override defaults with standard tools\n  such as plain Rails controllers and views.\n- Break up the library into core components and plugins,\n  so each component stays small and easy to maintain.\n"
  s.email = ["grayson@thoughtbot.com"]
  s.homepage = "https://administrate-docs.herokuapp.com/"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A Rails engine for creating super-flexible admin dashboards"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<autoprefixer-rails>, [">= 0"])
      s.add_runtime_dependency(%q<datetime_picker_rails>, ["~> 0.0.4"])
      s.add_runtime_dependency(%q<inline_svg>, ["~> 0.6"])
      s.add_runtime_dependency(%q<kaminari>, ["~> 0.16"])
      s.add_runtime_dependency(%q<momentjs-rails>, [">= 2.9.0"])
      s.add_runtime_dependency(%q<neat>, ["~> 1.1"])
      s.add_runtime_dependency(%q<normalize-rails>, ["~> 3.0"])
      s.add_runtime_dependency(%q<rails>, ["~> 4.2"])
      s.add_runtime_dependency(%q<sass>, ["~> 3.4"])
      s.add_runtime_dependency(%q<selectize-rails>, ["~> 0.6"])
    else
      s.add_dependency(%q<autoprefixer-rails>, [">= 0"])
      s.add_dependency(%q<datetime_picker_rails>, ["~> 0.0.4"])
      s.add_dependency(%q<inline_svg>, ["~> 0.6"])
      s.add_dependency(%q<kaminari>, ["~> 0.16"])
      s.add_dependency(%q<momentjs-rails>, [">= 2.9.0"])
      s.add_dependency(%q<neat>, ["~> 1.1"])
      s.add_dependency(%q<normalize-rails>, ["~> 3.0"])
      s.add_dependency(%q<rails>, ["~> 4.2"])
      s.add_dependency(%q<sass>, ["~> 3.4"])
      s.add_dependency(%q<selectize-rails>, ["~> 0.6"])
    end
  else
    s.add_dependency(%q<autoprefixer-rails>, [">= 0"])
    s.add_dependency(%q<datetime_picker_rails>, ["~> 0.0.4"])
    s.add_dependency(%q<inline_svg>, ["~> 0.6"])
    s.add_dependency(%q<kaminari>, ["~> 0.16"])
    s.add_dependency(%q<momentjs-rails>, [">= 2.9.0"])
    s.add_dependency(%q<neat>, ["~> 1.1"])
    s.add_dependency(%q<normalize-rails>, ["~> 3.0"])
    s.add_dependency(%q<rails>, ["~> 4.2"])
    s.add_dependency(%q<sass>, ["~> 3.4"])
    s.add_dependency(%q<selectize-rails>, ["~> 0.6"])
  end
end
