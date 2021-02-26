#!/bin/bash

set -e

wd=$PWD
app=$(cat dist/app.json | jq -r .app)
env=$(cat dist/app.json | jq -r .env)
platform=$(cat dist/app.json | jq -r .platform)
version=$(cat package.json | jq -r .version)
tag=$version
host_mpgate=https://mpgate.botim.me


if [ "$platform" != "bridge" ]; then
    >&2 echo "publish $platform is not allowed"
    exit 1
fi

echo "= upload packet to storage"
cd $wd
source upload.rc
subdir=app/$app/$platform/$version
file=dist/publish/$platform/$(cd dist/publish/$platform;ls)
appshort=`echo ${app##*.} | tr '[:upper:]' '[:lower:]'`
nameprefix=$appshort-${version}-
bash ci/upload.sh --file $file --dir $subdir --name-prefix $nameprefix
echo

echo "= publish to mpgate $host_mpgate"
cd $wd
md5=`$md5bin $file | awk '{print $1}'`
ext=`echo ${file##*.} | tr '[:upper:]' '[:lower:]'`
downloadurl=$getpath/$subdir/$nameprefix$md5.$ext

json=$(mktemp)
echo '{
  "token":"'$publishtoken'",
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
