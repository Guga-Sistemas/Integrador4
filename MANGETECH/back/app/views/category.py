from rest_framework.viewsets import ModelViewSet
from ..models import *
from ..serializers import *

class CategoryView(ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer