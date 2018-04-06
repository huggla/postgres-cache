FROM huggla/postgres-alpine

# pre-set variables (can be set at runtime)
# -----------------------------------------
ENV REV_USER="reader" \
    REV_USER_PASSWORD="read" \
    REV_DATABASE="cache" \
    REV_FOREIGN_SERVER_NAME="foreign_server" \
    REV_FOREIGN_SERVER_PORT="5432"
