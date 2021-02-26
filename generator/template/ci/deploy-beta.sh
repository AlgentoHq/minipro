#!/bin/bash

set -e

wd=$PWD
app=$(cat dist/app.json | jq -r .app)
env=$(cat dist/app.json | jq -r .env)
platform=$(cat dist/app.json | jq -r .platform)
version=$(cat package.json | jq -r .version)
tag=$version
host_mpgate=https://betaproxy-hk.botim.me:7443/mpgateProxy

source upload.rc

echo "= rsync packet to remote"
bot-workspace 2>&1 || :
rsync -ivrh -c dist/ l-node1.sg-bot.ops.algento.com:/home/ec2-user/nginx/html/miniprogram/base$1/


echo "= publish to mpgate $host_mpgate"
cd $wd
file=$(cd dist/publish/$platform; ls | head -1)
md5=`$md5bin dist/publish/$platform/$file | awk '{print $1}'`
downloadurl="https://2018.botim.me/miniprogram/base$1/publish/$platform/$file"

json=$(mktemp)
echo '{
  "token":"",
  "url":"'$downloadurl'",
  "appInfo":'$(cat dist/app.json | jq ".md5 = \"$md5\"" | jq -c | jq -R)',
  "env":"'$env'"
}'> $json
echo "request:"
cat $json | jq
echo "response:"
curl -s -H 'Content-Type:application/json' -X POST -d @$json $host_mpgate/publish/app
echo

echo "= done!"
