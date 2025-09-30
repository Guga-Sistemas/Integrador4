from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class TaskView(ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer