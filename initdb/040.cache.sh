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
vars="DATABASE FOREIGN_SERVER_SCHEMAS"
for var in $vars
do
   eval "readonly $var=\"$(var - $var)\""
done
prio="40"
dbname="$DATABASE"
sql_file="$BIN_DIR/initdb/$prio.$dbname.sql"
>"$sql_file"
IFS=$(echo -en ",")
for fschema in $FOREIGN_SERVER_SCHEMAS
do
   fschema="$(trim "$fschema")"
   foreign_server_schema_tables="$(var - $fschema)"
   ftable_schema=$fschema"_foreign"
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

