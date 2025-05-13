import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _
from django.conf import settings

class User(AbstractUser):
    id = models.UUIDField(primary_key=True, unique=True, default=uuid.uuid4)
    username = models.CharField(blank=True, null=True, max_length=255)
    email = models.EmailField(_('Email Address'), unique=True)
    password = models.CharField(max_length=255)
    activation_key = models.CharField(_('Activation Key'), max_length=255, blank=True, null=True)
    is_verified = models.BooleanField(_('Verified'), default=False)
    is_enabled = models.BooleanField(_('Active'), default=False)
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['id', 'username', 'password']

    @property
    def hasProfile(self):
        return hasattr(self, 'profile')

    def __str__(self):
        return "{}".format(self.email)


class UserProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='profile'
    )
    sex = models.CharField(_('Sex'), max_length=20)
    dob = models.DateField(_('Date of Birth'), null=True, blank=True)
    address = models.CharField(_('Address'), max_length=255)
    country = models.CharField(max_length=50)
    city = models.CharField(max_length=50)
    photo = models.ImageField(upload_to='uploads', blank=True)
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)