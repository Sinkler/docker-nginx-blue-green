FROM nginx:1.11.12

RUN apt-get update -qqy && apt-get -qqy install curl runit wget unzip && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN wget https://releases.hashicorp.com/consul-template/0.19.3/consul-template_0.19.3_linux_amd64.zip && \
    unzip -d /usr/local/bin consul-template_0.19.3_linux_amd64.zip && \
    rm -rf consul-template_0.19.3_linux_amd64.zip

ADD nginx.service /etc/service/nginx/run
ADD consul-template.service /etc/service/consul-template/run
RUN mkdir /etc/consul-templates
ADD nginx.conf.ctmpl /etc/consul-templates
RUN chmod +x /etc/service/nginx/run && chmod +x /etc/service/consul-template/run
RUN rm /etc/nginx/conf.d/default.conf

CMD ["/usr/bin/runsvdir", "/etc/service"]
