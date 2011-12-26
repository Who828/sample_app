source 'http://rubygems.org'

gem 'rails', '3.1.1'
gem 'gravatar_image_tag'
gem 'will_paginate'
gem 'heroku'

group :production do
  gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'prototype-rails'

group :development do
  gem 'rspec-rails'
  gem 'annotate', git:'git://github.com/ctran/annotate_models.git'
  gem 'faker'
end

group :test do
  gem 'rspec'
  gem 'spork'
  gem 'webrat'
  gem 'factory_girl_rails'
end
