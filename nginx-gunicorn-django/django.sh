#!/bin/bash
mkdir backend
cd backend
pip install -U pip
pip install -r requirements.txt
django-admin.py startproject config .
