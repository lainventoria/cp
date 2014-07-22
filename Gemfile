source 'https://rubygems.org'

gem 'rails', '4.1.4'

gem 'money-rails'
# normaliza con varios métodos la entrada de usuario
gem 'attribute_normalizer'
gem 'paperclip'
# fork con pull requests para rails 4.1 mergeados
gem 'state_machine', github: 'lainventoria/state_machine'

# permite importar y exportar datos en formato yml
gem 'yaml_db', github: 'mauriciopasquier/yaml_db'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Assets/GUI
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'turbolinks'
# selector de fechas con calendario mensual
gem 'bootstrap-datepicker-rails'
# error messages
gem 'dynamic_form'
# autocomplete en formularios
gem 'rails3-jquery-autocomplete'
gem 'jquery-ui-rails'
gem 'jquery-ui-themes'
# selector de archivos bootstrapeado
gem 'bootstrap-filestyle-rails'
gem 'therubyracer'

# I18n
gem 'rails-i18n'
gem 'inflections', '0.0.5', require: 'inflections/es'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'spring'
  # Deploy con capistrano
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
end

group :development, :test do
  gem 'pry-rails'
  gem 'hirb'
  # Usar fábricas en vez de fixtures
  gem 'factory_girl_rails'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :production do
  gem 'mysql2'
end

group :test do
  # Para limpiar la base de datos después de cada test
  gem 'database_cleaner'
end
