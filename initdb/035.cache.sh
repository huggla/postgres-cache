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
