#!/bin/bash
cd /usr/src/app
# sed -i -e "s/^DATABASE_URL.*/DATABASE_URL=postgresql:\/\/testuser:password@${POSTGRESQL_HOST}\/testdb/g" /usr/src/app/.env
sed -i -e "s/^DATABASE_URL.*/DATABASE_URL=postgresql:\/\/${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}\/${POSTGRES_DB}/g" /usr/src/app/.env
cat .env
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput
service nginx start
gunicorn config.wsgi:application --bind=unix:/var/run/gunicorn/gunicorn.sock