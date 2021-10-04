# Encoding: UTF-8

Gem::Specification.new do |s|
  s.name              = %q{refinerycms-news}
  s.version           = %q{4.0.0}
  s.description       = %q{A really straightforward open source Ruby on Rails news engine designed for integration with Refinery CMS.}
  s.date              = "2021-10-04"
  s.summary           = %q{Ruby on Rails news engine for Refinery CMS.}
  s.email             = %q{info@refinerycms.com}
  s.homepage          = %q{http://refinerycms.com}
  s.authors           = ["Philip Arndt", "Uģis Ozols"]
  s.require_paths     = %w(lib)

  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- spec/*`.split("\n")

  s.add_dependency    'refinerycms-core',     '~> 4.0.0'
  s.add_dependency    'refinerycms-settings', '~> 4.0.0'
  s.add_dependency    'friendly_id',          '~> 5.1'
end
