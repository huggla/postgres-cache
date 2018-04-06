#!/bin/sh

# Set in parent script:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# readonly BIN_DIR="$(/usr/bin/dirname "$0")"
# . "$BIN_DIR/start.stage2.functions"
# readonly NAME="$(var - NAME)"
# readonly CONFIG_FILE="$(var - CONFIG_FILE)"
# readonly CONFIG_DIR="$(/usr/bin/dirname "$CONFIG_FILE")"
# readonly sql_dir="$CONFIG_DIR/initdb/sql"
# readonly psql_cmd="/usr/bin/env -i $BIN_DIR/sudo -u $NAME $BIN_DIR/psql --variable=ON_ERROR_STOP=1 --username postgres"
# ---------------------------------------------------------

IFS_tmp=$IFS
IFS=$(echo -en " ")
vars="USER DATABASE USER_PASSWORD_FILE FOREIGN_SERVER_USER FOREIGN_SERVER_USER_PASSWORD_FILE FOREIGN_SERVER_NAME FOREIGN_SERVER_ADDRESS FOREIGN_SERVER_DATABASE FOREIGN_SERVER_PORT"
for var in $vars
do
   eval "readonly $var=\"$(var - $var)\""
done
password_vars="USER_PASSWORD FOREIGN_SERVER_USER_PASSWORD"
for var in $password_vars
do
   eval "password_file_value=\$$var_FILE"
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
sql_file="$sql_dir/$prio.$dbname.sql"
echo "CREATE USER \"$USER\" WITH LOGIN NOINHERIT VALID UNTIL 'infinity' PASSWORD '$USER_PASSWORD';" > "$sql_file"
echo "CREATE DATABASE \"$DATABASE\" WITH OWNER = \"postgres\";" >> "$sql_file"

# TEMPLATE=template_postgis;

echo "CREATE EXTENSION postgres_fdw;" >> "$sql_file"
echo "CREATE SERVER \"$FOREIGN_SERVER_NAME\" FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$FOREIGN_SERVER_ADDRESS', dbname '$FOREIGN_SERVER_DATABASE', port '$FOREIGN_SERVER_PORT');" >> "$sql_file"
echo "ALTER SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (ADD updatable 'false');" >> "$sql_file"
echo "CREATE USER MAPPING FOR \"$USER\" SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');" >> "$sql_file"
echo "CREATE USER MAPPING FOR \"postgres\" SERVER \"$FOREIGN_SERVER_NAME\" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');" >> "$sql_file"
prio="110"
dbname="$DATABASE"
sql_file="$sql_dir/$prio.$dbname.sql"
>"$sql_file"
IFS=$(echo -en ",")
for fschema in $FOREIGN_SERVER_SCHEMAS
do
   fschema="$(trim "$fschema")"
   foreign_server_schema_tables="$(var - $fschema)"
   if [ -n "$foreign_server_schema_tables" ]
   then 
      limitstr="LIMIT TO ($foreign_server_schema_tables)"
   else
      limitstr=""
   fi
   ftable_schema=$fschema"_foreign"
   echo "CREATE SCHEMA $ftable_schema AUTHORIZATION \"postgres\";" >> "$sql_file"
   echo "GRANT USAGE ON SCHEMA $ftable_schema TO \"$USER\";" >> "$sql_file"
   echo "ALTER DEFAULT PRIVILEGES IN SCHEMA $ftable_schema GRANT SELECT ON TABLES TO \"$USER\";" >> "$sql_file"
   echo "IMPORT FOREIGN SCHEMA \"$fschema\" $limitstr FROM SERVER \"$FOREIGN_SERVER_NAME\" INTO $ftable_schema;" >> "$sql_file"
   echo "CREATE SCHEMA \"$fschema\" AUTHORIZATION \"postgres\";" >> "$sql_file"
   echo "GRANT USAGE ON SCHEMA \"$fschema\" TO \"$USER\";" >> "$sql_file"
   echo "ALTER DEFAULT PRIVILEGES IN SCHEMA \"$fschema\" GRANT SELECT ON TABLES TO \"$USER\";" >> "$sql_file"
   if [ -z "$foreign_server_schema_tables" ]
   then
      foreign_server_schema_tables="$("$psql_cmd" -q -A -t -R , --dbname="$DATABASE" -c "SELECT table_name FROM information_schema.tables WHERE table_schema='$ftable_schema'")"
   fi   
   for ftable in $foreign_server_schema_tables
   do
      "$psql_cmd" --dbname="$DATABASE" -c "CREATE MATERIALIZED VIEW $fschema.$ftable AS SELECT * FROM $ftable_schema.$ftable WITH DATA;"
   done
done
IFS=$IFS_tmp
eval $ADDITIONAL_CONFIGURATION
