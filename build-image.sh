#!/bin/sh

THRIFT_PATH=/usr/local/src/thrift
SCRIBE_PATH=/usr/local/src/scribe
CONTAINER_NAME="scribe-temp-`date +%Y%m%d%H%M%S`"
SCRIBE_IMAGE_NAME=hisoku/scribe

docker create --name $CONTAINER_NAME debian:jessie init
docker start $CONTAINER_NAME

docker exec --tty $CONTAINER_NAME sh -c "apt-get update -qq && apt-get install -y make autoconf automake flex bison libevent-dev pkg-config libssl-dev libtool libboost-filesystem-dev python g++ git -qq"
docker exec --tty $CONTAINER_NAME sh -c "git clone https://github.com/apache/thrift.git $THRIFT_PATH && cd $THRIFT_PATH && git fetch && git checkout 0.9.1 && ./bootstrap.sh && ./configure && make && make install"
docker exec --tty $CONTAINER_NAME sh -c "cd $THRIFT_PATH/contrib/fb303 && ./bootstrap.sh && ./configure && make && make install"
docker exec --tty $CONTAINER_NAME sh -c "cd $THRIFT_PATH/lib/py && python setup.py install && cd $THRIFT_PATH/contrib/fb303/py && python setup.py install"
docker exec --tty $CONTAINER_NAME sh -c "git clone https://github.com/facebookarchive/scribe.git $SCRIBE_PATH && cd $SCRIBE_PATH && sed -i 's/^\\(AM_INIT_AUTOMAKE.*\\)/#\\1/g' configure.ac && autoreconf --force --verbose --install && ./configure LIBS='-lboost_system -lboost_filesystem' --config-cache --with-boost-filesystem=boost_filesystem && make && make install"
docker exec --tty $CONTAINER_NAME sh -c "apt-get remove -y git g++ gcc cpp autoconf automake && apt-get autoremove -y"
docker exec --tty $CONTAINER_NAME sh -c "rm -rf /usr/local/src && mkdir -p /srv/logs/scribed"

docker cp config $CONTAINER_NAME:/srv/config
docker commit $CONTAINER_NAME $SCRIBE_IMAGE_NAME
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
