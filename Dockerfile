FROM huggla/postgres-alpine

USER root

COPY ./initdb/x01.cache.sh /etc/initdb/x01.cache.sh

RUN /bin/chown postgres:root /etc/initdb/x01.cache.sh \
 && /bin/chmod ug+x /etc/initdb/x01.cache.sh

USER sudoer

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV USER="reader" \
    USER_PASSWORD="read" \
    DATABASE="cache" \
    FOREIGN_SERVER_NAME="foreign_server" \
    FOREIGN_SERVER_PORT="5432"
