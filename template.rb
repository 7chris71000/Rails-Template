=begin
Please follow repository's README.md to use this template
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def setup_gems
  say "Setting up Gems", :blue

  gem "deployem"
  gem "rabl"
  gem "gon"
  gem "resque", require: "resque/server"
  gem "font-awesome-rails"
  gem "aws-sdk-s3", "~> 1"

  gem_group :development do
    gem "pry"
    gem "letter_opener"
  end

  gem_group :development, :test do
    gem "faker"
    gem "dotenv-rails"
  end

  inject_into_file "Gemfile", "#ruby-gemset=#{@app_path}"
end

def setup_gemset
  say "Setting up gemset", :blue

  setup_gems

  say "Running bundler", :blue
  run "gem install bundler"
end

def create_env
  file ".env"
  file ".env.tmpl"
end

def setup_devise
  say "Setting up Devise", :blue
  inject_into_file "./Gemfile", "gem 'devise'\n", before: "#ruby-gemset=#{@app_path}"
  run "bundle install"

  generate "devise:install"
  environment 'config.action_mailer.default_url_options = { host: \'localhost\', port: 3000 }', env: "development"
  # maybe ask if they want to setup the production.rb
  generate :devise, "User"
  rails_command "db:migrate"
end

def setup_cancancan
  say "Setting up CanCanCan", :blue
  inject_into_file "./Gemfile", "gem 'cancancan'\n", before: "#ruby-gemset=#{@app_path}"
  run "bundle install"

  generate "cancan:ability"

  admin_method = <<~RUBY
    def admin?
      self.has_role? :admin
    end
  RUBY
  
  insert_into_file "app/models/user.rb", "\n#{admin_method}", :before => /^end/
end

def setup_rolify
  say "Setting up Rolify", :blue
  inject_into_file "./Gemfile", "gem 'rolify'\n", before: "#ruby-gemset=#{@app_path}"
  run "bundle install"

  generate :rolify, "Role", "User"
  rails_command "db:migrate"

  sessions_helper = <<~RUBY
    module SessionsHelper
      def admin?
        current_user && current_user.admin?
      end
    end
  RUBY
  
  file 'app/helpers/sessions_helper.rb', sessions_helper
  
  inject_into_file "app/controllers/application_controller.rb", "\n  include SessionsHelper", after: /^class ApplicationController < ActionController::Base/

end

def setup_spire
  say "Setting up Spire Gem", :blue
  # using inject_into_file so I can specify where in the gemfile this line should be added
  inject_into_file "./Gemfile", "gem 'spire', git: 'https://github.com/bitesite/spire-ruby'\n", before: "#ruby-gemset=#{@app_path}"
  
  spire_config = <<~RUBY
    Spire.configure do |config|
      config.company = ENV["SPIRE_COMPANY"]
      config.username = ENV["SPIRE_USERNAME"]
      config.password = ENV["SPIRE_PASSWORD"]
      config.host = ENV["SPIRE_HOST"]
      config.port = ENV["SPIRE_PORT"]
    end
  RUBY

  file "config/initializers/spire.rb", spire_config

  if yes?("\nDo you have the Spire configuration variables?")
    spire_company = ask("Spire Company:")
    spire_host = ask("Spire Host:")
    spire_port = ask("Spire Port:")
    spire_username = ask("Spire Username:")
    spire_password = ask("Spire Password:")
  
    spire_env_vars = <<~EOF
      SPIRE_COMPANY=#{spire_company}
      SPIRE_HOST=#{spire_host}
      SPIRE_PORT=#{spire_port}
      SPIRE_USERNAME=#{spire_username}
      SPIRE_PASSWORD=#{spire_password}
    EOF
  
    inject_into_file ".env", spire_env_vars
  end

  spire_env_vars = <<~EOF
    SPIRE_COMPANY=
    SPIRE_HOST=
    SPIRE_PORT=
    SPIRE_USERNAME=
    SPIRE_PASSWORD=
  EOF

  inject_into_file ".env.tmpl", spire_env_vars

  run "bundle install"
end

def setup_git_ignore
  insert_into_file ".gitignore", <<~EOF
    .env
    .env.tmpl
  EOF
end

def setup_rspec
  say "Setting up RSpec", :blue
  gem_group :development, :test do
    gem "rspec-rails"
    gem "factory_bot_rails"
  end

  run "bundle install"

  generate "rspec:install"

  # delete views
  run "rm -rf spec/views"
  # delete requests
  run "rm -rf spec/requests"
  # delete helpers
  run "rm -rf spec/helpers"
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
  say "Generating Pages Controller", :blue
  generate(:controller, "Pages", "home")
  route 'root to: \'pages#home\''
end

def setup_heroku
  say "Setting up heroku", :blue
  
  apply "heroku_setup.rb"
end

def remove_unnecessary_files
  say "Removing Unnecessary Files.", :blue
  run "rm .ruby-version"
end

def get_source_control_info
  # ask user if they would like to push to their source control, if so get their url
  @source_control_remote = ask "Please provide your repository link (eg: git@github.com:<YOUR NAME>/<REPO NAME>.git)"
end

def stop_spring
  # This fixes the hanging controller generation call
  run "spring stop"
end

def force_ssl
  gsub_file "config/environments/production.rb", /# config.force_ssl = true/, "config.force_ssl = true"
end

# Main
source_paths

# setup_gems
setup_gemset

after_bundle do
  stop_spring
  
  setup_react
  setup_controllers
  create_env

  setup_db

  if yes?("\nWould you like to test this project using RSpec?")
    setup_rspec
  end

  if yes?("\nWill this project require Devise?")
    setup_devise
  end

  if yes?("\nWill this project require Cancancan?")
    setup_cancancan
  end

  if yes?("\nWill this project require Rolify?")
    setup_rolify
  end

  if yes?("\nWould you like to force SSL in production?")
    force_ssl
  end

  if yes?("\nWill this project be integrated with Spire?")
    setup_spire
    setup_git_ignore
  end

  remove_unnecessary_files

  if yes?("\nWould you like to create an inital commit?")
    git :init
    git add: '.'
    git commit: '-a -m \'Initial commit\''

    if yes?("\nWould you like to push this initial commit to your GitHub/BitBucket/GitLab/etc?")
      get_source_control_info
      git remote: "add origin #{@source_control_remote}"
      git push: "-u origin main"
    end
  end

  if yes?("\nWould you like to setup heroku?")
    setup_heroku
  end

  say "#{@app_path} successfully created! 😀", :blue

  say "\n\nSwitch to your app by running:"
  say "$ cd #{@app_path}", :blue
end
