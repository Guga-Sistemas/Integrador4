from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class EquipmentView(ModelViewSet):
    queryset = Equipment.objects.all()
    serializer_class = EquipmentSerializer