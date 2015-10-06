# -*- encoding: utf-8 -*-
# stub: jwt 1.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jwt"
  s.version = "1.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jeff Lindsay"]
  s.date = "2015-06-22"
  s.description = "JSON Web Token implementation in Ruby"
  s.email = "progrium@gmail.com"
  s.extra_rdoc_files = ["lib/jwt.rb", "lib/jwt/json.rb"]
  s.files = ["Manifest", "Rakefile", "jwt.gemspec", "lib/jwt.rb", "lib/jwt/json.rb", "spec/helper.rb", "spec/jwt_spec.rb"]
  s.homepage = "http://github.com/progrium/ruby-jwt"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--line-numbers", "--title", "Jwt", "--main", "README.md"]
  s.rubyforge_project = "jwt"
  s.rubygems_version = "2.4.6"
  s.summary = "JSON Web Token implementation in Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<echoe>, [">= 4.6.3"])
    else
      s.add_dependency(%q<echoe>, [">= 4.6.3"])
    end
  else
    s.add_dependency(%q<echoe>, [">= 4.6.3"])
  end
end
