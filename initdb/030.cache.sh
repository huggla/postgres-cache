#!/bin/sh

# Set in parent script:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# readonly BIN_DIR="$(/usr/bin/dirname "$0")"
# . "$BIN_DIR/start.stage2.functions"
# readonly CONFIG_FILE="$(var - CONFIG_FILE)"
# readonly CONFIG_DIR="$(/usr/bin/dirname "$CONFIG_FILE")"
# ---------------------------------------------------------


if [ -n "$TEMPLATE" ]
then
   template_string="TEMPLATE=$TEMPLATE"
fi
prio="030"
dbname="postgres"
sql_file="/initdb/$prio.$dbname.sql"
{
   echo "CREATE USER \"$USER\" WITH LOGIN NOINHERIT VALID UNTIL 'infinity' PASSWORD '$USER_PASSWORD';"
   echo "CREATE DATABASE \"$DATABASE\" WITH OWNER = \"postgres\" $template_string;"
} > "$sql_file"
prio="031"
dbname="$DATABASE"
sql_file="$CONFIG_DIR/initdb/$prio.$dbname.sql"
{
   echo "CREATE EXTENSION postgres_fdw;"
   echo "CREATE SERVER \"$FOREIGN_SERVER_NAME\" FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$FOREIGN_SERVER_ADDRESS', dbname '$FOREIGN_SERVER_DATABASE', port '$FOREIGN_SERVER_PORT');"
   echo "ALTER SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (ADD updatable 'false');"
   echo "CREATE USER MAPPING FOR \"$USER\" SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');"
   echo "CREATE USER MAPPING FOR \"postgres\" SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');"
} > "$sql_file"
IFS=$IFS_tmp
