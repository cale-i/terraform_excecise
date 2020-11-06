from django.contrib import admin
from django.urls import path
from django.conf.urls import include
from django.conf.urls import re_path
from django.views.generic import TemplateView
from django.views.generic import RedirectView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', TemplateView.as_view(template_name='index.html')),
]
