#!/bin/sh

# Set in parent script:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# . /start/stage2.functions
# VAR_*

IFS_tmp=$IFS
IFS=$(echo -en " ")
FOREIGN_SERVER_SCHEMAS="$(var - FOREIGN_SERVER_SCHEMAS)"
prio="035"
dbname="$DATABASE"
sql_file="$CONFIG_DIR/initdb/$prio.$dbname.sql"
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
   {
      echo "CREATE SCHEMA $ftable_schema AUTHORIZATION \"postgres\";"
      echo "GRANT USAGE ON SCHEMA $ftable_schema TO \"$USER\";"
      echo "ALTER DEFAULT PRIVILEGES IN SCHEMA $ftable_schema GRANT SELECT ON TABLES TO \"$USER\";"
      echo "IMPORT FOREIGN SCHEMA \"$fschema\" $limitstr FROM SERVER \"$FOREIGN_SERVER_NAME\" INTO $ftable_schema;"
      echo "CREATE SCHEMA \"$fschema\" AUTHORIZATION \"postgres\";"
      echo "GRANT USAGE ON SCHEMA \"$fschema\" TO \"$USER\";"
      echo "ALTER DEFAULT PRIVILEGES IN SCHEMA \"$fschema\" GRANT SELECT ON TABLES TO \"$USER\";"
   } >> "$sql_file"
done
IFS=$IFS_tmp
