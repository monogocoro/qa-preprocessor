#!/usr/bin/env bash
git pull origin master
bundle install
bundle exec rake db:migrate
bundle exec rake assets:precompile
bundle exec rake assets:clean
kill -9 $(lsof -i tcp:3000 -t)
bundle exec rails server -d
