from django.db import models

class Environment(models.Model):
    name = models.CharField(max_length=150)
    user_FK = models.ForeignKey('CustomUser', 
                                related_name='Environment_user_FK',
                                on_delete=models.CASCADE)
    
    def __str__(self):
        return self.name
