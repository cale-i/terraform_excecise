from django.urls import path, include

from apiv1 import views

app_name = 'apiv1'
urlpatterns = [
    path('list/books/', views.BookListAPIView.as_view()),
    path('retrieve/books/<pk>/', views.BookRetrieveAPIView.as_view()),
    path('post/books/', views.BookCreateAPIView.as_view()),
    path('update/books/<pk>/', views.BookUpdateAPIView.as_view()),
    path('delete/books/<pk>/', views.BookDestroyAPIView.as_view()),

]
