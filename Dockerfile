FROM huggla/postgres-alpine

USER root

COPY ./initdb "$CONFIG_DIR/initdb"

ENV PATH="$BIN_DIR:/bin:/sbin:/usr/bin:/usr/sbin"

RUN /bin/chown -R root:$BEV_NAME "$CONFIG_DIR/initdb" \
 && /bin/chmod -R u=rwX,g=rX,o= "$CONFIG_DIR/initdb"

USER sudoer

ENV PATH="$BIN_DIR"

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV REV_USER="reader" \
    REV_USER_PASSWORD="read" \
    REV_DATABASE="cache" \
    REV_FOREIGN_SERVER_NAME="foreign_server" \
    REV_FOREIGN_SERVER_PORT="5432" \
    REV_param_fsync="off" \
    REV_param_full_page_writes="off"
