# -*- encoding: utf-8 -*-
# stub: domain_name 0.5.25 ruby lib

Gem::Specification.new do |s|
  s.name = "domain_name"
  s.version = "0.5.25"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Akinori MUSHA"]
  s.date = "2015-10-06"
  s.description = "This is a Domain Name manipulation library for Ruby.\n\nIt can also be used for cookie domain validation based on the Public\nSuffix List.\n"
  s.email = ["knu@idaemons.org"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.md"]
  s.files = ["LICENSE.txt", "README.md"]
  s.homepage = "https://github.com/knu/ruby-domain_name"
  s.licenses = ["BSD-2-Clause", "BSD-3-Clause", "MPL-1.1", "GPL-2.0", "LGPL-2.1"]
  s.rubygems_version = "2.4.8"
  s.summary = "Domain Name manipulation library for Ruby"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<unf>, ["< 1.0.0", ">= 0.0.5"])
      s.add_development_dependency(%q<test-unit>, ["~> 2.5.5"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 1.2.0"])
      s.add_development_dependency(%q<rake>, [">= 0.9.2.2"])
      s.add_development_dependency(%q<rdoc>, [">= 2.4.2"])
    else
      s.add_dependency(%q<unf>, ["< 1.0.0", ">= 0.0.5"])
      s.add_dependency(%q<test-unit>, ["~> 2.5.5"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 1.2.0"])
      s.add_dependency(%q<rake>, [">= 0.9.2.2"])
      s.add_dependency(%q<rdoc>, [">= 2.4.2"])
    end
  else
    s.add_dependency(%q<unf>, ["< 1.0.0", ">= 0.0.5"])
    s.add_dependency(%q<test-unit>, ["~> 2.5.5"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 1.2.0"])
    s.add_dependency(%q<rake>, [">= 0.9.2.2"])
    s.add_dependency(%q<rdoc>, [">= 2.4.2"])
  end
end
