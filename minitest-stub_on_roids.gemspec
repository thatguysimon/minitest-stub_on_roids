# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "minitest-stub_on_roids"
  s.version     = "0.0.4"
  s.date        = "2019-08-05"
  s.summary     = "Minitest's #stub but on steroids"
  s.description = "A set of helper methods based around Minitest's Object#stub method."
  s.authors     = ["Simon Nizov"]
  s.email       = "simon.nizov@gmail.com"
  s.files       = Dir["{lib/**/*,[A-Z]*}"]
  s.homepage    = "https://github.com/thatguysimon/minitest-stub_on_roids"
  s.license     = "MIT"

  s.add_runtime_dependency "minitest", ">= 5.0"

  s.add_development_dependency "minitest-reporters", ">= 1.4.0"
  s.add_development_dependency "rubocop", "~> 0.74.0"
  s.add_development_dependency "bundler", ">= 2.0.0"
  s.add_development_dependency "rake", ">= 13.0.0"
  s.add_development_dependency "byebug"
end
