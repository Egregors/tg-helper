FROM ubuntu:trusty

MAINTAINER Egregors (egregors@yandex.ru)

# Install tg
RUN apt-get update && apt-get install -y \
libreadline-dev \
libconfig-dev \
libssl-dev \
lua5.2 \
liblua5.2-dev \
libevent-dev \
make \
git

RUN cd /home && git clone --recursive https://github.com/vysheng/tg.git
RUN cd /home/tg && ./configure && make

# Add lua action script
ADD ./_custom /home/tg/_custom

# Add auth
ADD ./auth /root/.telegram-cli/

CMD ["/home/tg/bin/telegram-cli", "-k", "/home/tg/tg-server.pub", "-W", "-s", "/home/tg/_custom/action.lua"]