#!/bin/bash
set -e
IFS=","
#PATH=/usr/local/bin

if [ -n "$USER_PASSWORD_FILE" ]
then
   read USER_PASSWORD < "$USER_PASSWORD_FILE"
fi
readonly USER_PASSWORD

#psql_cmd="/usr/bin/env -i $BIN_DIR/sudo -u $NAME $BIN_DIR/psql -v ON_ERROR_STOP=1 --username $NAME --dbname $NAME"
#eval $psql_cmd <<-EOSQL

sql_file="$(/usr/bin/lsof +p $$ | /bin/grep "initdb" | /usr/bin/awk -F "\t" '{print $3}').sql"
echo "$sql_file"
echo "CREATE USER \"$USER\" WITH LOGIN NOINHERIT VALID UNTIL 'infinity' PASSWORD '$USER_PASSWORD';" > "$sql_file"
echo "CREATE DATABASE \"$DATABASE\" WITH OWNER = \"postgres\";" >> "$sql_file"
#EOSQL
exit
# TEMPLATE=template_postgis;
readonly FOREIGN_SERVER_USER_PASSWORD_FILE="$(var - FOREIGN_SERVER_USER_PASSWORD_FILE)"
if [ -n "$FOREIGN_SERVER_USER_PASSWORD_FILE" ]
then
   read FOREIGN_SERVER_USER_PASSWORD < "$FOREIGN_SERVER_USER_PASSWORD_FILE"
fi

psql -v ON_ERROR_STOP=1 --username "postgres" "$DATABASE" <<-EOSQL
    CREATE EXTENSION postgres_fdw;
    CREATE SERVER "$FOREIGN_SERVER_NAME" FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$FOREIGN_SERVER_ADDRESS', dbname '$FOREIGN_SERVER_DATABASE', port '$FOREIGN_SERVER_PORT');
    ALTER SERVER "$FOREIGN_SERVER_NAME" OPTIONS (ADD updatable 'false');
    CREATE USER MAPPING FOR "$USER" SERVER "$FOREIGN_SERVER_NAME" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');
    CREATE USER MAPPING FOR "postgres" SERVER "$FOREIGN_SERVER_NAME" OPTIONS (user '$FOREIGN_SERVER_USER', password '$FOREIGN_SERVER_USER_PASSWORD');
EOSQL

for fschema in $FOREIGN_SERVER_SCHEMAS
do
   eval 'foreign_server_schema_tables=$'"$fschema"
   if [ -n "$foreign_server_schema_tables" ]
   then 
      limitstr="LIMIT TO ($foreign_server_schema_tables)"
   else
      limitstr=""
   fi
   ftable_schema=$fschema"_foreign"
   psql -v ON_ERROR_STOP=1 --username "postgres" "$DATABASE" <<-___EOSQL
      CREATE SCHEMA $ftable_schema AUTHORIZATION "postgres";
      GRANT USAGE ON SCHEMA $ftable_schema TO "$USER";
      ALTER DEFAULT PRIVILEGES IN SCHEMA $ftable_schema GRANT SELECT ON TABLES TO "$USER";
      IMPORT FOREIGN SCHEMA "$fschema" $limitstr FROM SERVER "$FOREIGN_SERVER_NAME" INTO $ftable_schema;
      CREATE SCHEMA "$fschema" AUTHORIZATION "postgres";
      GRANT USAGE ON SCHEMA "$fschema" TO "$USER";
      ALTER DEFAULT PRIVILEGES IN SCHEMA "$fschema" GRANT SELECT ON TABLES TO "$USER";
___EOSQL
   if [ -z "$foreign_server_schema_tables" ]
   then
      foreign_server_schema_tables=`psql -q -A -t -R , -v ON_ERROR_STOP=1 --username "postgres" "$DATABASE" -c "SELECT table_name FROM information_schema.tables WHERE table_schema='$ftable_schema'"`
   fi   
   for ftable in $foreign_server_schema_tables
   do
      psql -v ON_ERROR_STOP=1 --username "postgres" "$DATABASE" -c "CREATE MATERIALIZED VIEW $fschema.$ftable AS SELECT * FROM $ftable_schema.$ftable WITH DATA;"
   done
done
eval $ADDITIONAL_CONFIGURATION
