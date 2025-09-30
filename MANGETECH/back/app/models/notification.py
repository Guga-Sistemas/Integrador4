from django.db import models

class Notification(models.Model):
    text = models.CharField(max_length=500)
    task_FK = models.ForeignKey('Task', 
                                related_name='Notification_task_FK',
                                on_delete=models.CASCADE)
    user_FK = models.ForeignKey('CustomUser', 
                                related_name='Notification_user_FK',
                                on_delete=models.SET_NULL,
                                null=True)
    creation_date = models.DateTimeField(auto_now_add=True)
    notification_read = models.BooleanField(default=False)

    def __str__(self):
        return self.task_FK.name
