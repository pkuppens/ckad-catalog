# Static frontend served by nginx (listens on 8080 so it can run as non-root).
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY html/ /usr/share/nginx/html/

EXPOSE 8080
