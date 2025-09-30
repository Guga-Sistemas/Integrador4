from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class NotificationView(ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer