# -*- encoding: utf-8 -*-
# stub: sexp_processor 4.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sexp_processor"
  s.version = "4.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ryan Davis"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDPjCCAiagAwIBAgIBAjANBgkqhkiG9w0BAQUFADBFMRMwEQYDVQQDDApyeWFu\nZC1ydWJ5MRkwFwYKCZImiZPyLGQBGRYJemVuc3BpZGVyMRMwEQYKCZImiZPyLGQB\nGRYDY29tMB4XDTE0MDkxNzIzMDcwN1oXDTE1MDkxNzIzMDcwN1owRTETMBEGA1UE\nAwwKcnlhbmQtcnVieTEZMBcGCgmSJomT8ixkARkWCXplbnNwaWRlcjETMBEGCgmS\nJomT8ixkARkWA2NvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALda\nb9DCgK+627gPJkB6XfjZ1itoOQvpqH1EXScSaba9/S2VF22VYQbXU1xQXL/WzCkx\ntaCPaLmfYIaFcHHCSY4hYDJijRQkLxPeB3xbOfzfLoBDbjvx5JxgJxUjmGa7xhcT\noOvjtt5P8+GSK9zLzxQP0gVLS/D0FmoE44XuDr3iQkVS2ujU5zZL84mMNqNB1znh\nGiadM9GHRaDiaxuX0cIUBj19T01mVE2iymf9I6bEsiayK/n6QujtyCbTWsAS9Rqt\nqhtV7HJxNKuPj/JFH0D2cswvzznE/a5FOYO68g+YCuFi5L8wZuuM8zzdwjrWHqSV\ngBEfoTEGr7Zii72cx+sCAwEAAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAw\nHQYDVR0OBBYEFEfFe9md/r/tj/Wmwpy+MI8d9k/hMA0GCSqGSIb3DQEBBQUAA4IB\nAQAFoDJRokCQdxFfOrmsKX41KOFlU/zjrbDVM9hgB/Ur999M6OXGSi8FitXNtMwY\nFVjsiAPeU7HaWVVcZkj6IhINelTkXsxgGz/qCzjHy3iUMuZWw36cS0fiWJ5rvH+e\nhD7uXxJSFuyf1riDGI1aeWbQ74WMwvNstOxLUMiV5a1fzBhlxPqb537ubDjq/M/h\nzPUFPVYeL5KjDHLCqI2FwIk2sEMOQgjpXHzl+3NlD2LUgUhHDMevmgVua0e2GT1B\nxJcC6UN6NHMOVMyAXsr2HR0gRRx4ofN1LoP2KhXzSr8UMvQYlwPmE0N5GQv1b5AO\nVpzF30vNaJK6ZT7xlIsIlwmH\n-----END CERTIFICATE-----\n"]
  s.date = "2015-05-28"
  s.description = "sexp_processor branches from ParseTree bringing all the generic sexp\nprocessing tools with it. Sexp, SexpProcessor, Environment, etc... all\nfor your language processing pleasure."
  s.email = ["ryand-ruby@zenspider.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt"]
  s.homepage = "https://github.com/seattlerb/sexp_processor"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.txt"]
  s.rubygems_version = "2.4.8"
  s.summary = "sexp_processor branches from ParseTree bringing all the generic sexp processing tools with it"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.7"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.7"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
