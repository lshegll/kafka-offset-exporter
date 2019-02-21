FROM golang:alpine as builder
RUN apk --no-cache --virtual=build-dependencies add git make gcc g++ && \
    go get -v github.com/danielqsj/kafka_exporter
WORKDIR /go/src/github.com/danielqsj/kafka_exporter
RUN GOARCH=amd64 GOOS=linux go build -v -a -ldflags '-extldflags "-static" -s -w' -o /bin/kafka_exporter .

FROM alpine:3.6
COPY --from=builder /bin/kafka_exporter /bin/kafka_exporter
CMD ["/bin/sh", "-c", "/bin/kafka_exporter -log.level debug -kafka.server ${KAFKA_BROKERS} -web.telemetry-path /metrics -web.listen-address :7979 -topic.filter \"^[^_].*\" -group.filter \".*\""]
