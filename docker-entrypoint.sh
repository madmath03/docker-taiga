#!/bin/sh

# Sleep when asked to, to allow the database time to start
# before Taiga tries to run /checkdb.py below.
: ${TAIGA_SLEEP:=0}
sleep $TAIGA_SLEEP

# Setup database automatically if needed
if [ -z "$TAIGA_SKIP_DB_CHECK" ]; then
  echo "Running database check"
  python /checkdb.py
  DB_CHECK_STATUS=$?

  if [ $DB_CHECK_STATUS -eq 1 ]; then
    echo "Failed to connect to database server or database does not exist."
    exit 1
  fi

  # Database migration check should be done in all startup in case of backend upgrade
  echo "Check for database migration"
  python manage.py migrate --noinput

  if [ $DB_CHECK_STATUS -eq 2 ]; then
    echo "Configuring initial database"
    python manage.py loaddata initial_user
    python manage.py loaddata initial_project_templates
    python manage.py loaddata initial_role
  fi
fi

# In case of frontend upgrade, locales and statics should be regenerated
python manage.py compilemessages
python manage.py collectstatic --noinput

# Automatically replace "TAIGA_HOSTNAME" with the environment variable
sed -ri "s#(\"api\": \"http://).*(/api/v1/\",)#\1$TAIGA_HOSTNAME\2#g" /taiga/conf.json
ln -s /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga

# Look to see if we should set the "eventsUrl"
if [ ! -z "$RABBIT_PORT_5672_TCP_ADDR" ]; then
  echo "Enabling Taiga Events"
  sed -i "s/eventsUrl\": null/eventsUrl\": \"ws:\/\/$TAIGA_HOSTNAME\/events\"/g" /taiga/conf.json
  rm /etc/nginx/sites-enabled/taiga
  ln -s /etc/nginx/sites-available/taiga-events /etc/nginx/sites-enabled/taiga-events
fi

# Handle enabling/disabling SSL
if [ "$TAIGA_SSL_BY_REVERSE_PROXY" = "True" ]; then
  echo "Enabling external SSL support! SSL handling must be done by a reverse proxy or a similar system"
  sed -i "s/http:\/\//https:\/\//g" /taiga/conf.json
  sed -i "s/ws:\/\//wss:\/\//g" /taiga/conf.json
  rm /etc/nginx/sites-enabled/taiga
  ln -s /etc/nginx/sites-available/taiga-ssl /etc/nginx/sites-enabled/taiga-ssl
elif [ "$TAIGA_SSL" = "True" ]; then
  echo "Enabling SSL support!"
  sed -i "s/http:\/\//https:\/\//g" /taiga/conf.json
  sed -i "s/ws:\/\//wss:\/\//g" /taiga/conf.json
  rm /etc/nginx/sites-enabled/taiga
  ln -s /etc/nginx/sites-available/taiga-ssl /etc/nginx/sites-enabled/taiga-ssl
elif grep -q "wss://" "/taiga/conf.json"; then
  echo "Disabling SSL support!"
  sed -i "s/https:\/\//http:\/\//g" /taiga/conf.json
  sed -i "s/wss:\/\//ws:\/\//g" /taiga/conf.json
fi

# Start nginx service (need to start it as background process)
nginx

# Start gunicorn  server
exec "$@"
