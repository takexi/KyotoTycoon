FROM alpine:3.4

ENV LANG ja_JP.UTF-8
ENV KYOTOCABINET_VERSION 1.2.76
ENV KYOTOTYCOON_VERSION 0.9.56

RUN apk update && apk upgrade \
  && apk --no-cache add libstdc++ supervisor \
  && apk --no-cache add --virtual build-dependencies build-base zlib-dev curl tzdata \
  && cp -pf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && echo "Asia/Tokyo" > /etc/timezone \
  && curl -SLO http://fallabs.com/kyotocabinet/pkg/kyotocabinet-${KYOTOCABINET_VERSION}.tar.gz \
  && tar xzvf kyotocabinet-${KYOTOCABINET_VERSION}.tar.gz \
  && cd kyotocabinet-${KYOTOCABINET_VERSION} \
  && ./configure \
  && make \
  && make install \
  && cd / \
  && curl -SLO http://fallabs.com/kyototycoon/pkg/kyototycoon-${KYOTOTYCOON_VERSION}.tar.gz \
  && tar xzvf kyototycoon-${KYOTOTYCOON_VERSION}.tar.gz \
  && cd kyototycoon-${KYOTOTYCOON_VERSION} \
  && ./configure \
  && sed -i -e "/^#include <kttimeddb.h>$/a #include <unistd.h>" ./ktdbext.h \
  && make \
  && make install \
  && cp -pf ./lab/ktservctl /bin/ \
  && cd / \
  && mkdir -p /etc/supervisor.d \
  && echo '[supervisord]' >> /etc/supervisor.d/ktserver.ini \
  && echo 'nodaemon=true' >> /etc/supervisor.d/ktserver.ini \
  && echo '[program:ktserver]' >> /etc/supervisor.d/ktserver.ini \
  && echo 'command=/bin/ktservctl start' >> /etc/supervisor.d/ktserver.ini \
  && apk del build-dependencies \
  && rm -rf \
       kyotocabinet-${KYOTOCABINET_VERSION} \
       kyotocabinet-${KYOTOCABINET_VERSION}.tar.gz \
       kyototycoon-${KYOTOTYCOON_VERSION} \
       kyototycoon-${KYOTOTYCOON_VERSION}.tar.gz

VOLUME ["/var/ktserver"]

EXPOSE 1978

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

