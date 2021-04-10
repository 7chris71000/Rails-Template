=begin
Please follow repository's README.md to use this template
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def setup_gems
  say "Setting up Gems", :blue

  gem "devise"
  gem "cancancan"
  gem "rolify"
  gem "deployem"
  gem "rabl"
  gem "gon"
  gem "resque", require: "resque/server"
  gem "font-awesome-rails"
  gem "spire", git: "https://github.com/bitesite/spire-ruby"
  gem "aws-sdk-s3", "~> 1"

  gem_group :development do
    gem "pry"
  end

  gem_group :development, :test do
    gem "rspec-rails", "~> 5.0.0"
    gem "factory_bot_rails"
    gem "faker"
  end

  # This only sometimes works... ¯\_(ツ)_/¯
  insert_into_file "Gemfile", "#ruby-gemset=#{@app_path}"
end

def setup_gemset
  say "Setting up gemset", :blue

  setup_gems

  say "Running bundler", :blue
  run "gem install bundler"
end

def setup_devise
  say "Setting up Devise", :blue
  generate "devise:install"
  environment 'config.action_mailer.default_url_options = { host: \'localhost\', port: 3000 }', env: "development"
  # maybe ask if they want to setup the production.rb
  generate :devise, "User"
  rails_command "db:migrate"
end

def setup_cancancan
  say "Setting up CanCanCan", :blue
  generate "cancan:ability"
end

def setup_rolify
  say "Setting up Rolify", :blue
  generate :rolify, "Role", "User"
  rails_command "db:migrate"
end

def setup_rspec
  say "Setting up RSpec", :blue
  # second iteration
end

def setup_heroku
  say "Setting up heroku", :blue
  # second iteration
end

def setup_db
  say "Setting up database", :blue
  rails_command "db:create"
  rails_command "db:migrate"
end

def setup_react
  say "Adding components folder for React", :blue
  in_root do
    run "mkdir app/javascript/components"
  end
end

def setup_controllers
  # Sometimes hangs here and doesnt go further
  say "Generating Pages Controller", :blue
  generate(:controller, "Pages", "home")
  route 'root to: \'pages#home\''
end

def remove_unnecessary_files
  run "rm .ruby-version"
  run "rm app/javascript/packs/hello_react.jsx"
end

def get_source_control_repo_name
  # ask user if they would like to push to their source control, if so get their url
  ask "Please provide your repository link (eg: git@github.com:<YOUR NAME>/<REPO NAME>.git)"
end

# Main
source_paths

# setup_gems
setup_gemset

after_bundle do
  setup_react
  setup_controllers

  setup_db

  if yes?("\nWill this project require Devise?")
    setup_devise
  end

  if yes?("\nWill this project require Cancancan?")
    setup_cancancan
  end

  if yes?("\nWill this project require Rolify?")
    setup_rolify
  end

  if yes?("\nWould you like to test this project using RSpec?")
    setup_rspec
  end

  remove_unnecessary_files

  if yes?("\nWould you like to create an inital commit?")
    git :init
    git add: '.'
    git commit: '-a -m \'Initial commit\''

    if yes?("\nWould you like to push this initial commit to your GitHub/BitBucket/GitLab/etc?")
      git remote: "add origin #{get_source_control_repo_name}"
    end
  end

  if yes?("\nWould you like to setup heroku?")
    setup_heroku
  end

  run "cd #{@app_path}"
  say "#{@app_path} successfully created! 😀", :blue
end
