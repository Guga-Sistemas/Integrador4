from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *
from ..filters import TaskFilter
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.permissions import IsAuthenticated
from ..utils import is_Admin

class TaskView(ReadWriteSerializer, ModelViewSet):
    queryset = Task.objects.all()
    read_serializer_class = TaskReadSerializer
    write_serializer_class = TaskWriteSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_class = TaskFilter
    permission_classes = [IsAuthenticated]

    # def get_queryset(self):
    #     user = self.request.user

    #     if user.is_authenticated:
    #         return Task.objects.all() if is_Admin(user.id) else \
    #                Task.objects.filter(creator_FK=user.id)
    #     return Task.objects.none()

    