from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class TaskStatusView(ModelViewSet):
    queryset = TaskStatus.objects.all()
    serializer_class = TaskStatusSerializer

class TaskStatusImageView(ModelViewSet):
    queryset = TaskStatusImage.objects.all()
    serializer_class = TaskStatusImageSerializer