FROM nginx:latest

RUN apt update && apt install -y \
    nginx \
    python3 \
    python3-pip \
    libpq-dev \
    # postgresql \
    # postgresql-contrib \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --upgrade pip

WORKDIR /usr/src/code

COPY ./backend/requirements.txt .
RUN pip3 install -r requirements.txt
COPY ./backend/ /usr/src/code/

RUN python3 manage.py makemigrations \
    && python3 manage.py migrate \
    && python3 manage.py collectstatic --noinput
# ENTRYPOINT [ "python3", "manage.py", "runserver", "0.0.0.0:80" ]
ENTRYPOINT [ "gunicorn", "--bind=0.0.0.0:8000", "config.wsgi:application"]

# WORKDIR /etc/systemd/system

# COPY ./gunicorn/gunicorn.servece .

# RUN systemctl start gunicorn \
#     && systemclt enable gunicorn



EXPOSE 80
