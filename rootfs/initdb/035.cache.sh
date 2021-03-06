#!/bin/sh

# Set in parent script:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# . /start/stage2.functions
# VAR_*

writeSqlPrio35(){
   local prio="035"
   local dbname="$VAR_DATABASE"
   local sql_file="/initdb/$prio.$dbname.sql"
   >"$sql_file"
   local foreign_server_schema_tables=""
   local limitstr=""
   local ftable_schema=""
   local IFS=$(echo -en ",")
   for fschema in $VAR_FOREIGN_SERVER_SCHEMAS
   do
      fschema="$(trim "$fschema")"
      foreign_server_schema_tables=$(echo \$VAR_$fschema)
      if [ -n "$foreign_server_schema_tables" ]
      then 
         limitstr="LIMIT TO ($foreign_server_schema_tables)"
      fi
      ftable_schema=$fschema"_foreign"
      {
         echo "CREATE SCHEMA $ftable_schema AUTHORIZATION \"$VAR_LINUX_USER\";"
         echo "GRANT USAGE ON SCHEMA $ftable_schema TO \"$VAR_USER\";"
         echo "ALTER DEFAULT PRIVILEGES IN SCHEMA $ftable_schema GRANT SELECT ON TABLES TO \"$VAR_USER\";"
         echo "IMPORT FOREIGN SCHEMA \"$fschema\" $limitstr FROM SERVER \"$VAR_FOREIGN_SERVER_NAME\" INTO $ftable_schema;"
         echo "CREATE SCHEMA \"$fschema\" AUTHORIZATION \"$VAR_LINUX_USER\";"
         echo "GRANT USAGE ON SCHEMA \"$fschema\" TO \"$VAR_USER\";"
         echo "ALTER DEFAULT PRIVILEGES IN SCHEMA \"$fschema\" GRANT SELECT ON TABLES TO \"$VAR_USER\";"
      } >> "$sql_file"
   done
}

writeSqlPrio35
