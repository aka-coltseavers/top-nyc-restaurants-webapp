from etl import etl

import unittest
from unittest import mock

class MockURL():
    def __init__(self):
        self.times_called = 0
        
    def read(self, size):
        if self.times_called < 2:
            self.times_called += 1
            return bytes("Abcd", "utf-8")
        else:
            return None

    def info(self):
        return {'Content-Length': '4'}

class EtlExtractTestCase(unittest.TestCase):
    
    @mock.patch('urllib.request.urlopen')
    def test_extract(self, mock_urllib):
        mock_url_content = MockURL()
        mock_urllib.return_value = mock_url_content
        test_etl = etl.Etl()
        test_etl.extract("any url","any.filename")
        # test that extract called etl.extract with the right parameters
        mock_urllib.assert_called_with("any url")


