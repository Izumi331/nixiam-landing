FROM nginx:alpine
COPY nixiam-landing.html /usr/share/nginx/html/index.html
COPY favicon.svg /usr/share/nginx/html/favicon.svg