import multiprocessing

# Detailed explanation on https://realpython.com/django-nginx-gunicorn

# Flask WSGI application path in pattern MODULE_NAME:VARIABLE_NAME
wsgi_app = "src.app:create_app()"

# The number of worker processes for handling requests
workers = multiprocessing.cpu_count() * 2 + 1

# The socket to bind
bind = "0.0.0.0:5000"

# Write access and error info to /var/log
accesslog = "/var/log/gunicorn/access.log"
errorlog = "/var/log/gunicorn/error.log"

# Redirect stdout/stderr to log file
capture_output = True

# PID file so you can easily fetch process ID
pidfile = "/var/run/gunicorn/gunicorn.pid"

# Daemonize the Gunicorn process (detach & enter background)
daemon = True

# explanation about the --timeout argument below
# https://github.com/benoitc/gunicorn/issues/1801
timeout = 1000
