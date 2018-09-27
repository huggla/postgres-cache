FROM huggla/postgres-alpine as stage1

COPY ./rootfs /rootfs

RUN find /* -maxdepth 0 ! -name rootfs -execdir cp -a {} /rootfs/

FROM huggla/base

ENV VAR_USER="reader" \
    VAR_USER_PASSWORD="read" \
    VAR_DATABASE="cache" \
    VAR_FOREIGN_SERVER_NAME="foreign_server" \
    VAR_FOREIGN_SERVER_PORT="5432" \
    VAR_param_fsync="off" \
    VAR_param_full_page_writes="off"

ONBUILD USER root
