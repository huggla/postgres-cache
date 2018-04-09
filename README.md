**Note! I use Docker latest tag for development, which means that it isn't allways working. Date tags are stable.**

# postgis-cache
Docker image that creates a cache of foreign Postgis tables. The cache consists of a database with materialized views stored in ram. Based on huggla/postgis-alpine.

## Environment variables
### pre-set runtime variables from huggla/postgis-alpine.
* REV_LOCALE="en_US.UTF-8"
* REV_ENCODING="UTF8"
* REV_TEXT_SEARCH_CONFIG="english"
* REV_HBA="local all all trust, host all all 127.0.0.1/32 trust, host all all ::1/128 trust, host all all all md5"
* REV_CREATE_EXTENSION_PGAGENT="yes"
* REV_password_postgres=generated, random
* REV_param_data_directory="'/pgdata'"
* REV_param_hba_file="'/etc/postgres/pg_hba.conf'"
* REV_param_ident_file="'/etc/postgres/pg_ident.conf'"
* REV_param_unix_socket_directories="'/var/run/postgresql'"
* REV_param_listen_addresses="'*'"
* REV_param_timezone="'UTC'"

### pre-set runtime variables.
* REV_USER="reader": Name of database user with read access to the cache database.
* REV_USER_PASSWORD="read": Password for USER.
* REV_DATABASE="cache": Name of the container Postgis database.
* REV_FOREIGN_SERVER_NAME="foreign_server": Name of the foreign server in the cache database.
* REV_ENV FOREIGN_SERVER_PORT="5432": The database port on the source database.

### Mandatory runtime variables
* REV_FOREIGN_SERVER_ADDRESS: Network address to the source Postgis server.
* REV_FOREIGN_SERVER_DATABASE: Name of database containing tables to be cached.
* REV_FOREIGN_SERVER_USER: Database user, with read permission, on the source database.
* REV_FOREIGN_SERVER_USER_PASSWORD: Password for FOREIGN_SERVER_USER.
* REV_FOREIGN_SERVER_SCHEMAS: Comma separated list of source schemas that contains tables to cache.

### Optional runtime variables
* REV_&lt;schema&gt;: Comma separated sub-set of tables in \<schema\> to cache.
* REV_USER_PASSWORD_FILE: File containing the password for USER.
* REV_FOREIGN_SERVER_USER_PASSWORD_FILE: File containing the password for FOREIGN_SERVER_USER.
* REV_param_&lt;postgres parameter name&gt;_&lt;: Additional Postgresql parameters.

## Capabilities
Can drop all but CHOWN, DAC_OVERRIDE, FOWNER, SETGID and SETUID.

## Capabilities
### Must add
* SYS_ADMIN
