FROM huggla/postgres-alpine

USER root

COPY ./initdb/x01.cache.sh /etc/postgres/initdb/x01.cache.sh

RUN /bin/chown postgres:root /etc/postgres/initdb/x01.cache.sh \
 && /bin/chmod ug+x /etc/postgres/initdb/x01.cache.sh

USER sudoer

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV REV_USER="reader" \
    REV_USER_PASSWORD="read" \
    REV_DATABASE="cache" \
    REV_FOREIGN_SERVER_NAME="foreign_server" \
    REV_FOREIGN_SERVER_PORT="5432"
