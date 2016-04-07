FROM ctrlok/hugo
MAINTAINER Vsevolod Polyakov <ctrlok@gmail.com>
ADD config.toml /opt/ctrlok.com/
ADD content/ /opt/ctrlok.com/content
ADD themes/ /opt/ctrlok.com/themes
RUN mkdir /opt/ctrlok.com/public
WORKDIR /opt/ctrlok.com
RUN hugo -t angels-ladder
VOLUME /opt/ctrlok.com/public
ADD nginx/default.conf /etc/nginx/conf.d/default.conf
VOLUME /etc/nginx/conf.d
