FROM nginx
RUN apt-get update && apt-get install -yq jq
COPY ./bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/ssl_*.sh
RUN mkdir -p /work && mkdir -p /seed
WORKDIR /work
