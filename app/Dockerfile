FROM nginx:1.11.12

RUN rm /etc/nginx/conf.d/default.conf

ADD app.conf /etc/nginx/conf.d/app.conf

RUN mkdir /app

ADD index.html /app

ADD wait-for-it.sh /app
