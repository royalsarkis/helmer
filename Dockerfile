ARG HELM=3.13.2
ARG YQ4=4.35.2

FROM alpine:3.18.4

ARG HELM
ARG YQ4

RUN addgroup -g 1000 -S helmer && adduser -u 1000 -S helmer -G helmer
COPY helmer.sh /usr/local/bin/
RUN wget -O- https://get.helm.sh/helm-v${HELM}-linux-amd64.tar.gz | tar -C /usr/local/bin --strip-components=1 -xz linux-amd64/helm
RUN wget -O- https://github.com/mikefarah/yq/releases/download/v${YQ4}/yq_linux_amd64.tar.gz | tar -C /usr/local/bin -xz ./yq_linux_amd64 && mv /usr/local/bin/yq_linux_amd64 /usr/local/bin/yq
RUN chmod +x /usr/local/bin/helmer.sh

FROM alpine:3.18.4

ARG HELM
ARG YQ4

COPY --from=0 /etc/passwd /etc/group /etc/
COPY --from=0 --chown=1000:1000 /usr/local/bin/helm /usr/local/bin/yq /usr/local/bin/
COPY --from=0 --chown=1000:1000 /usr/local/bin/helmer.sh /
RUN apk add --update --no-cache bash
USER helmer
WORKDIR /in
WORKDIR /out

LABEL org.opencontainers.image.authors="https://github.com/royalsarkis"
LABEL org.opencontainers.image.base.name="docker.io/library/alpine:3.18.4"
LABEL org.opencontainers.image.description="helmer is similar to the helm package command, with the added benefit of allowing you to override the values.yaml file."
LABEL org.opencontainers.image.source="https://github.com/royalsarkis/helmer"
LABEL org.opencontainers.image.title="helmer"
LABEL org.opencontainers.image.version="helm ${HELM} yq ${YQ4}"

ENTRYPOINT ["/helmer.sh"]
