# frozen_string_literal: true

source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1", ">= 8.1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.6", ">= 1.6.3"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 8.0", ">= 8.0.1"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1", ">= 3.1.22"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable", "~> 3.0", ">= 3.0.12"
gem "solid_cache", "~> 1.0", ">= 1.0.10"
gem "solid_queue", "~> 1.4", ">= 1.4.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.24", ">= 1.24.4", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", "~> 2.11", ">= 2.11.0", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.14"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors", "~> 3.0"

# Agnostic pagination in plain ruby.
gem "pagy", "~> 43.5", ">= 43.5.4"

# Meilisearch integration for Ruby on Rails. See https://github.com/meilisearch/meilisearch
gem "meilisearch-rails", "~> 0.16", ">= 0.16.0"

# Generate beautiful API documentation
gem "rswag", "~> 2.17", ">= 2.17.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.11", ">= 1.11.1", require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", "~> 0.9.3", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "~> 8.0", ">= 8.0.4", require: false

  # rspec-rails integrates the Rails testing helpers into RSpec
  gem "rspec-rails", "~> 8.0", ">= 8.0.4"

  # factory_bot_rails provides integration between factory_bot and Rails
  gem "factory_bot_rails", "~> 6.5", ">= 6.5.1"

  # Faker, a port of Data::Faker from Perl, is used to easily generate fake data: names, addresses, phone numbers, etc.
  gem "faker", "~> 3.8", ">= 3.8.0"

  # Ruby code linter and formatter
  gem "rubocop",             "~> 1.86", ">= 1.86.2", require: false
  gem "rubocop-performance", "~> 1.26", ">= 1.26.1", require: false
  gem "rubocop-rails",       "~> 2.35", require: false
  gem "rubocop-rspec",       "~> 3.9",  ">= 3.9.0",  require: false
end
