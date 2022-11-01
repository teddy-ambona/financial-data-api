FROM nginx:1.23-alpine as base

# Remove default conf
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom conf in the image
# In this official Docker image the configuration files are located at: /etc/nginx/
# and the main configuration file is /etc/nginx/nginx.conf. At the bottom of
# /etc/nginx/nginx.conf is a line to include any additional configuration files located
# in the /etc/nginx/conf.d/ directory: "include /etc/nginx/conf.d/*.conf;"

# Since we are running the local stack with docker-compose, the hostname of the gunicorn container
# is going to be "flask-app" and not "localhost" like on ECS.Hence the need to copy in the right
# config for the right environment.
FROM base as image-local

COPY docker/nginx/nginx.local.conf /etc/nginx/conf.d

FROM base as image-ecs

COPY docker/nginx/nginx.ecs.conf /etc/nginx/conf.d
