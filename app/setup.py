import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))

tests_require = [ 'nose', 'coverage', 'virtualenv'] 

requires = ['pymongo', 'bottle', 'jinja2']

setup(name='top-nyc-restaurants-submission',
      version='0.1',
      description='orchard code sample',
      classifiers=[
          "Programming Language :: Python", ],
      author='',
      author_email='',
      url='',
      keywords='web orchard etl',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      tests_require=tests_require,
      test_suite='nose.collector',
      install_requires=requires,
      )
