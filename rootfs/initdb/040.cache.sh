#!/bin/sh

# Set in parent scripts:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# . /start/stage2.functions
# VAR_*
# readonly psql_cmd="/usr/bin/env -i $BIN_DIR/sudo -u $LINUX_USER $BIN_DIR/psql --variable=ON_ERROR_STOP=1 --username postgres"

prio="040"
dbname="$VAR_DATABASE"
sql_file="/initdb/$prio.$dbname.sql"
>"$sql_file"
IFS=$(echo -en ",")
for fschema in $VAR_FOREIGN_SERVER_SCHEMAS
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

