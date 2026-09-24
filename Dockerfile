FROM nginx:alpine

# Config nginx (active les Server Side Includes pour header.html / footer.html)
COPY default.conf /etc/nginx/conf.d/default.conf

# Partiels partagés
COPY header.html /usr/share/nginx/html/header.html
COPY footer.html /usr/share/nginx/html/footer.html
COPY calc-widget.html /usr/share/nginx/html/calc-widget.html

# Pages du site
COPY nixiam-landing.html /usr/share/nginx/html/index.html
COPY mentions-legales.html /usr/share/nginx/html/mentions-legales.html
COPY politique-confidentialite.html /usr/share/nginx/html/politique-confidentialite.html
COPY contact.html /usr/share/nginx/html/contact.html
COPY comment-ca-marche.html /usr/share/nginx/html/comment-ca-marche.html
COPY offre-essentiel.html /usr/share/nginx/html/offre-essentiel.html
COPY offre-business.html /usr/share/nginx/html/offre-business.html
COPY tarifs.html /usr/share/nginx/html/tarifs.html
COPY calculateur.html /usr/share/nginx/html/calculateur.html
COPY faq.html /usr/share/nginx/html/faq.html
COPY 404.html /usr/share/nginx/html/404.html

# Autres assets
COPY favicon.svg /usr/share/nginx/html/favicon.svg
COPY robots.txt /usr/share/nginx/html/robots.txt
COPY sitemap.xml /usr/share/nginx/html/sitemap.xml
COPY og-image.png /usr/share/nginx/html/og-image.png
