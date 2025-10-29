from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ChamadoViewSet,
    ComentarioViewSet,
    AtivoViewSet,
    UserViewSet,
    register_user,
    login_user,
    logout_user,
    recuperar_senha,
    export_chamados_csv,
    bulk_delete_chamados,
    dashboard_gerencial
)

# Router para ViewSets
router = DefaultRouter()
router.register(r'chamados', ChamadoViewSet, basename='chamado')
router.register(r'comentarios', ComentarioViewSet, basename='comentario')
router.register(r'ativos', AtivoViewSet, basename='ativo')
router.register(r'usuarios', UserViewSet, basename='usuario')

urlpatterns = [
    # Incluir rotas do router
    path('', include(router.urls)),
    
    # ========== AUTENTICAÇÃO ==========
    path('auth/register/', register_user, name='register'),
    path('auth/login/', login_user, name='login'),
    path('auth/logout/', logout_user, name='logout'),
    path('auth/recuperar-senha/', recuperar_senha, name='recuperar-senha'),
    
    # ========== CHAMADOS ==========
    path('chamados/export/', export_chamados_csv, name='export-chamados-csv'),
    path('chamados/bulk-delete/', bulk_delete_chamados, name='bulk-delete-chamados'),
    
    # ========== DASHBOARD ==========
    path('dashboard/gerencial/', dashboard_gerencial, name='dashboard-gerencial'),
]