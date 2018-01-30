FROM mdillon/postgis:10-alpine

COPY ./docker-entrypoint-initdb.d/x01.cache.sh /docker-entrypoint-initdb.d/x01.cache.sh

RUN chown postgres:postgres /docker-entrypoint-initdb.d/x01.cache.sh \
 && chmod ugo+x /docker-entrypoint-initdb.d/x01.cache.sh

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV PGDATA /tmp/pgdata                  # Container database data path
ENV USER reader                         # Container database user name
ENV USER_PASSWORD read                  # Container database user password
ENV DATABASE cache                      # Container database name
ENV FOREIGN_SERVER_NAME foreign_server  # Container database foreign server name
ENV FOREIGN_SERVER_PORT 5432            # Foreign server database port

# Mandatory runtime variables
# ---------------------------
# FOREIGN_SERVER_ADDRESS                # Foreign server address
# FOREIGN_SERVER_DATABASE               # Foreign server database name
# FOREIGN_SERVER_USER                   # Foreign server user name
# FOREIGN_SERVER_USER_PASSWORD          # Foreign server user password
# FOREIGN_SERVER_SCHEMAS                # Foreign server schemas to cache

# Optional runtime variables
# --------------------------
# <schema>                              # Foreign server table names (subset of <schema>)
# USER_PASSWORD_FILE                    # Container database user password file
# FOREIGN_SERVER_USER_PASSWORD_FILE     # Foreign server user password file
# ADDITIONAL_CONFIGURATION              # Container runtime bash commands 

# Additional variables: https://hub.docker.com/_/postgres/

USER postgres
