FROM nginx:latest

RUN apt update && apt install -y \
    python3 \
    python3-pip \
    libpq-dev \
    postgresql \
    # postgresql-contrib \
    vim \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /usr/src/app

COPY . /usr/src/app

RUN python3 -m pip install --no-cache-dir --upgrade pip

RUN pip3 install -r requirements.txt

# RUN python3 manage.py makemigrations \
#     && python3 manage.py migrate \
#     && python3 manage.py collectstatic --noinput

RUN mkdir -p /var/run/gunicorn
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT [ "/bin/bash", "/usr/src/app/startup.sh" ]
EXPOSE 80
