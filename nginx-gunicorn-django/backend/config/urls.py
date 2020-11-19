from django.contrib import admin
from django.urls import path
from django.conf.urls import include
from django.conf.urls import re_path
from django.views.generic import TemplateView
from django.views.generic import RedirectView


from django.conf import settings


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('apiv1.urls')),
    # path('example/', include('example.urls')),
    path('', TemplateView.as_view(template_name='index.html')),

]

if settings.DEBUG:
    import debug_toolbar

    urlpatterns += [
        path('__debug__/', include(debug_toolbar.urls)),
    ]
