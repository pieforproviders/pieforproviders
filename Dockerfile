# BASED ON
# https://blog.codeminer42.com/zero-to-up-and-running-a-rails-project-only-using-docker-20467e15f1be/

# Specify the Docker image to use as a base:
FROM ruby:2.6.6

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_VERSION=14.16.0

RUN sed -i '/deb-src/d' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y build-essential tree graphviz

RUN curl -sSL "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" | tar xfJ - -C /usr/local --strip-components=1 && \
    npm install npm -g

RUN useradd -m -s /bin/bash -u 1000 winner
USER winner

WORKDIR /home/winner/myapp
