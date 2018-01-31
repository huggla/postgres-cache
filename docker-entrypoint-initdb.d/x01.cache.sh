#!/bin/bash
set -e

if [ -n "$USER_PASSWORD_FILE" ]
then
   read USER_PASSWORD < "$USER_PASSWORD_FILE"
fi

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
   CREATE USER "$USER" WITH LOGIN NOINHERIT VALID UNTIL 'infinity' PASSWORD '$USER_PASSWORD';
   CREATE DATABASE "$DATABASE" WITH OWNER = "$POSTGRES_USER" TEMPLATE=template_postgis;
EOSQL

if [ -n "$FOREIGN_SERVER_USER_PASSWORD_FILE" ]
then
   read FOREIGN_SERVER_USER_PASSWORD < "$FOREIGN_SERVER_USER_PASSWORD_FILE"
fi

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "$DATABASE" <<-EOSQL
    CREATE EXTENSION postgres_fdw;
    CREATE SERVER "$FOREIGN_SERVER_NAME" FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$FOREIGN_SERVER_ADDRESS', dbname '$FOREIGN_SERVER_DATABASE', port '$FOREIGN_SERVER_PORT');
    ALTER SERVER "$FOREIGN_SERVER_NAME" OPTIONS (ADD updatable 'false');
    CREATE USER MAPPING FOR "$USER" SERVER "$FOREIGN_SERVER_NAME" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');
    CREATE USER MAPPING FOR "$POSTGRES_USER" SERVER "$FOREIGN_SERVER_NAME" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');
EOSQL

IFS=, read -ra fschemas_array <<< "$FOREIGN_SERVER_SCHEMAS"
for fschema in "${fschemas_array[@]}"
do
   eval 'foreign_server_schema_tables=$'"$fschema"
   if [ -n "$foreign_server_schema_tables" ]
   then 
      limitstr="LIMIT TO ($foreign_server_schema_tables)"
   else
      limitstr=""
   fi
   ftable_schema=$fschema"_foreign"
   psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "$DATABASE" <<-___EOSQL
      CREATE SCHEMA $ftable_schema AUTHORIZATION "$POSTGRES_USER";
      GRANT USAGE ON SCHEMA $ftable_schema TO "$USER";
      ALTER DEFAULT PRIVILEGES IN SCHEMA $ftable_schema GRANT SELECT ON TABLES TO "$USER";
      IMPORT FOREIGN SCHEMA "$fschema" $limitstr FROM SERVER "$FOREIGN_SERVER_NAME" INTO $ftable_schema;
      CREATE SCHEMA "$fschema" AUTHORIZATION "$POSTGRES_USER";
      GRANT USAGE ON SCHEMA "$fschema" TO "$USER";
      ALTER DEFAULT PRIVILEGES IN SCHEMA "$fschema" GRANT SELECT ON TABLES TO "$USER";
___EOSQL
   if [ -z "$foreign_server_schema_tables" ]
   then
      foreign_server_schema_tables=`psql -q -A -t -R , -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "$DATABASE" -c "SELECT table_name FROM information_schema.tables WHERE table_schema='$ftable_schema'"`
   fi   
   IFS=, read -ra ftables_array <<< "$foreign_server_schema_tables"
   for ftable in "${ftables_array[@]}"
   do
      psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "$DATABASE" -c "CREATE MATERIALIZED VIEW $fschema.$ftable AS SELECT * FROM $ftable_schema.$ftable WITH DATA;"
   done
done
eval $ADDITIONAL_CONFIGURATION
