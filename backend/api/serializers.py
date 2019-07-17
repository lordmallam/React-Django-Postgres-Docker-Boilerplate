from rest_framework import serializers
from .models import Publisher, UserProfile, User

class PublisherSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = Publisher
        fields = '__all__'


class UserProfileSerializer(serializers.ModelSerializer):

    class Meta:
        model = UserProfile
        fields = ('dob', 'address', 'country', 'city', 'sex', 'photo')


class UserSerializer(serializers.HyperlinkedModelSerializer):
    profile = UserProfileSerializer(required=True)

    class Meta:
        model = User
        fields = ('url', 'email', 'first_name', 'last_name', 'password', 'profile')
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        profile_data = validated_data.pop('profile')
        password = validated_data.pop('password')
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        UserProfile.objects.create(user=user, **profile_data)
        return user

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile')
        profile = instance.profile

        instance.email = validated_data.get('email', instance.email)
        instance.save()

        profile.sex = profile_data.get('sex', profile.sex)
        profile.dob = profile_data.get('dob', profile.dob)
        profile.address = profile_data.get('address', profile.address)
        profile.country = profile_data.get('country', profile.country)
        profile.city = profile_data.get('city', profile.city)
        profile.photo = profile_data.get('photo', profile.photo)
        profile.save()

        return instance