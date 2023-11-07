FROM golang:1.21-alpine as builder

RUN apk update && apk upgrade \
    && apk add --no-cache git gcc libc-dev \
    #
    && git clone https://github.com/whosonfirst/go-whosonfirst-geoparquet.git go-whosonfirst-geoparquet \
    && cd go-whosonfirst-geoparquet \
    && go build -mod vendor -ldflags="-s -w" -o /usr/local/bin/wof-geoparquet-features cmd/features/main.go \
    && cd - \
    && rm -rf /go-whosonfirst-geoparquet \
    #
    && git clone https://github.com/planetlabs/gpq.git \
    && cd gpq \
    && go build -ldflags="-s -w" -o /usr/local/bin/gpq cmd/gpq/main.go \
    && cd - \
    && rm -rf /gpq \
    #
    && git clone https://github.com/aaronland/gocloud-blob.git gocloud-blob \
    && cd gocloud-blob \
    && go build -mod vendor -ldflags="-s -w" -o /usr/local/bin/copy-uri cmd/copy-uri/main.go \
    && cd - \
    && rm -rf /gocloud-blob
    
FROM alpine

RUN mkdir /usr/local/data

VOLUME /usr/local/data

RUN apk update && apk upgrade 

COPY --from=builder /usr/local/bin/wof-geoparquet-features /usr/local/bin/wof-geoparquet-features
COPY --from=builder /usr/local/bin/gpq /usr/local/bin/gpq
COPY --from=builder /usr/local/bin/copy-uri /usr/local/bin/copy-uri

COPY build.sh /usr/local/bin/build.sh