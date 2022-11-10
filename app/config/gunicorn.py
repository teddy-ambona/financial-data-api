import multiprocessing

# Detailed explanation on https://realpython.com/django-nginx-gunicorn
# Also check out the exhaustive example config
# https://github.com/benoitc/gunicorn/blob/master/examples/example_config.py

# The number of worker processes for handling requests
workers = multiprocessing.cpu_count() * 2 + 1

# The socket to bind
bind = "0.0.0.0:5000"

# Explanation about the --timeout argument below
# https://github.com/benoitc/gunicorn/issues/1801
timeout = 1000

# Log to stdout
logfile = "-"
loglevel = "info"
accesslog = '-'
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
