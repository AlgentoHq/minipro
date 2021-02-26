#!/bin/bash

set -e

file=
block=10485760
path=
getpath=
token=
subdir=
nameprefix=
readlinkbin=readlink
md5bin="md5 -q"

test -f upload.rc && source upload.rc || :

while test $# -gt 0; do case $1 in
    -f | --file ) shift; file=$1;;
    --name-prefix ) shift; nameprefix=$1;;
    --dir ) shift; subdir=$1;;
esac; shift; done

test -f $file
[ "$getpath" != "" ] || getpath=$path
if [ "$subdir" != "" ]; then
    path=$path/$subdir
    getpath=$path/$subdir
fi

function lexec {
    >&2 echo "> $@"
    "$@"
    echo
}

function err_ext {
    >&2 echo "error: $@"
    exit 1
}

test -f $file
file=`$readlinkbin -f $file`

size=`ls -l $file | awk '{print $5}'`
md5=`$md5bin $file | awk '{print $1}'`

dparts=$(mktemp -d)/$(basename $file).parts
test -d $dparts && rm -Rf $dparts || :
mkdir -p $dparts
dparts=$($readlinkbin -f $dparts)

echo "= spliting $file -> $dparts"

cd $dparts
split -b $block $file
ext=`echo ${file##*.} | tr '[:upper:]' '[:lower:]'`

rpath=$path/$nameprefix$md5.$ext
cblock=`ls $dparts | wc -l | awk '{print $1}'`
if [ "$cblock" = "1" ]; then
  echo "= touch single file -> $rpath"
  # lexec curl -k -X POST -H "X-Object-Size: $size" \
  #                -H "X-Object-Data-Hash: $md5" \
  #                -H "X-Auth-Token: $token" \
  #                $rpath
else
  echo "= create split -> $rpath"
  lexec curl -k -X POST -H "X-Object-Size: $size" \
                 -H "X-Object-Data-Hash: $md5" \
                 -H "X-Object-Block-Size: $block" \
                 -H "X-Auth-Token: $token" \
                 $rpath
fi

echo "= calc block"
vblocks=
for fpart in `ls $dparts`; do
    [ "$vblocks" = "" ] || vblocks="$vblocks,"
    vblocks="$vblocks`$md5bin $fpart | awk '{print $1}'`"
done

echo "= gather bucket info"
code=
function is_uploaded {
    # curl -s -k -I -H "X-Auth-Token: $token" $rpath
    code=`curl -s -k -I -H "X-Auth-Token: $token" -o /dev/null -w %{http_code} $rpath`
    if [ "$code" = "401" ]; then
        >&2 echo "not login!!"
        exit 1
    fi

    etags=`curl -s -k -I -H "X-Auth-Token: $token" $rpath | grep ETag: | awk '{print $2}' | tr -s "[:blank:]"`
    if [[ "${etags:0:8}" = "${md5:0:8}" ]]; then
        echo " etags matched, code=$code"
        [[ "$code" =~ ^20 ]] && return 0 || return 1
    fi
    [ "$cblock" = "1" ] && return 1

    blocks=`curl -s -k -I -H "X-Auth-Token: $token" $rpath | grep X-Object-Block-Hash: | awk '{print $2}' | tr -s "[:blank:]"`
    echo " blocks $blocks"
    # echo "vblocks $vblocks"
    if [ "${code:0:1}" = "2" ] && [ $((cblock*33-1)) -le `echo -n $blocks|wc -c` ] && [[ "$blocks" =~ $vblocks ]]; then
        return 0
    fi

    # echo "blocks $blocks"
    # echo "comparing $((cblock*33-1)) != `echo -n $blocks|wc -c`"
    return 1
}

if is_uploaded; then
    echo "already uploade"
else
    lexec curl -k -I -H "X-Auth-Token: $token" $rpath

    count=0
    if [ "$cblock" = "1" ]; then
        echo "= upload file from $dparts"
        lexec curl -k -X PUT -F "file=@$(ls $dparts)" \
                   -H "X-Auth-Token: $token" \
                   $rpath
    else
        echo "= upload $cblock parts, block = $((block/1024))KB, from = $dparts"
        for fsplit in $(ls $dparts); do
            partmd5=`$md5bin $fsplit | awk '{print $1}'`
            echo "[$(($count+1))/$cblock] $fsplit $partmd5"
            retry=3
            while true; do
                code=`curl -k -X PUT -F "file=@$fsplit" \
                           -H "X-Object-Block-Id: $count" \
                           -H "X-Auth-Token: $token" \
                           -o /dev/null -w %{http_code} \
                           $rpath`
                [ "$code" != "200" ] || break
                retry=$((retry-1))
                echo "upload part $count failed, retry $retry"
                if [ $retry -le 0 ]; then
                    >&2 echo "max retry, return failed"
                    exit 1
                fi
            done
            count=$((count+1))
        done
    fi

    timeout=30
    echo "= checking status, timeout = $timeouts"
    timeout=$((`date +%s`+$timeout))
    while [ `date +%s` -gt $timeout ]; do
        echo "combining..."
        is_uploaded && break || :
        sleep 1
    done
    if ! is_uploaded; then
        >&2 echo "upload failed!"
        exit 1
    fi
fi

echo "= get path"
echo $getpath/$nameprefix$md5.$ext
