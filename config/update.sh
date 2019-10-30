# Get previous ETAG
ETAG=`ENVIRONMENT=$1 node index.js get | grep etag | cut -d : -f 2- | sed -e 's/^[ \t]*//'`
# Publish remote-config-<ENVIRONMENT>.json
ENVIRONMENT=$1 node index.js publish $ETAG
