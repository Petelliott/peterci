FROM ubuntu:18.04

COPY build.sh /

RUN mkdir /repo

RUN apt-get update && apt-get install -y jq

CMD ./build.sh /repo/*
