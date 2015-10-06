# -*- encoding: utf-8 -*-
# stub: sysexits 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sysexits"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDbDCCAlSgAwIBAgIBATANBgkqhkiG9w0BAQUFADA+MQwwCgYDVQQDDANnZWQx\nGTAXBgoJkiaJk/IsZAEZFglGYWVyaWVNVUQxEzARBgoJkiaJk/IsZAEZFgNvcmcw\nHhcNMTQwMzE5MDQzNTI2WhcNMTUwMzE5MDQzNTI2WjA+MQwwCgYDVQQDDANnZWQx\nGTAXBgoJkiaJk/IsZAEZFglGYWVyaWVNVUQxEzARBgoJkiaJk/IsZAEZFgNvcmcw\nggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDb92mkyYwuGBg1oRxt2tkH\n+Uo3LAsaL/APBfSLzy8o3+B3AUHKCjMUaVeBoZdWtMHB75X3VQlvXfZMyBxj59Vo\ncDthr3zdao4HnyrzAIQf7BO5Y8KBwVD+yyXCD/N65TTwqsQnO3ie7U5/9ut1rnNr\nOkOzAscMwkfQxBkXDzjvAWa6UF4c5c9kR/T79iA21kDx9+bUMentU59aCJtUcbxa\n7kcKJhPEYsk4OdxR9q2dphNMFDQsIdRO8rywX5FRHvcb+qnXC17RvxLHtOjysPtp\nEWsYoZMxyCDJpUqbwoeiM+tAHoz2ABMv3Ahie3Qeb6+MZNAtMmaWfBx3dg2u+/WN\nAgMBAAGjdTBzMAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQWBBSZ0hCV\nqoHr122fGKelqffzEQBhszAcBgNVHREEFTATgRFnZWRARmFlcmllTVVELm9yZzAc\nBgNVHRIEFTATgRFnZWRARmFlcmllTVVELm9yZzANBgkqhkiG9w0BAQUFAAOCAQEA\nTuL1Bzl6TBs1YEzEubFHb9XAPgehWzzUudjDKzTRd+uyZmxnomBqTCQjT5ucNRph\n3jZ6bhLNooLQxTjIuHodeGcEMHZdt4Yi7SyPmw5Nry12z6wrDp+5aGps3HsE5WsQ\nZq2EuyEOc96g31uoIvjNdieKs+1kE+K+dJDjtw+wTH2i63P7r6N/NfPPXpxsFquo\nwcYRRrHdR7GhdJeT+V8Q8Bi5bglCUGdx+8scMgkkePc98k9osQHypbACmzO+Bqkv\nc7ZKPJcWBv0sm81+FCZXNACn2f9jfF8OQinxVs0O052KbGuEQaaiGIYeuuwQE2q6\nggcrPfcYeTwWlfZPu2LrBg==\n-----END CERTIFICATE-----\n"]
  s.date = "2014-08-08"
  s.description = "Have you ever wanted to call <code>exit()</code> with an error condition, but\nweren't sure what exit status to use? No? Maybe it's just me, then.\n\nAnyway, I was reading manpages late one evening before retiring to bed in my\npalatial estate in rural Oregon, and I stumbled across\n<code>sysexits(3)</code>. Much to my chagrin, I couldn't find a +sysexits+ for\nRuby! Well, for the other 2 people that actually care about\n<code>style(9)</code> as it applies to Ruby code, now there is one!\n\nSysexits is a *completely* *awesome* collection of human-readable constants for\nthe standard (BSDish) exit codes, used as arguments to +exit+ to\nindicate a specific error condition to the parent process.\n\nIt's so fantastically fabulous that you'll want to fork it right away to avoid\nbeing thought of as that guy that's still using Webrick for his blog. I mean,\n<code>exit(1)</code> is so pass\u{e9}! This is like the 14-point font of Systems\nProgramming.\n\nLike the C header file from which this was derived (I mean forked, naturally),\nerror numbers begin at <code>Sysexits::EX__BASE</code> (which is way more cool\nthan plain old +64+) to reduce the possibility of clashing with other exit\nstatuses that other programs may already return.\n\nThe codes are available in two forms: as constants which can be imported into\nyour own namespace via <code>include Sysexits</code>, or as\n<code>Sysexits::STATUS_CODES</code>, a Hash keyed by Symbols derived from the\nconstant names.\n\nAllow me to demonstrate. First, the old way:\n\n    exit( 69 )\n\nWhaaa...? Is that a euphemism? What's going on? See how unattractive and...\nwell, 1970 that is? We're not changing vaccuum tubes here, people, we're\n<em>building a totally-awesome future in the Cloud\u{2122}!</em>\n\n    include Sysexits\n    exit EX_UNAVAILABLE\n\nOkay, at least this is readable to people who have used <code>fork()</code>\nmore than twice, but you could do so much better!\n\n    include Sysexits\n    exit :unavailable\n\nHoly Toledo! It's like we're writing Ruby, but our own made-up dialect in\nwhich variable++ is possible! Well, okay, it's not quite that cool. But it\ndoes look more Rubyish. And no monkeys were patched in the filming of this\nepisode! All the simpletons still exiting with icky _numbers_ can still\ncontinue blithely along, none the wiser."
  s.email = ["ged@FaerieMUD.org"]
  s.extra_rdoc_files = ["History.rdoc", "Manifest.txt", "README.rdoc"]
  s.files = ["History.rdoc", "Manifest.txt", "README.rdoc"]
  s.homepage = "https://bitbucket.org/ged/sysexits"
  s.licenses = ["BSD"]
  s.rdoc_options = ["-f", "fivefish", "-t", "Sysexits"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = "sysexits"
  s.rubygems_version = "2.4.8"
  s.summary = "Have you ever wanted to call <code>exit()</code> with an error condition, but weren't sure what exit status to use? No? Maybe it's just me, then"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4.0"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.1.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.11"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.6"])
      s.add_development_dependency(%q<hoe>, ["~> 3.9"])
    else
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4.0"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.1.0"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<rspec>, ["~> 2.11"])
      s.add_dependency(%q<simplecov>, ["~> 0.6"])
      s.add_dependency(%q<hoe>, ["~> 3.9"])
    end
  else
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4.0"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.1.0"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<rspec>, ["~> 2.11"])
    s.add_dependency(%q<simplecov>, ["~> 0.6"])
    s.add_dependency(%q<hoe>, ["~> 3.9"])
  end
end
