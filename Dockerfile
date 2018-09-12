FROM golang:alpine AS builder
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

#final stage
FROM alpine:latest
RUN apk --no-cache add ca-certificates openssl && \
    openssl req \
     -new \
     -newkey rsa:4096 \
     -days 365 \
     -nodes \
     -x509 \
     -subj "/C=US/ST=Iowa/L=Des Moines/O=Dwolla/CN=flashpaper.dwolla.net" \
     -keyout /server.key \
     -out /server.crt

COPY --from=builder /go/src/app/main /main
EXPOSE 8443
ENTRYPOINT /main
