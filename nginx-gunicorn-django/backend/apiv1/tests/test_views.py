from django.contrib.auth import get_user_model
from django.utils.timezone import localtime
from rest_framework.test import APITestCase
import json

from example.models import Book


class TestBookListAPIView(APITestCase):
    """BookListAPIViewのテストクラス"""

    TARGET_URL = '/api/v1/list/books/'

    def test_list_success(self):
        """本モデルの一覧参照APIへのGETリクエスト(正常系)"""

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        response = self.client.get(
            self.TARGET_URL,
            format='json')

        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 1)

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 200)

        book = Book.objects.get()
        expected_json_dict = {
            'id': str(book.id),
            'title': book.title,
            'price': book.price,
            'created_at': str(localtime(book.created_at)).replace(' ', 'T'),
        }
        dict_content = json.loads(response.content)['results'][0]
        self.assertEqual(dict_content, expected_json_dict)

    # def test_list_bad_request(self):


class TestBookRetrieveAPIView(APITestCase):
    """BookRetrieveAPIViewのテストクラス"""

    TARGET_URL = '/api/v1/retrieve/books/{}/'

    def test_retrieve_success(self):
        """本モデルの詳細参照APIへのGETリクエスト(正常系)"""

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        response = self.client.get(
            self.TARGET_URL.format(book.id),
            format='json')
        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 1)

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 200)

        book = Book.objects.get()
        expected_json_dict = {
            'id': str(book.id),
            'title': book.title,
            'price': book.price,
            'created_at': str(localtime(book.created_at)).replace(' ', 'T'),
        }
        # dict_content = json.loads(response.content)
        self.assertJSONEqual(response.content, expected_json_dict)

    def test_retrieve_bad_request(self):
        """本モデルの詳細参照APIへのGETリクエスト(異常系: バリデーションNG)"""

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        book_id = book.id

        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 1)

        # データを削除
        book.delete()

        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 0)

        response = self.client.get(
            self.TARGET_URL.format(book_id),
            format='json')
        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 404)


class TestBookCreateAPIView(APITestCase):
    """BookCreateAPIViewのテストクラス"""

    TARGET_URL = '/api/v1/post/books/'

    def test_create_success(self):
        """本モデルの登録APIへのPOSTリクエスト(正常系)"""

        # APIリクエストを実行
        params = {
            'title': 'testtitle',
            'price': 1000,
        }
        response = self.client.post(self.TARGET_URL, params, format='json')
        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 1)

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 201)

        book = Book.objects.get()
        expected_json_dict = {
            'id': str(book.id),
            'title': book.title,
            'price': book.price,
            'created_at': str(localtime(book.created_at)).replace(' ', 'T'),
        }
        self.assertJSONEqual(response.content, expected_json_dict)

    def test_create_bad_request(self):
        """本モデルの公録APIへのPOSTリクエスト(異常系: バリデーションNG)"""

        # APIリクエストを実行
        params = {
            'title': '',
            'price': 1000,
        }

        response = self.client.post(self.TARGET_URL, params, format='json')

        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 0)

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 400)


class TestBookUpdateAPIView(APITestCase):
    """BookUpdateAPIViewのテストクラス"""

    TARGET_URL_WITH_PK = '/api/v1/update/books/{}/'

    @ classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.user = get_user_model().objects.create_user(
            username='user',
            email='user@example.com',
            password='password',
        )

    def test_update_success(self):
        """本モデル更新APIのへのPUTリクエスト(正常系)"""

        # ログイン(Cookie認証)
        self.client.login(username='user', password='password')

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        params = {
            'id': book.id,
            'title': 'modified_title',
            'price': 2000,
        }
        response = self.client.put(
            self.TARGET_URL_WITH_PK.format(book.id),
            params,
            format='json',
        )

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 200)
        book = Book.objects.get()
        expected_json_dict = {
            'id': str(book.id),
            'title': params['title'],
            'price': params['price'],
            'created_at': str(localtime(book.created_at)).replace(' ', 'T'),
        }
        self.assertJSONEqual(response.content, expected_json_dict)

    def test_update_bad_request(self):
        """本モデル更新APIのへのPUTリクエスト(異常系: バリデーションNG)"""

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        params = {
            'id': book.id,
            'title': '',
            'price': 2000,
        }
        response = self.client.put(
            self.TARGET_URL_WITH_PK.format(book.id),
            params,
            format='json',
        )

        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 1)

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 400)


class TestBookDestroyAPIView(APITestCase):
    """BookDestroyAPIViewのテストクラス"""

    TARGET_URL_WITH_PK = '/api/v1/delete/books/{}/'

    @ classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.user = get_user_model().objects.create_user(
            username='user',
            email='user@example.com',
            password='password',
        )

    def test_delete_success(self):
        """本モデル削除APIのへのDELETEリクエスト(正常系)"""

        # ログイン(Cookie認証)
        self.client.login(username='user', password='password')

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        response = self.client.delete(
            self.TARGET_URL_WITH_PK.format(book.id),
        )
        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 0)
        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 204)

    def test_delete_bad_request(self):
        """本モデル更新APIのへのDELETEリクエスト(異常系: バリデーションNG)"""

        # APIリクエストを実行
        book = Book.objects.create(
            title='sampletitle1',
            price=1000,
        )
        book.id = ''
        response = self.client.delete(
            self.TARGET_URL_WITH_PK.format(book.id),
        )
        # データベースの状態を検証
        self.assertEqual(Book.objects.count(), 1)

        # レスポンスの内容を検証
        self.assertEqual(response.status_code, 404)
