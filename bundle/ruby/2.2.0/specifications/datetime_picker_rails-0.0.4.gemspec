# -*- encoding: utf-8 -*-
# stub: datetime_picker_rails 0.0.4 ruby lib

Gem::Specification.new do |s|
  s.name = "datetime_picker_rails"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Grayson Wright"]
  s.date = "2015-09-04"
  s.description = "This gem packages the Bootstrap3 bootstrap-datetimepicker (JS + CSS) for Rails 3.1+ asset pipeline."
  s.email = ["wright.grayson@gmail.com"]
  s.homepage = "http://github.com/graysonwright/datetime_picker_rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Bootstrap3 bootstrap-datetimepicker\"s JS + CSS for Rails 3.1+ asset pipeline."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<momentjs-rails>, [">= 2.8.1"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<momentjs-rails>, [">= 2.8.1"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<momentjs-rails>, [">= 2.8.1"])
  end
end
