from rest_framework import serializers

from example.models import Book


class BookSerializer(serializers.ModelSerializer):
    """本モデル用のシリアライザ"""

    class Meta:
        model = Book
        fields = '__all__'
