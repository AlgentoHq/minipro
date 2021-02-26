#!/bin/bash

set -e
version=$1

[ "$version" != "" ]

cat package.json | jq ".version = \"$version\"" > package.json.2
mv -f package.json.2 package.json

npm install --save git+ssh://git@gitlab.corp.algento.com:miniprogram-public/mp-framework-include.git#$version
npm install webpack-cli -g
echo "= done"
