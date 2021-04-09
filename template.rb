=begin
Template Title: Generic Rails/React User App
Author: Christopher Francis
Run Command: $ rails new <APPNAME> -m <THIS TEMPLATE SRC>

This template uses rvm to create and setup a new rails project. It will use the system default ruby version.

Note: use a ~/.railsrc to set your flags. See more here https://samuelmullen.com/articles/configuring_new_rails_projects_with_railsrc_and_templates/#railsrc
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def setup_gems
  say "Setting up Gems", :blue

  gem 'devise'
  gem 'cancancan'
  gem 'rolify'
  gem 'deployem'
  gem 'rabl'
  gem 'gon'
  gem 'resque', require: 'resque/server'
  gem 'font-awesome-rails'
  gem 'spire', git: 'https://github.com/bitesite/spire-ruby'
  gem 'aws-sdk-s3', '~> 1'
  
  gem_group :development do
    gem 'pry'
  end
  
  gem_group :development, :test do
    gem 'rspec-rails', '~> 5.0.0'
    gem 'factory_bot_rails'
    gem 'faker'
  end
  
  # This used to work then it didnt... ¯\_(ツ)_/¯
  # insert_into_file 'Gemfile', "#ruby-gemset=#{@app_path}"
end

def setup_gemset
  say "Setting up gemset", :blue

  rvm_list = `rvm list`.gsub(Regexp.new("\e\\[.?.?.?m"), "")
  desired_ruby = rvm_list.match(/=\* (ruby[^ ]+)|=> (ruby[^ ]+)/)[1]
  require 'pry'; binding.pry

  # Create the gemset
  run "rvm #{desired_ruby} gemset create #{@app_path}"
  @rvm = "rvm use #{desired_ruby}@#{@app_path}"
  run "#{@rvm} gem install bundler"
end

def setup_devise
  say "Setting up Devise", :blue
  generate 'devise:install'
  environment 'config.action_mailer.default_url_options = { host: \'localhost\', port: 3000 }', env: 'development'
  # maybe ask if they want to setup the production.rb
  generate :devise, 'User'
end

def setup_cancancan
  say "Setting up CanCanCan", :blue
  generate 'cancan:ability'
end

def setup_rolify
  say "Setting up Rolify", :blue
  generate :rolify, 'Role', 'User'
end

def setup_rspec
  say "Setting up RSpec", :blue
  # second iteration
end

def setup_db
  say "Setting up database", :blue
  rails_command 'db:create'
  rails_command 'db:migrate'
end

def setup_react
  say "Adding components folder for React", :blue
  in_root do
    run 'mkdir app/javascript/components'
  end
end

def setup_controllers
  say "Generating Pages Controller", :blue
  generate(:controller, 'Pages', 'home')
  route 'root to: \'pages#home\''
end

def remove_unnecessary_files
  run 'rm .ruby-version'
  run 'rm app/javascript/packs/hello_react.jsx'
  
end

def get_source_control_repo_name
  # ask user if they would like to push to their source control, if so get their url
  ask "Please provide your repository link (eg: git@github.com:<YOUR NAME>/<REPO NAME>.git)"
end

# Main
source_paths

setup_gems
setup_gemset


after_bundle do
  setup_react
  setup_controllers
  
  if yes?("\nWill this project require Devise?")
    setup_devise
  end

  if yes?("\nWill this project require Cancancan?")
    setup_cancancan
  end

  if yes?("\nWill this project require Rolify?")
    setup_rolify
  end

  if yes?("Would you like to test this project using RSpec?")
    setup_devise
    setup_rspec
  end
  
  setup_db

  remove_unnecessary_files
  
  # git :init
  # git add: '.'
  # git commit: '-a -m \'Initial commit\''
  
  # if yes?("Would you like to push this initial commit to your GitHub/BitBucket/GitLab/etc?")
  #   git remote: "add origin #{get_source_control_repo_name}"
  # end
  
  run "cd #{@app_name}"
  say "#{@app_name} successfully created! 😀", :blue
end

