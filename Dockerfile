FROM ubuntu:16.04

# --- Python Installation ---
RUN apt-get update -y && apt-get install -y python3 gcc python3-dev musl-dev python3-pip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# --- Work Directory ---
WORKDIR /usr/src/app

# --- Python Setup ---
ADD . .
RUN pip install -r app/requirements.pip

# --- Nginx Setup ---
COPY config/nginx/default.conf /etc/nginx/conf.d/
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
RUN addgroup nginx root

# --- Expose and CMD ---
EXPOSE 8081
CMD gunicorn --bind 0.0.0.0:5000 wsgi --chdir /usr/src/app/app & nginx -g "daemon off;"