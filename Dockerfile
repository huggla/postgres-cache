FROM postgres:10-alpine

COPY ./docker-entrypoint-initdb.d/x01.cache.sh /docker-entrypoint-initdb.d/x01.cache.sh

RUN chown postgres:root /docker-entrypoint-initdb.d/x01.cache.sh \
 && chmod ug+x /docker-entrypoint-initdb.d/x01.cache.sh

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV PGDATA="/tmp/pgdata" \
    USER="reader" \
    USER_PASSWORD="read" \
    DATABASE="cache" \
    FOREIGN_SERVER_NAME="foreign_server" \
    FOREIGN_SERVER_PORT="5432"

USER postgres
