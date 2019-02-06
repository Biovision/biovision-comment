$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "biovision/comment/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "biovision-comment"
  s.version     = Biovision::Comment::VERSION
  s.authors     = ["Maxim Khan-Magomedov"]
  s.email       = ["maxim.km@gmail.com"]
  s.homepage    = "https://github.com/Biovision/biovision-comment"
  s.summary     = "Commenting for biovision-based applications"
  s.description = "Commenting for biovision-based applications"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '~> 5.1'
  s.add_dependency 'rails-i18n', '~> 5.0'

  s.add_dependency 'biovision-base'
  s.add_dependency 'kaminari'

  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
end