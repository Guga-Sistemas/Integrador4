from .models import CustomUser

def check_group(group_name,user_id)-> bool:
    try:        
        custom_user = CustomUser.objects.get(id=user_id)
        return custom_user.groups.filter(name=group_name).exists()
    except CustomUser.DoesNotExist:
        return False

def is_Admin(user_id)-> bool:
    return check_group('ADMIN',user_id)
