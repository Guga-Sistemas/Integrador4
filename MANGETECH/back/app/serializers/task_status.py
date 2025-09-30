from rest_framework import serializers
from ..models import *

class TaskStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaskStatus
        fields = '__all__'
        many= True

class TaskStatusImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = TaskStatusImage
        fields = '__all__'
        many= True