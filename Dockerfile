FROM huggla/postgres-alpine

USER root

COPY ./initdb /initdb

ENV VAR_USER="reader" \
    VAR_USER_PASSWORD="read" \
    VAR_DATABASE="cache" \
    VAR_FOREIGN_SERVER_NAME="foreign_server" \
    VAR_FOREIGN_SERVER_PORT="5432" \
    VAR_param_fsync="off" \
    VAR_param_full_page_writes="off"

USER starter
