#!/bin/sh

# Set in parent scripts:
# ---------------------------------------------------------
# set -e +a +m +s +i +f
# VAR_*
# ---------------------------------------------------------

writePgCacheSqlFiles1(){
   local template_string=""
   if [ -n "$VAR_TEMPLATE" ]
   then
      template_string="TEMPLATE=$VAR_TEMPLATE"
   fi
   local prio="030"
   local dbname="postgres"
   local sql_file="/initdb/$prio.$dbname.sql"
   {
      echo "CREATE USER \"$VAR_USER\" WITH LOGIN NOINHERIT VALID UNTIL 'infinity' PASSWORD '$VAR_USER_PASSWORD';"
      echo "CREATE DATABASE \"$VAR_DATABASE\" WITH OWNER = \"$VAR_LINUX_USER\" $template_string;"
   } > "$sql_file"
   prio="031"
   dbname="$VAR_DATABASE"
   sql_file="/initdb/$prio.$dbname.sql"
   {
      echo "CREATE EXTENSION postgres_fdw;"
      echo "CREATE SERVER \"$VAR_FOREIGN_SERVER_NAME\" FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$VAR_FOREIGN_SERVER_ADDRESS', dbname '$VAR_FOREIGN_SERVER_DATABASE', port '$VAR_FOREIGN_SERVER_PORT');"
      echo "ALTER SERVER \"$VAR_FOREIGN_SERVER_NAME\" OPTIONS (ADD updatable 'false');"
      echo "CREATE USER MAPPING FOR \"$VAR_USER\" SERVER \"$VAR_FOREIGN_SERVER_NAME\" OPTIONS (user '$VAR_FOREIGN_SERVER_USER', password '$VAR_FOREIGN_SERVER_USER_PASSWORD');"
      echo "CREATE USER MAPPING FOR \"postgres\" SERVER \"$VAR_FOREIGN_SERVER_NAME\" OPTIONS (user '$VAR_FOREIGN_SERVER_USER', password '$VAR_FOREIGN_SERVER_USER_PASSWORD');"
   } > "$sql_file"
}

writePgCacheSqlFiles1
