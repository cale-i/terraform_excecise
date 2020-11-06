FROM nginx:latest

RUN apt update && apt install -y \
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
    && python3 manage.py collectstatic

ENTRYPOINT [ "python3", "manage.py", "runserver", "0.0.0.0:80" ]
EXPOSE 80
