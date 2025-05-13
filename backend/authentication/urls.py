"""api URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from . import views

router = DefaultRouter()

router.register(r"users", views.UserViewSet)
# router.register(r"profiles", views.UserProfileViewSet)

urlpatterns = [
    
    path('auth/', include('dj_rest_auth.urls')),
    path('auth/social/', include('dj_rest_auth.urls')),  # Social auth endpoints
    path('auth/social/login/', include('allauth.urls')),  # Social login
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path("account/", include(router.urls)),
     path('account/sso/', views.SSOLoginSignupView.as_view(), name='sso-login-signup'),
]
