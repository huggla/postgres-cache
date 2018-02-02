# postgres-cache
Docker image that creates a cache of foreign Postgresql tables. The cache consists of a database with materialized views stored in ram.

## Environment variables
### pre-set variables (can be set at runtime)
* PGDATA (/tmp/pgdata): Where the cache database is stored inside the container.
* USER (reader): Name of database user with read access to the cache database.
* USER_PASSWORD (read): Password for USER.
* DATABASE (cache): Name of the container Postgresql database.
* FOREIGN_SERVER_NAME (foreign_server): Name of the foreign server in the cache database.
* ENV FOREIGN_SERVER_PORT (5432): The database port on the source database.

### Mandatory runtime variables
* FOREIGN_SERVER_ADDRESS: Network address to the source Postgresql server.
* FOREIGN_SERVER_DATABASE: Name of database containing tables to be cached.
* FOREIGN_SERVER_USER: Database user, with read permission, on the source database.
* FOREIGN_SERVER_USER_PASSWORD: Password for FOREIGN_SERVER_USER.
* FOREIGN_SERVER_SCHEMAS: Comma separated list of source schemas that contains tables to cache.

### Optional runtime variables
* \<schema\>: Comma separated sub-set of tables in \<schema\> to cache.
* USER_PASSWORD_FILE: File containing the password for USER.
* FOREIGN_SERVER_USER_PASSWORD_FILE: File containing the password for FOREIGN_SERVER_USER.
* ADDITIONAL_CONFIGURATION: Semi colon separated list of bash commands to run during database init.

### Additional variables
Check out the postgres base image documentation, https://hub.docker.com/_/postgres/.

## Volumes
* Mount a volume at PGDATA if you prefer caching to disk.
* Mounting an empty folder on your host to /var/lib/postgresql/data prevents creation of an unnecessary volume.

## Capabilities
### Must add
* SYS_ADMIN

### Can drop
* AUDIT_CONTROL
* AUDIT_WRITE
* BLOCK_SUSPEND
* DAC_READ_SEARCH
* IPC_LOCK
* IPC_OWNER
* KILL
* LEASE
* LINUX_IMMUTABLE
* MAC_ADMIN
* MAC_OVERRIDE
* MKNOD
* NET_ADMIN
* NET_BIND_SERVICE
* NET_BROADCAST
* NET_RAW
* SETFCAP
* SETPCAP
* SYSLOG
* SYS_BOOT
* SYS_CHROOT
* SYS_MODULE
* SYS_NICE
* SYS_PACCT
* SYS_PTRACE
* SYS_RAWIO
* SYS_RESOURCE
* SYS_TIME
* SYS_TTY_CONFIG
* WAKE_ALARM

## Tips
Example of ADDITIONAL_CONFIGURATION:
```
echo "ssl = on" >> "$PGDATA/postgresql.conf"; echo "ssl_cert_file = '/run/secrets/ssl-cert-snakeoil.pem'" >> "$PGDATA/postgresql.conf"; echo "ssl_key_file = '/run/secrets/ssl-cert-snakeoil.key'" >> "$PGDATA/postgresql.conf"; head -n -1 "$PGDATA/pg_hba.conf" > /tmp/pg_hba.conf; mv /tmp/pg_hba.conf "$PGDATA/pg_hba.conf"; echo "hostssl all reader all trust" >> "$PGDATA/pg_hba.conf"; psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -c "SET TIME ZONE 'Europe/Stockholm';"
```
