VAR=`curl http://localhost:3000/ 2>&1 >/dev/null`
if echo $VAR | grep -q 'Failed to connect'; then
  #kill -9 $(lsof -i tcp:3000 -t)
  cd /var/www/AI-talk-engine/preprocessor; ~/bin/bundle exec rails server -d
fi
