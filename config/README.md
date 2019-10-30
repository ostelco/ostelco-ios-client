This project is based on [REST APIs using the node client](https://github.com/firebase/quickstart-nodejs/tree/master/config) to manipulate remote config in firebase.

### Prerequisites
1. Download the corresponding service account files and add them to .secrets

for dev: `pi-ostelco-dev-firebase-adminsdk.json`

for prod: `pi-ostelco-prod-firebase-adminsdk.json`

More info on how to download service accounts from the firebase remote config REST API [documentation](https://firebase.google.com/docs/remote-config/use-config-rest#step_2_get_an_access_token_to_authenticate_and_authorize_api_requests)

2. `npm install`
3. `npm run publish:dev` or `npm run publish:prod`


It's also possible to run the `index.js` directly

```
node index.js get
node index.js publish <LATEST_ETAG>
node index.js versions
node index.js rollback <TEMPLATE_VERSION_NUMBER>
```

The above commands defaults to our `dev` project, to run them in `prod` add `ENVIRONMENT=prod` in front like so:

`ENVIRONMENT=prod node index.js get`

### Update config

To update the config you could

1. Copy the "value" of the config you want to modify

```
"feature_flags": {
      "defaultValue": {
        "value": "{\"enableStripeInsteadOfApplePay\":false}"
      }
    }
```
This part from the above

`{\"enableStripeInsteadOfApplePay\":false}`

2. Use a tool to unescape the string like https://www.freeformatter.com/json-escape.html
3. Optionally use https://jsonlint.com/ to pretty print it before modifying
4. Use tool from step 2 to escape the string
5. Update the `"value"` field with the new values 
6. Run the scripts to publish the newly modified config


