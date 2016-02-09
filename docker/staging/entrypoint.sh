#!/bin/bash
set -e

cd /var/www/app
# run startup script, like migrations

# run the CMD
exec "$@"
