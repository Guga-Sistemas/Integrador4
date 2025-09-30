from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class CustomUserView(ModelViewSet):
    queryset = CustomUser.objects.all()
    serializer_class = CustomUserSerializer