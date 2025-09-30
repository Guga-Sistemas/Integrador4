from django.db import models

class URGENCY_LEVELS(models.TextChoices):
    LOW = 'LOW', 'low'
    MEDIUM = 'MEDIUM', 'medium'
    HIGH = 'HIGH', 'high'
    EXTRA_HIGH = 'EXTRA_HIGH', 'extra_high'


class Task(models.Model):
    name = models.CharField(max_length=150)
    description = models.CharField(max_length=1000)
    suggested_date = models.DateTimeField()
    urgency_level = models.CharField(max_length=50, 
                                     choices=URGENCY_LEVELS.choices,
                                     default=URGENCY_LEVELS.LOW)
    creation_date = models.DateTimeField(auto_now_add=True)
    creator_FK = models.ForeignKey('CustomUser', 
                                related_name='Task_creator_FK',
                                on_delete=models.SET_NULL,
                                null=True)
    equipments_FK = models.ManyToManyField('Equipment')
    responsibles_FK = models.ManyToManyField('CustomUser')

    def __str__(self):
        return self.name