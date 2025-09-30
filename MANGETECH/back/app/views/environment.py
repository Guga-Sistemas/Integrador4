from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class EnvironmentView(ModelViewSet):
    queryset = Environment.objects.all()
    serializer_class = EnvironmentSerializer