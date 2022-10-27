FROM nginx:1.23-alpine

# Remove default conf
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom conf in the image
COPY docker/nginx/nginx.conf /etc/nginx/conf.d
