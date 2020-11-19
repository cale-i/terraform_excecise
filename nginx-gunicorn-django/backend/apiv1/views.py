from rest_framework import generics

from example.models import Book
from .serializers import BookSerializer


class BookListAPIView(generics.ListAPIView):
    """本モデルの一覧取得APIクラス"""

    queryset = Book.objects.all()
    serializer_class = BookSerializer


class BookRetrieveAPIView(generics.RetrieveAPIView):
    """本モデルの詳細取得APIクラス"""

    queryset = Book.objects.all()
    serializer_class = BookSerializer


class BookCreateAPIView(generics.CreateAPIView):
    """本モデルの登録APIクラス"""

    queryset = Book.objects.all()
    serializer_class = BookSerializer


class BookUpdateAPIView(generics.UpdateAPIView):
    """本モデルの更新・一部更新APIクラス"""

    queryset = Book.objects.all()
    serializer_class = BookSerializer


class BookDestroyAPIView(generics.DestroyAPIView):
    """本モデルの削除APIクラス"""

    queryset = Book.objects.all()
