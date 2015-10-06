# -*- encoding: utf-8 -*-
# stub: stripe 1.29.0 ruby lib

Gem::Specification.new do |s|
  s.name = "stripe"
  s.version = "1.29.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ross Boucher", "Greg Brockman"]
  s.date = "2015-10-05"
  s.description = "Stripe is the easiest way to accept payments online.  See https://stripe.com for details."
  s.email = ["boucher@stripe.com", "gdb@stripe.com"]
  s.executables = ["stripe-console"]
  s.files = ["bin/stripe-console"]
  s.homepage = "https://stripe.com/api"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "Ruby bindings for the Stripe API"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, ["~> 1.4"])
      s.add_runtime_dependency(%q<json>, ["~> 1.8.1"])
      s.add_development_dependency(%q<mocha>, ["~> 0.13.2"])
      s.add_development_dependency(%q<shoulda>, ["~> 3.4.0"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, ["~> 1.4"])
      s.add_dependency(%q<json>, ["~> 1.8.1"])
      s.add_dependency(%q<mocha>, ["~> 0.13.2"])
      s.add_dependency(%q<shoulda>, ["~> 3.4.0"])
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, ["~> 1.4"])
    s.add_dependency(%q<json>, ["~> 1.8.1"])
    s.add_dependency(%q<mocha>, ["~> 0.13.2"])
    s.add_dependency(%q<shoulda>, ["~> 3.4.0"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
