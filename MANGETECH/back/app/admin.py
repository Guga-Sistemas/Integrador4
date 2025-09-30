from django.contrib import admin
from .models import *
from django.contrib.auth.admin import UserAdmin

class AdminCustomUser(UserAdmin):
    model = CustomUser
    list_display = ['id', 'email', 'nif']
    list_display_links = ('id', 'email', 'nif',)
    fieldsets = (
        (None, {'fields': ('email','password')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 
                                    'is_superuser', 'groups', 
                                    'user_permissions',)}),
        ('User data', {'fields': ('nif', 'phone','creation_date',)}),
    )
    filter_horizontal = ('groups', 'user_permissions',)
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email','name','nif','password1','password2'),
        }),
    )
    ordering = ['email']

admin.site.register(CustomUser, AdminCustomUser)
admin.site.register(Environment)
admin.site.register(Category)
admin.site.register(Equipment)
admin.site.register(Task)
admin.site.register(TaskStatus)
admin.site.register(TaskStatusImage)
admin.site.register(Notification)
