set -x
TAG=$1

npm install
if [ `echo $TAG | grep 't'` ]; then
    echo build build
    npm run build
elif [ `echo $TAG | grep 'r'` ]; then

    echo build test
    npm run test
else
     echo build beta/business
     npm run build
fi

