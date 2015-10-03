$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bling/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bling-api-rails"
  s.version     = Bling::VERSION
  s.authors     = ["Ariel Schvartz"]
  s.email       = ["ari.shh@gmail.com"]
  s.homepage    = "https://github.com/arielschvartz"
  s.summary     = "Integration to Bling API"
  s.description = "Make calls to Bling API"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", ">= 3.1"
  s.add_dependency "httparty"

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'dotenv-rails'
  s.add_development_dependency 'pry-rails'
end
