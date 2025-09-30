from django.db import models

class Equipment(models.Model):
    name = models.CharField(max_length=150)
    code = models.CharField(max_length=50)
    description = models.CharField(max_length=500)
    creation_date = models.DateTimeField(auto_now_add=True)
    category_FK = models.ForeignKey('Category', 
                                related_name='Equipment_category_FK',
                                on_delete=models.SET_NULL,
                                null=True)
    environment_FK = models.ForeignKey('Environment', 
                                related_name='Equipment_environment_FK',
                                on_delete=models.SET_NULL,
                                null=True)

    def __str__(self):
        return self.name
# description
# category_FK
# environment_FK

