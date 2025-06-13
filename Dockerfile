FROM alpine:latest

ARG ps5_ip
ARG killgame
ARG continue
ARG inject
ENV PYTHONUNBUFFERED=1

RUN apk update
RUN apk add --no-cache bash git wget curl jq socat python3 && ln -sf python3 /usr/bin/python

WORKDIR /opt
RUN wget https://raw.githubusercontent.com/BenNoxXD/automatic-lua-loader/refs/heads/main/install.sh 
RUN chmod +x install.sh 
RUN bash install.sh -ps5_ip=$ps5_ip -docker=on -killgame=$killgame -continue=$continue -inject=$inject

RUN chmod +x /opt/automatic-lua-loader/run.sh
RUN rm /opt/install.sh

CMD ["bash", "/opt/automatic-lua-loader/run.sh"]
