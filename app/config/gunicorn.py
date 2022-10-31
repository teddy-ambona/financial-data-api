import multiprocessing

# Detailed explanation on https://realpython.com/django-nginx-gunicorn

# The number of worker processes for handling requests
workers = multiprocessing.cpu_count() * 2 + 1

# The socket to bind
bind = "0.0.0.0:5000"

# Explanation about the --timeout argument below
# https://github.com/benoitc/gunicorn/issues/1801
timeout = 1000
