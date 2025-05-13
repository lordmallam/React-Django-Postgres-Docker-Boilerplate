from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from . import models, serializers, permissions
from .models import User
from .serializers import UserSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = models.User.objects.all()
    serializer_class = serializers.UserSerializer

    def get_permissions(self):
        permission_classes = []
        if self.action == 'create':
            permission_classes = [AllowAny]
        elif self.action == 'retrieve' or self.action == 'update' or self.action == 'partial_update':
            permission_classes = [permissions.IsLoggedInUserOrAdmin]
        elif self.action == 'list' or self.action == 'destroy':
            permission_classes = [permissions.IsAdminUser]
        return [permission() for permission in permission_classes]

class SSOLoginSignupView(APIView):
    """
    Handles SSO login and signup.
    """

    def post(self, request, *args, **kwargs):
        sso_provider = request.data.get('sso_provider')
        sso_id = request.data.get('sso_id')
        email = request.data.get('email')
        first_name = request.data.get('first_name', '')
        last_name = request.data.get('last_name', '')

        if not sso_provider or not sso_id:
            return Response(
                {"error": "SSO provider and SSO ID are required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Check if the user already exists
        user = User.objects.filter(sso_provider=sso_provider, sso_id=sso_id).first()
        if user:
            # User exists, return their data
            serializer = UserSerializer(user, context={'request': request})
            return Response(serializer.data, status=status.HTTP_200_OK)

        # Create a new user for SSO
        user_data = {
            'email': email,
            'first_name': first_name,
            'last_name': last_name,
            'sso_provider': sso_provider,
            'sso_id': sso_id,
            'is_verified': True,  # Assume SSO users are verified
        }
        serializer = UserSerializer(data=user_data, context={'request': request})
        if serializer.is_valid():
            user = serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
