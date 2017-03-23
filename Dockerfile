FROM debian:jessie
RUN apt-get update -qq && apt-get install -y make autoconf automake flex bison libevent-dev pkg-config libssl-dev libtool libboost-filesystem-dev python g++ git -qq
ENV THRIFT_PATH /usr/local/src/thrift
RUN git clone https://github.com/apache/thrift.git $THRIFT_PATH \
    && cd $THRIFT_PATH && git fetch && git checkout 0.9.1 && ./bootstrap.sh && ./configure && make && make install
RUN cd $THRIFT_PATH/contrib/fb303 && ./bootstrap.sh && ./configure && make && make install
RUN cd $THRIFT_PATH/lib/py && python setup.py install && cd $THRIFT_PATH/contrib/fb303/py && python setup.py install
ENV SCRIBE_PATH /usr/local/src/scribe
RUN git clone https://github.com/facebookarchive/scribe.git $SCRIBE_PATH \
    && cd $SCRIBE_PATH && sed -i 's/^\(AM_INIT_AUTOMAKE.*\)/#\1/g' configure.ac && autoreconf --force --verbose --install \
    && ./configure LIBS="-lboost_system -lboost_filesystem" --config-cache --with-boost-filesystem=boost_filesystem && make && make install
RUN apt-get remove -y git g++ gcc cpp autoconf automake && apt-get autoremove -y
RUN rm -rf /usr/local/src && mkdir -p /srv/logs/scribed

COPY config /srv/config
CMD ["/usr/local/bin/scribed", "/srv/config/scribed.conf"]
