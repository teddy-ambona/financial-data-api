FROM nginx:1.23-alpine

# Remove default conf
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom conf in the image
# In this official Docker image the configuration files are located at: /etc/nginx/
# and the main configuration file is /etc/nginx/nginx.conf. At the bottom of
# /etc/nginx/nginx.conf is a line to include any additional configuration files located
# in the /etc/nginx/conf.d/ directory: "include /etc/nginx/conf.d/*.conf;"
COPY docker/nginx/nginx.local.conf /etc/nginx/conf.d
