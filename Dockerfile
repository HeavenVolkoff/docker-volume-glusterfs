ARG DEBIAN_VERSION=bookworm-slim

FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx

#--

FROM --platform=$BUILDPLATFORM golang:alpine as plugin-builder

ARG TARGETPLATFORM

RUN apk add clang lld

# Setup Cross-compiling
COPY --from=xx / /
RUN xx-apk add musl-dev gcc
RUN set -e; [ "$(xx-info arch)" != "ppc64le" ] \
    || \
    XX_CC_PREFER_LINKER=ld xx-clang --setup-target-triple

COPY . /go/src/github.com/urbitechsro/docker-volume-glusterfs

WORKDIR /go/src/github.com/urbitechsro/docker-volume-glusterfs

ARG CGO_ENABLED=1
RUN xx-go build -tags 'netgo osusergo' -ldflags '-extldflags "-static"' -o /bin/docker-volume-glusterfs \
    && \
    xx-verify --static /bin/docker-volume-glusterfs

#--

FROM debian:${DEBIAN_VERSION}

# --- Environment Variables ---
# Don't allow APT to make question
ARG DEBIAN_FRONTEND=noninteractive
# http://stackoverflow.com/questions/48162574/ddg#49462622
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Add APT config file
ADD "https://gist.githubusercontent.com/HeavenVolkoff/ff7b77b9087f956b8df944772e93c071/raw" /etc/apt/apt.conf.d/99custom

# No need to reset cache after: https://github.com/rocker-org/rocker/issues/35#issuecomment-58944297
RUN apt update -qq && apt install glusterfs-client

COPY --from=plugin-builder /bin/docker-volume-glusterfs /bin/

CMD ["/bin/docker-volume-glusterfs"]

LABEL org.opencontainers.image.title="docker-volume-glusterfs" \
    org.opencontainers.image.authors="Vítor Vasconcellos <support@vasconcellos.casa>" \
    org.opencontainers.image.version="1.2.0" \
    org.opencontainers.image.revision="7" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.description="This is a managed Docker volume plugin to allow Docker containers to access GlusterFS volumes"
