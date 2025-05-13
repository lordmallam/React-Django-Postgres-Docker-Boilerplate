from rest_framework import serializers
from .models import UserProfile, User


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ('dob', 'address', 'country', 'city', 'sex', 'photo')


class UserSerializer(serializers.HyperlinkedModelSerializer):
    url = serializers.HyperlinkedIdentityField(view_name="authentication:user-detail")

    class Meta:
        model = User
        fields = (
            'url', 'email', 'first_name', 'last_name', 'password', 'is_verified', 
            'is_enabled', 'username', 'profile', 'sso_provider', 'sso_id'
        )
        extra_kwargs = {
            'password': {'write_only': True, 'required': False},
            'is_verified': {'read_only': True},
            'is_enabled': {'read_only': True},
            'username': {'read_only': True},
            'profile': {'read_only': True},
            'sso_provider': {'read_only': True},
            'sso_id': {'read_only': True},
        }

    def create(self, validated_data):
        # Handle SSO signup
        sso_provider = validated_data.get('sso_provider')
        sso_id = validated_data.get('sso_id')

        if sso_provider and sso_id:
            # Ensure no duplicate SSO entries
            if User.objects.filter(sso_provider=sso_provider, sso_id=sso_id).exists():
                raise serializers.ValidationError("A user with this SSO provider and ID already exists.")
            user = User.objects.create(**validated_data)
        else:
            # Handle regular signup
            password = validated_data.pop('password', None)
            user = User(**validated_data)
            if password:
                user.set_password(password)
            user.save()

        return user

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', None)
        profile = instance.profile if hasattr(instance, 'profile') else None

        instance.first_name = validated_data.get('first_name', instance.first_name)
        instance.last_name = validated_data.get('last_name', instance.last_name)
        instance.save()

        if profile and profile_data:
            profile.sex = profile_data.get('sex', profile.sex)
            profile.dob = profile_data.get('dob', profile.dob)
            profile.address = profile_data.get('address', profile.address)
            profile.country = profile_data.get('country', profile.country)
            profile.city = profile_data.get('city', profile.city)
            profile.photo = profile_data.get('photo', profile.photo)
            profile.save()

        return instance