FROM artifactory.outbrain.com:5005/golang:1.21.3-bullseye AS build

WORKDIR $GOPATH/src/pushgateway
COPY go.mod ./
COPY go.sum ./
COPY . .

ENV CGO_ENABLED=0
RUN go build -ldflags '-extldflags "static"' -v ./...
RUN go install -v ./...
RUN md5sum /go/bin/pushgateway | tee /pushgateway.md5sum

FROM quay.io/prometheus/busybox-linux-amd64:latest
LABEL maintainer="The Prometheus Authors <prometheus-developers@googlegroups.com>"

COPY --from=build --chown=nobody:nobody /go/bin/pushgateway /bin/pushgateway

EXPOSE 9091
RUN mkdir -p /pushgateway && chown nobody:nobody /pushgateway
WORKDIR /pushgateway

USER 65534

ENTRYPOINT [ "/bin/pushgateway" ]
