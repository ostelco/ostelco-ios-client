#!/bin/bash
# Used to update the firebase remote config for pi-ostelco-dev or pi-ostelco-prod using the corresponding remote config values found in remote-config-dev.json and remote-config-prod.json.
# USAGE: 
# - ./update.sh dev
# - ./update.sh prod
# The script is meant to be run through npm run publish:dev or npm run publish:prod
# The above are defined under "scripts" in package.json 

# Get previous ETAG (ETAG is used by firebase to validate the version we update and every update requires us to pass the previous / latest ETAG
# node index.js get returns the latest remote config template and is printed out in the console, we then grep for it and massage the line so we get only the ETAG
ETAG=`ENVIRONMENT=$1 node index.js get | grep etag | cut -d : -f 2- | sed -e 's/^[ \t]*//'`

# Publish remote-config-<ENVIRONMENT>.json
ENVIRONMENT=$1 node index.js publish $ETAG
