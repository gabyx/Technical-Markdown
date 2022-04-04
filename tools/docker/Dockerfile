FROM alpine:latest as base
ARG NAME="1234"
RUN echo "base:: $NAME"

FROM base AS base-dev
ARG NAME
RUN echo "dev:: $NAME"

FROM base-dev as base-custom
ARG NAME
RUN echo "custom::" $NAME
