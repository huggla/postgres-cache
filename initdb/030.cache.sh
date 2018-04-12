#!/bin/sh

# Set in parent script:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# readonly BIN_DIR="$(/usr/bin/dirname "$0")"
# . "$BIN_DIR/start.stage2.functions"
# readonly NAME="$(var - NAME)"
# readonly CONFIG_FILE="$(var - CONFIG_FILE)"
# readonly CONFIG_DIR="$(/usr/bin/dirname "$CONFIG_FILE")"
# readonly psql_cmd="/usr/bin/env -i $BIN_DIR/sudo -u $NAME $BIN_DIR/psql --variable=ON_ERROR_STOP=1 --username postgres"
# ---------------------------------------------------------

IFS_tmp=$IFS
IFS=$(echo -en " ")
vars="USER DATABASE USER_PASSWORD_FILE FOREIGN_SERVER_USER FOREIGN_SERVER_USER_PASSWORD_FILE FOREIGN_SERVER_NAME FOREIGN_SERVER_ADDRESS FOREIGN_SERVER_DATABASE FOREIGN_SERVER_PORT FOREIGN_SERVER_SCHEMAS"
for var in $vars
do
   eval "readonly $var=\"$(var - $var)\""
done
password_vars="USER_PASSWORD FOREIGN_SERVER_USER_PASSWORD"
for var in $password_vars
do
   eval "password_file_value=\$$var""_FILE"
   if [ -n "$password_file_value" ]
   then
      eval "read $var < \"$password_file_value\""
   else
      eval "$var=\"$(var - $var)\""
   fi
   eval "readonly $var"
done
prio="030"
dbname="postgres"
sql_file="$BIN_DIR/initdb/$prio.$dbname.sql"
{
   echo "CREATE USER \"$USER\" WITH LOGIN NOINHERIT VALID UNTIL 'infinity' PASSWORD '$USER_PASSWORD';"
   echo "CREATE DATABASE \"$DATABASE\" WITH OWNER = \"postgres\";"
   echo "CREATE EXTENSION postgres_fdw;"
   echo "CREATE SERVER \"$FOREIGN_SERVER_NAME\" FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$FOREIGN_SERVER_ADDRESS', dbname '$FOREIGN_SERVER_DATABASE', port '$FOREIGN_SERVER_PORT');"
   echo "ALTER SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (ADD updatable 'false');"
   echo "CREATE USER MAPPING FOR \"$USER\" SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');"
   echo "CREATE USER MAPPING FOR \"postgres\" SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');"
} > "$sql_file"