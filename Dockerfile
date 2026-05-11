FROM node:20-alpine AS


FROM nginx:alpine

COPY ./deploy/nginx_conf/nginx.conf /etc/nginx/nginx.conf
COPY ./deploy/conf.d/ /etc/nginx/conf.d/
COPY ./deploy/html/ /usr/share/nginx/html/