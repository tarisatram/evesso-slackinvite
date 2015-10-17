# evesso-slackinvite

evesso-slackinvite is a simple sinatra webapp that allows CREST authenticated characters to submit requests to a Slack. team.
Prior to deploying, you need to have created an Incoming WebHook integration for your Slack. team.
You also need to register an application on https://developers.eveonline.com and get the client id, secret key, and set the OAuth callback url.

Deploys have only been tested on Heroku thus far. It should work with any cloud provider that supports ruby, or you can deploy it on your own.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/tarisatram/evesso-slackinvite.git)
