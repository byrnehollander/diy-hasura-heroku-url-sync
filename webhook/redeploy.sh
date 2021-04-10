#!/bin/sh
URL=$(heroku config:get DATABASE_URL -a YOUR-HEROKU-APP-NAME)
PW=$(echo $URL | grep -Po "[a-zA-Z0-9]+?(?=@)")
echo "DATABASE_URI=$URL\nDATABASE_PASSWORD=$PW" > .env
docker-compose restart
