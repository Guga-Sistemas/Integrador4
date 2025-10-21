from rest_framework import serializers
from ..models import *

class EquipmentSerializer(serializers.ModelSerializer):
    from .environment import EnvironmentSerializer
    from .category import CategorySerializer

    # environment_FK = EnvironmentSerializer()
    environment_FK = EnvironmentSerializer()
    category_FK = serializers.SlugRelatedField(slug_field="name",
                                               read_only=True)

    # category_FK = CategorySerializer()
    class Meta:
        model = Equipment
        fields = '__all__'
        many= True