We use [Firebase Remote Config](https://firebase.google.com/docs/remote-config) for dynamic configuration of our app.

There are one configuration for [dev](https://console.firebase.google.com/project/pi-ostelco-prod/config) and one for [prod](https://console.firebase.google.com/project/pi-ostelco-dev/config).

For future reference:
It should be possible to automatically push changes to remote config using the [REST API](https://firebase.google.com/docs/remote-config/use-config-rest) which would enable us to deploy these changes automatically through CI.
