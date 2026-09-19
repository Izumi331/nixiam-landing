FROM nginx:alpine

# Config nginx (active les Server Side Includes pour header.html / footer.html)
COPY default.conf /etc/nginx/conf.d/default.conf

# Partiels partagés
COPY header.html /usr/share/nginx/html/header.html
COPY footer.html /usr/share/nginx/html/footer.html

# Pages du site
COPY nixiam-landing.html /usr/share/nginx/html/index.html
COPY mentions-legales.html /usr/share/nginx/html/mentions-legales.html
COPY politique-confidentialite.html /usr/share/nginx/html/politique-confidentialite.html
COPY contact.html /usr/share/nginx/html/contact.html
COPY 404.html /usr/share/nginx/html/404.html

# Autres assets
COPY favicon.svg /usr/share/nginx/html/favicon.svg
