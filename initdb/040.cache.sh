#!/bin/sh

# Set in parent script:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# readonly BIN_DIR="$(/usr/bin/dirname "$0")"
# . "$BIN_DIR/start.stage2.functions"
# readonly CONFIG_FILE="$(var - CONFIG_FILE)"
# readonly CONFIG_DIR="$(/usr/bin/dirname "$CONFIG_FILE")"
# readonly LINUX_USER="$(var - LINUX_USER)"
# readonly psql_cmd="/usr/bin/env -i $BIN_DIR/sudo -u $LINUX_USER $BIN_DIR/psql --variable=ON_ERROR_STOP=1 --username postgres"
# DATABASE FOREIGN_SERVER_SCHEMAS
# ---------------------------------------------------------

IFS_tmp=$IFS
IFS=$(echo -en " ")
prio="040"
dbname="$DATABASE"
sql_file="$CONFIG_DIR/initdb/$prio.$dbname.sql"
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
      echo "CREATE MATERIALIZED VIEW $fschema.$ftable AS SELECT * FROM $ftable_schema.$ftable WITH DATA;" >> "$sql_file"
   done
done
IFS=$IFS_tmp

