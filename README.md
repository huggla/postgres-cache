# postgres-cache
Docker image that creates a cache of foreign Postgres tables. The cache consists of a database with materialized views stored in ram. Based on huggla/postgres-alpine.

## Environment variables
### pre-set runtime variables
* VAR_CONFIG_FILE="/etc/postgres/postgresql.conf"
* VAR_FINAL_COMMAND="/usr/local/bin/postgres --config_file=\"\$VAR_CONFIG_FILE\""
* VAR_LOCALE="en_US.UTF-8"
* VAR_ENCODING="UTF8"
* VAR_TEXT_SEARCH_CONFIG="english"
* VAR_HBA="local all all trust, host all all 127.0.0.1/32 trust, host all all ::1/128 trust, host all all all md5"
* VAR_CREATE_EXTENSION_PGAGENT="yes"
* VAR_ARGON2_PARAMS="-r" (only used if VAR_ENCRYPT_PW is set to "yes")
* VAR_SALT_FILE="/proc/sys/kernel/hostname" (only used if VAR_ENCRYPT_PW is set to "yes")
* VAR_LINUX_USER="postgres" (also database owner/superuser)
* VAR_param_data_directory="'/pgdata'" (Must be owned by UID 102)
* VAR_param_hba_file="'/etc/postgres/pg_hba.conf'"
* VAR_param_ident_file="'/etc/postgres/pg_ident.conf'"
* VAR_param_unix_socket_directories="'/var/run/postgresql'"
* VAR_param_listen_addresses="'*'"
* VAR_param_timezone="'UTC'"
* VAR_FREETDS_CONF="[global]\\ntds version=auto\\ntext size=64512" (contents of /etc/freerds.conf)
* VAR_USER="reader": Name of database user with read access to the cache database.
* VAR_USER_PASSWORD="read": Password for USER.
* VAR_DATABASE="cache": Name of the container Postgis database.
* VAR_FOREIGN_SERVER_NAME="foreign_server": Name of the foreign server in the cache database.
* VAR_ENV FOREIGN_SERVER_PORT="5432": The database port on the source database.

### Mandatory runtime variables
* VAR_FOREIGN_SERVER_ADDRESS: Network address to the source Postgis server.
* VAR_FOREIGN_SERVER_DATABASE: Name of database containing tables to be cached.
* VAR_FOREIGN_SERVER_USER: Database user, with read permission, on the source database.
* VAR_FOREIGN_SERVER_USER_PASSWORD: Password for FOREIGN_SERVER_USER.
* VAR_FOREIGN_SERVER_SCHEMAS: Comma separated list of source schemas that contains tables to cache.

### Optional runtime variables
* VAR_param_&lt;postgres parameter name&gt;
* VAR_password_file_&lt;VAR_LINUX_USER&gt;
* VAR_password_&lt;VAR_LINUX_USER&gt;
* VAR_ENCRYPT_PW (set to "yes" to hash password with Argon2)
* VAR_&lt;schema&gt;: Comma separated sub-set of tables in \<schema\> to cache.
* VAR_USER_PASSWORD_FILE: File containing the password for USER.
* VAR_FOREIGN_SERVER_USER_PASSWORD_FILE: File containing the password for FOREIGN_SERVER_USER.
* VAR_param_&lt;postgres parameter name&gt;_&lt;: Additional Postgresql parameters.

## Capabilities
Can drop all but SETPCAP, SETGID and SETUID.
