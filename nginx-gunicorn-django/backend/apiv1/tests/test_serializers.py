from django.test import TestCase
from django.utils.timezone import localtime

from example.models import Book
from apiv1.serializers import BookSerializer


class TestBookSerializer(TestCase):
    """BookSerializerのテストクラス"""

    def test_input_valid(self):
        """入力データのバリデーション(OK)"""

        # シリアライザを作成
        input_data = {
            'title': 'sample_title',
            'price': 1000,
        }
        serializer = BookSerializer(data=input_data)

        # バリデーションの結果を検証
        self.assertEqual(serializer.is_valid(), True)

    def test_input_invalid_if_title_is_blank(self):
        """入力データのバリデーション(NG: titleが空文字"""

        # シリアライザを作成
        input_data = {
            'title': '',
            'price': 1000,
        }
        serializer = BookSerializer(data=input_data)

        # バリデーションの結果を検証
        self.assertEqual(serializer.is_valid(), False)
        self.assertCountEqual(serializer.errors.keys(), ['title'])
        self.assertCountEqual(
            [e.code for e in serializer.errors['title']],
            ['blank'],
        )

    def test_output_data(self):
        """出力データの内容検証"""

        # シリアライザを作成
        book = Book.objects.create(
            title='sample_title',
            price=1000,
        )
        serializer = BookSerializer(instance=book)

        # シリアライザの出力内容を検証
        expected_data = {
            'id': str(book.id),
            'title': book.title,
            'price': book.price,
            'created_at': str(localtime(book.created_at)).replace(' ', 'T'),
        }
        self.assertDictEqual(serializer.data, expected_data)
