#!/usr/bin/env python

from io import open
from setuptools import find_packages, setup


setup(
    version='1.0',
    name='django.api',
    description='A django app',

    url='http://www.trisiki.com',
    author='Lord-Mallam Nugwan',
    author_email='lordmallam@trisiki.com',
    license='Apache2 License',

    packages=find_packages(),
)