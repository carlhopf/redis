FROM redis:7.0.9 as builder

RUN apt-get update -qq
RUN apt-get install -yq git 
RUN git clone --recursive https://github.com/RediSearch/RediSearch.git /redisearch

WORKDIR /redisearch

RUN git checkout v2.6.6
RUN git submodule update --init --recursive

RUN ./sbin/setup
RUN bash -l

RUN make setup
RUN make build


FROM redis:7.0.9

COPY redis.conf /etc/redis/redis.conf

COPY entrypoint.sh /usr/bin/entrypoint.sh

COPY setupMasterSlave.sh /usr/bin/setupMasterSlave.sh

COPY healthcheck.sh /usr/bin/healthcheck.sh

COPY --from=builder /redisearch/bin/linux-*-release/search/redisearch.so /etc/redis/redisearch.so


VOLUME ["/data"]

WORKDIR /data

EXPOSE 6379


ENTRYPOINT ["/usr/bin/entrypoint.sh"]
