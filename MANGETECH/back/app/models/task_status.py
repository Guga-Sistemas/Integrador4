from django.db import models


class STATUS(models.TextChoices):
    OPEN = 'OPEN'
    WAITING_RESPONSIBLE = 'WAITING_RESPONSIBLE'
    ONGOING = 'ONGOING'
    DONE = 'DONE'
    FINISHED = 'FINISHED'
    CANCELLED = 'CANCELLED'


class TaskStatus(models.Model):
    status = models.CharField(max_length=50, 
                              choices=STATUS.choices,
                              default=STATUS.OPEN)
    status_date = models.DateTimeField(auto_now_add=True)
    comment = models.CharField(max_length=300, null=True, blank=True)
    task_FK = models.ForeignKey('Task', 
                                related_name='TaskStatus_task_FK',
                                on_delete=models.CASCADE)
    user_FK = models.ForeignKey('CustomUser', 
                                related_name='TaskStatus_user_FK',
                                on_delete=models.SET_NULL,
                                null=True)
    
    def __str__(self):
        return self.status
    

class TaskStatusImage(models.Model):
    image = models.FileField(upload_to="task_images")
    task_status_FK = models.ForeignKey('TaskStatus', 
                                related_name='TaskStatusImage_task_status_FK',
                                on_delete=models.CASCADE)
    def __str__(self):
        return self.task_status_FK.status