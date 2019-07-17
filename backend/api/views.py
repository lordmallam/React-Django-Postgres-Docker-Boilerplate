
from rest_framework import viewsets
from rest_framework.permissions import AllowAny
from . import models, serializers, permissions


class PublisherViewSet(viewsets.ModelViewSet):
    queryset = models.Publisher.objects.all()
    serializer_class = serializers.PublisherSerializer

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
