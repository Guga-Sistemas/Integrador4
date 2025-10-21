from rest_framework import serializers
from ..models import *

class TaskReadSerializer(serializers.ModelSerializer):
    from .custom_user import CustomUserSerializer
    from .equipment import EquipmentSerializer
    creator_FK = CustomUserSerializer()
    equipments_FK = EquipmentSerializer(many=True)
    responsibles_FK = CustomUserSerializer(many=True)
    
    class Meta:
        model = Task
        fields = '__all__'
        many= True

class TaskWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = '__all__'
        many= True