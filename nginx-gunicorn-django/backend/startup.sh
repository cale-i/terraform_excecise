#!/bin/bash
service nginx start
gunicorn config.wsgi:application --bind=unix:/var/run/gunicorn/gunicorn.sock