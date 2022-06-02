FROM node:16-bullseye AS build-web

WORKDIR /usr/src/app/

COPY . .

WORKDIR /usr/src/app/octant/web

RUN npm ci --prefer-offline --no-audit

RUN npm run build

FROM golang:1.18-bullseye AS build-bin

WORKDIR /usr/src/app/octant

COPY --from=build-web /usr/src/app/ /usr/src/app/

RUN go run build.go build

FROM gcr.io/distroless/base-debian11

ENV OCTANT_LISTENER_ADDR=0.0.0.0:8080
ENV OCTANT_DISABLE_OPEN_BROWSER=true

COPY --from=build-bin /usr/src/app/build/octant /usr/local/bin/octant

ENTRYPOINT ["/usr/local/bin/octant"]

EXPOSE 8080