# template to setup heroku with a new app using heroku-cli

# use `template template_name.rb`

def get_heroku_cli_location
  run("which heroku", capture: true)
end

def get_heroku_user
  run("heroku auth:whoami", capture: true)
end

def get_heroku_app_name(app_type)
  say "\nNote: The following name must start with a letter, end with a letter or digit and can only contain lowercase letters, digits, and dashes.", :yellow
  ask "Please provide the app name for #{app_type}:"
end

def setup_heroku
  say "\nCreating staging", :yellow
  @staging_app_name = get_heroku_app_name("staging")
  create_heroku_app(@staging_app_name, "staging")

  say "\nCreating production", :yellow
  @production_app_name = get_heroku_app_name("production")
  create_heroku_app(@production_app_name, "production")
end

def create_heroku_app(app_name, app_type)
  while true
    result = run("heroku create #{app_name}", capture: true)

    if result.include?("Creating #{app_name}... done")
      break
    else
      say "Error while creating staging on heroku: #{result}", :red

      app_name = get_heroku_app_name(app_type)
      if app_type == "staging"
        @staging_app_name = app_name
      elsif app_type == "production"
        @production_app_name = app_name
      end
    end
  end
end

#MAIN
@staging_app_name = ""
@production_app_name = ""

if get_heroku_cli_location == ""
  say "Heroku CLI not found. Please install here: https://devcenter.heroku.com/articles/heroku-cli", :red
  return
end

while get_heroku_user.include?("Error")
  # not logged in
  run "heroku login -i"
end

say "User: #{get_heroku_user.chop} logged in. Using this account to create the heroku app.", :blue

# logged in
setup_heroku

say "Successfully created heroku apps: \n\t#{@staging_app_name}\n\t#{@production_app_name}.", :blue
