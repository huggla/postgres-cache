FROM postgres:10-alpine

COPY ./docker-entrypoint-initdb.d/x01.cache.sh /docker-entrypoint-initdb.d/x01.cache.sh

RUN chown postgres:postgres /docker-entrypoint-initdb.d/x01.cache.sh \
 && chmod ugo+x /docker-entrypoint-initdb.d/x01.cache.sh

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV PGDATA /tmp/pgdata
ENV USER reader
ENV USER_PASSWORD read
ENV DATABASE cache
ENV FOREIGN_SERVER_NAME foreign_server
ENV FOREIGN_SERVER_PORT 5432

USER postgres
