# -*- encoding: utf-8 -*-
# stub: puma 2.14.0 ruby lib
# stub: ext/puma_http11/extconf.rb

Gem::Specification.new do |s|
  s.name = "puma"
  s.version = "2.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Evan Phoenix"]
  s.date = "2015-09-18"
  s.description = "Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications. Puma is intended for use in both development and production environments. In order to get the best throughput, it is highly recommended that you use a  Ruby implementation with real threads like Rubinius or JRuby."
  s.email = ["evan@phx.io"]
  s.executables = ["puma", "pumactl"]
  s.extensions = ["ext/puma_http11/extconf.rb"]
  s.extra_rdoc_files = ["DEPLOYMENT.md", "History.txt", "Manifest.txt", "README.md", "docs/config.md", "docs/nginx.md", "docs/signals.md", "tools/jungle/README.md", "tools/jungle/init.d/README.md", "tools/jungle/upstart/README.md"]
  s.files = ["DEPLOYMENT.md", "History.txt", "Manifest.txt", "README.md", "bin/puma", "bin/pumactl", "docs/config.md", "docs/nginx.md", "docs/signals.md", "ext/puma_http11/extconf.rb", "tools/jungle/README.md", "tools/jungle/init.d/README.md", "tools/jungle/upstart/README.md"]
  s.homepage = "http://puma.io"
  s.licenses = ["BSD-3-Clause"]
  s.rdoc_options = ["--main", "README.md"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "2.4.8"
  s.summary = "Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<rack>, ["< 2.0", ">= 1.1"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 0.8"])
      s.add_development_dependency(%q<hoe>, ["~> 3.14"])
    else
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<rack>, ["< 2.0", ">= 1.1"])
      s.add_dependency(%q<rake-compiler>, ["~> 0.8"])
      s.add_dependency(%q<hoe>, ["~> 3.14"])
    end
  else
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<rack>, ["< 2.0", ">= 1.1"])
    s.add_dependency(%q<rake-compiler>, ["~> 0.8"])
    s.add_dependency(%q<hoe>, ["~> 3.14"])
  end
end
