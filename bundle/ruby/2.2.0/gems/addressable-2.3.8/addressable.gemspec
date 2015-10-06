# -*- encoding: utf-8 -*-
# stub: addressable 2.3.8 ruby lib

Gem::Specification.new do |s|
  s.name = "addressable"
  s.version = "2.3.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bob Aman"]
  s.date = "2015-03-27"
  s.description = "Addressable is a replacement for the URI implementation that is part of\nRuby's standard library. It more closely conforms to the relevant RFCs and\nadds support for IRIs and URI templates.\n"
  s.email = "bob@sporkmonger.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["CHANGELOG.md", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "addressable.gemspec", "data/unicode.data", "lib/addressable/idna.rb", "lib/addressable/idna/native.rb", "lib/addressable/idna/pure.rb", "lib/addressable/template.rb", "lib/addressable/uri.rb", "lib/addressable/version.rb", "spec/addressable/idna_spec.rb", "spec/addressable/net_http_compat_spec.rb", "spec/addressable/template_spec.rb", "spec/addressable/uri_spec.rb", "spec/spec_helper.rb", "tasks/clobber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/metrics.rake", "tasks/rspec.rake", "tasks/yard.rake", "website/index.html"]
  s.homepage = "https://github.com/sporkmonger/addressable"
  s.licenses = ["Apache License 2.0"]
  s.rdoc_options = ["--main", "README.md"]
  s.rubygems_version = "2.4.6"
  s.summary = "URI Implementation"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<rspec-its>, ["~> 1.1"])
      s.add_development_dependency(%q<launchy>, [">= 2.4.3", "~> 2.4"])
    else
      s.add_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<rspec-its>, ["~> 1.1"])
      s.add_dependency(%q<launchy>, [">= 2.4.3", "~> 2.4"])
    end
  else
    s.add_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<rspec-its>, ["~> 1.1"])
    s.add_dependency(%q<launchy>, [">= 2.4.3", "~> 2.4"])
  end
end
