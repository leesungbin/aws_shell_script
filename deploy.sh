#!/bin/bash
sudo -u $myappuser -H sh -c '
rvm use ruby-$ruby_version

cd /var/www/myapp/code
bundle install --deployment --without development test
printf "\tadapter: sqlite3" >> config/database.yml
sudo sed -i "22s/  secret_key_base: <%=ENV["SECRET_KEY_BASE"]%>//" config/secrets.yml
bundle exec rake secret >> config/secrets.yml

chmod 700 config debchmod 600 config/database.yml config/secrets.yml
bundle exec rake assets:precompile db:migrate RAILS_ENV=production
'
#3.1.....