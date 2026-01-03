FROM scratch AS ctx
COPY build_files /

FROM docker.io/archlinux/archlinux:latest as arch-base

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/root \
    /ctx/base.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/readonly.sh
    
RUN bootc container lint
