import csv
from django.http import HttpResponse
from django.core.exceptions import ValidationError
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.db.models import Q, Count

from rest_framework import viewsets, filters, status
from rest_framework.decorators import api_view, action, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token

from django_filters.rest_framework import DjangoFilterBackend

from .models import (
    Chamado, 
    ChamadoStatusHistory,
    ChamadoStatusImage,
    ChamadoAnexo,
    Comentario,
    Ativo,
    AtivoHistorico
)
from .serializers import (
    ChamadoReadSerializer,
    ChamadoWriteSerializer,
    MudarStatusSerializer,
    ComentarioSerializer,
    CriarComentarioSerializer,
    AtivoSerializer,
    UserSerializer,
    UserRegistrationSerializer,
    UserLoginSerializer
)


# ========== AUTENTICAÇÃO ==========

@api_view(['POST'])
@permission_classes([AllowAny])
def register_user(request):
    """Cadastro de novo usuário"""
    serializer = UserRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        user = serializer.save()
        token, _ = Token.objects.get_or_create(user=user)
        
        return Response({
            'success': True,
            'message': 'Usuário criado com sucesso!',
            'user': UserSerializer(user).data,
            'token': token.key
        }, status=status.HTTP_201_CREATED)
    
    return Response({
        'success': False,
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_user(request):
    """Login de usuário"""
    serializer = UserLoginSerializer(data=request.data)
    
    if serializer.is_valid():
        email = serializer.validated_data['email']
        senha = serializer.validated_data['senha']
        
        try:
            user = User.objects.get(email=email)
            user = authenticate(username=user.username, password=senha)
            
            if user:
                token, _ = Token.objects.get_or_create(user=user)
                
                return Response({
                    'success': True,
                    'message': 'Login realizado com sucesso!',
                    'user': UserSerializer(user).data,
                    'token': token.key
                })
            else:
                return Response({
                    'success': False,
                    'message': 'Email ou senha incorretos'
                }, status=status.HTTP_401_UNAUTHORIZED)
        
        except User.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Email ou senha incorretos'
            }, status=status.HTTP_401_UNAUTHORIZED)
    
    return Response({
        'success': False,
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def logout_user(request):
    """Logout de usuário"""
    if request.user.is_authenticated:
        Token.objects.filter(user=request.user).delete()
        return Response({
            'success': True,
            'message': 'Logout realizado com sucesso'
        })
    
    return Response({
        'success': False,
        'message': 'Usuário não autenticado'
    }, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def recuperar_senha(request):
    """Solicitar recuperação de senha"""
    email = request.data.get('email')
    
    if not email:
        return Response({
            'success': False,
            'message': 'Email é obrigatório'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = User.objects.get(email=email)
        # Aqui você implementaria o envio de email real
        # Por enquanto, apenas simula
        
        return Response({
            'success': True,
            'message': 'Instruções enviadas para o email'
        })
    
    except User.DoesNotExist:
        # Por segurança, não revela se o email existe ou não
        return Response({
            'success': True,
            'message': 'Se o email existir, instruções serão enviadas'
        })


# ========== CHAMADOS ==========

class ChamadoViewSet(viewsets.ModelViewSet):
    """ViewSet para Chamados com métodos personalizados"""
    
    queryset = Chamado.objects.all().select_related(
        'solicitante'
    ).prefetch_related(
        'responsaveis',
        'historico',
        'comentarios',
        'anexos'
    ).order_by('-data_criacao')
    
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'urgencia', 'ambiente', 'solicitante']
    search_fields = ['titulo', 'descricao', 'ativo', 'id']
    ordering_fields = ['data_criacao', 'urgencia', 'status', 'data_atualizacao']
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return ChamadoWriteSerializer
        return ChamadoReadSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        user = self.request.user
        
        # Filtrar por usuário se não for admin
        if not user.is_staff and user.is_authenticated:
            queryset = queryset.filter(
                Q(solicitante=user) | Q(responsaveis=user)
            ).distinct()
        
        return queryset
    
    def perform_create(self, serializer):
        """Criar chamado e definir solicitante automaticamente"""
        chamado = serializer.save(solicitante=self.request.user)
        
        # Criar histórico inicial
        ChamadoStatusHistory.objects.create(
            chamado=chamado,
            status=chamado.status,
            descricao=f"Chamado criado: {chamado.titulo}",
            usuario=self.request.user
        )
    
    @action(detail=True, methods=['post'])
    def mudar_status(self, request, pk=None):
        """Endpoint para mudar status do chamado"""
        chamado = self.get_object()
        serializer = MudarStatusSerializer(data=request.data)
        
        if serializer.is_valid():
            novo_status = serializer.validated_data['status']
            descricao = serializer.validated_data['descricao']
            fotos = serializer.validated_data.get('fotos', [])
            
            # Atualizar status do chamado
            chamado.status = novo_status
            chamado.save()
            
            # Criar histórico
            historico = ChamadoStatusHistory.objects.create(
                chamado=chamado,
                status=novo_status,
                descricao=descricao,
                usuario=request.user
            )
            
            # Adicionar fotos se houver
            for foto in fotos:
                ChamadoStatusImage.objects.create(
                    historico=historico,
                    imagem=foto
                )
            
            return Response({
                'success': True,
                'message': 'Status atualizado com sucesso',
                'chamado': ChamadoReadSerializer(chamado, context={'request': request}).data
            })
        
        return Response({
            'success': False,
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'])
    def adicionar_comentario(self, request, pk=None):
        """Endpoint para adicionar comentário"""
        chamado = self.get_object()
        serializer = CriarComentarioSerializer(data=request.data)
        
        if serializer.is_valid():
            comentario = serializer.save(
                chamado=chamado,
                autor=request.user
            )
            
            return Response({
                'success': True,
                'message': 'Comentário adicionado com sucesso',
                'comentario': ComentarioSerializer(comentario).data
            })
        
        return Response({
            'success': False,
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=True, methods=['post'])
    def adicionar_anexo(self, request, pk=None):
        """Endpoint para adicionar anexo"""
        chamado = self.get_object()
        arquivo = request.FILES.get('arquivo')
        
        if not arquivo:
            return Response({
                'success': False,
                'message': 'Nenhum arquivo enviado'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        anexo = ChamadoAnexo.objects.create(
            chamado=chamado,
            arquivo=arquivo,
            nome_original=arquivo.name
        )
        
        return Response({
            'success': True,
            'message': 'Anexo adicionado com sucesso',
            'anexo': {
                'id': anexo.id,
                'nome': anexo.nome_original,
                'url': request.build_absolute_uri(anexo.arquivo.url)
            }
        })
    
    @action(detail=False, methods=['get'])
    def estatisticas(self, request):
        """Endpoint para dashboard gerencial"""
        user = request.user
        
        # Filtrar por usuário se não for admin
        queryset = Chamado.objects.all()
        if not user.is_staff:
            queryset = queryset.filter(
                Q(solicitante=user) | Q(responsaveis=user)
            ).distinct()
        
        # Total de chamados
        total = queryset.count()
        
        # Chamados por status
        por_status = queryset.values('status').annotate(
            total=Count('id')
        ).order_by('status')
        
        # Chamados por urgência
        por_urgencia = queryset.values('urgencia').annotate(
            total=Count('id')
        ).order_by('urgencia')
        
        # Chamados críticos abertos
        criticos_abertos = queryset.filter(
            urgencia__in=['Crítico', 'Alta'],
            status__in=['ABERTO', 'EM ANDAMENTO', 'AGUARDANDO RESP']
        ).count()
        
        # Chamados do mês
        from django.utils import timezone
        mes_atual = timezone.now().replace(day=1, hour=0, minute=0, second=0)
        chamados_mes = queryset.filter(data_criacao__gte=mes_atual).count()
        
        return Response({
            'total_chamados': total,
            'por_status': list(por_status),
            'por_urgencia': list(por_urgencia),
            'criticos_abertos': criticos_abertos,
            'chamados_mes': chamados_mes,
        })


@api_view(['GET'])
def export_chamados_csv(request):
    """Exporta todos os chamados em CSV"""
    response = HttpResponse(content_type='text/csv; charset=utf-8')
    response['Content-Disposition'] = 'attachment; filename="chamados.csv"'
    
    # BOM para UTF-8
    response.write('\ufeff')
    
    writer = csv.writer(response)
    writer.writerow([
        'ID', 'Título', 'Descrição', 'Ativo', 'Ambiente', 
        'Solicitante', 'Responsáveis', 'Urgência', 'Status', 
        'Data Criação', 'Data Sugerida'
    ])

    chamados = Chamado.objects.all()
    for c in chamados:
        responsaveis = ", ".join([
            r.get_full_name() or r.username 
            for r in c.responsaveis.all()
        ])
        
        writer.writerow([
            f"#{c.id}",
            c.titulo,
            c.descricao,
            c.ativo,
            c.ambiente,
            c.solicitante.get_full_name() if c.solicitante else "",
            responsaveis,
            c.urgencia,
            c.status,
            c.data_criacao.strftime("%d/%m/%Y %H:%M"),
            c.data_sugerida.strftime("%d/%m/%Y %H:%M") if c.data_sugerida else ""
        ])

    return response


@api_view(['POST'])
def bulk_delete_chamados(request):
    """
    Recebe uma lista de IDs e tenta deletar os chamados.
    Chamados em andamento não serão deletados.
    """
    ids = request.data.get('ids', [])
    if not ids:
        return Response({
            "success": False,
            "error": "Nenhum ID fornecido."
        }, status=status.HTTP_400_BAD_REQUEST)

    success = []
    errors = []

    for cid in ids:
        try:
            chamado = Chamado.objects.get(id=cid)
            chamado.delete()
            success.append(cid)
        except Chamado.DoesNotExist:
            errors.append({"id": cid, "error": "Chamado não encontrado"})
        except ValidationError as e:
            errors.append({"id": cid, "error": str(e)})

    return Response({
        "success": True,
        "deleted": success, 
        "errors": errors
    })


# ========== COMENTÁRIOS ==========

class ComentarioViewSet(viewsets.ModelViewSet):
    """ViewSet para Comentários"""
    
    queryset = Comentario.objects.all().select_related(
        'autor', 'chamado'
    ).order_by('-data_criacao')
    
    serializer_class = ComentarioSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['chamado', 'autor']
    
    def perform_create(self, serializer):
        serializer.save(autor=self.request.user)


# ========== ATIVOS ==========

class AtivoViewSet(viewsets.ModelViewSet):
    """ViewSet para Ativos/Equipamentos"""
    
    queryset = Ativo.objects.all().order_by('nome')
    serializer_class = AtivoSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'ambiente']
    search_fields = ['codigo', 'nome', 'modelo', 'fabricante', 'numero_serie']
    ordering_fields = ['nome', 'data_cadastro', 'status']
    
    @action(detail=True, methods=['get'])
    def por_qrcode(self, request, pk=None):
        """Buscar ativo por código QR"""
        codigo = pk
        
        try:
            ativo = Ativo.objects.get(codigo=codigo)
            return Response({
                'success': True,
                'ativo': AtivoSerializer(ativo, context={'request': request}).data
            })
        except Ativo.DoesNotExist:
            return Response({
                'success': False,
                'message': 'Ativo não encontrado'
            }, status=status.HTTP_404_NOT_FOUND)
    
    @action(detail=True, methods=['get'])
    def chamados(self, request, pk=None):
        """Listar chamados relacionados ao ativo"""
        ativo = self.get_object()
        
        chamados = Chamado.objects.filter(
            ativo__icontains=ativo.codigo
        ).order_by('-data_criacao')
        
        serializer = ChamadoReadSerializer(
            chamados, 
            many=True, 
            context={'request': request}
        )
        
        return Response({
            'success': True,
            'chamados': serializer.data
        })
    
    @action(detail=True, methods=['post'])
    def adicionar_historico(self, request, pk=None):
        """Adicionar movimentação ao histórico do ativo"""
        ativo = self.get_object()
        
        tipo = request.data.get('tipo')
        descricao = request.data.get('descricao')
        
        if not tipo or not descricao:
            return Response({
                'success': False,
                'message': 'Tipo e descrição são obrigatórios'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        historico = AtivoHistorico.objects.create(
            ativo=ativo,
            tipo=tipo,
            descricao=descricao,
            usuario=request.user
        )
        
        return Response({
            'success': True,
            'message': 'Histórico adicionado com sucesso'
        })


# ========== USUÁRIOS ==========

class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet para listar usuários (apenas leitura)"""
    
    queryset = User.objects.all().order_by('username')
    serializer_class = UserSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['username', 'first_name', 'last_name', 'email']
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        """Retorna dados do usuário autenticado"""
        if request.user.is_authenticated:
            return Response({
                'success': True,
                'user': UserSerializer(request.user).data
            })
        
        return Response({
            'success': False,
            'message': 'Usuário não autenticado'
        }, status=status.HTTP_401_UNAUTHORIZED)


# ========== DASHBOARD GERENCIAL ==========

@api_view(['GET'])
def dashboard_gerencial(request):
    """
    Endpoint completo para dashboard gerencial com todas as métricas
    """
    user = request.user
    
    # Filtrar por usuário se não for admin
    queryset = Chamado.objects.all()
    if not user.is_staff:
        queryset = queryset.filter(
            Q(solicitante=user) | Q(responsaveis=user)
        ).distinct()
    
    # KPIs principais
    total_chamados = queryset.count()
    
    abertos = queryset.filter(status='ABERTO').count()
    em_andamento = queryset.filter(status='EM ANDAMENTO').count()
    aguardando = queryset.filter(status='AGUARDANDO RESP').count()
    realizado = queryset.filter(status='REALIZADO').count()
    concluido = queryset.filter(status='CONCLUÍDO').count()
    cancelado = queryset.filter(status='CANCELADO').count()
    
    # Chamados críticos
    criticos = queryset.filter(
        urgencia__in=['Crítico', 'Alta'],
        status__in=['ABERTO', 'EM ANDAMENTO', 'AGUARDANDO RESP']
    )
    
    criticos_detalhes = ChamadoReadSerializer(
        criticos[:10], 
        many=True,
        context={'request': request}
    ).data
    
    # Chamados por urgência
    por_urgencia = {
        'critico': queryset.filter(urgencia='Crítico').count(),
        'alta': queryset.filter(urgencia='Alta').count(),
        'media': queryset.filter(urgencia='Média').count(),
        'baixa': queryset.filter(urgencia='Baixa').count(),
    }
    
    # Tempo médio de resolução (simplificado)
    # Você pode implementar cálculo mais complexo depois
    tempo_medio = "4.2h"
    
    # Chamados do período
    from django.utils import timezone
    from datetime import timedelta
    
    hoje = timezone.now()
    ultimos_7_dias = queryset.filter(
        data_criacao__gte=hoje - timedelta(days=7)
    ).count()
    
    ultimos_30_dias = queryset.filter(
        data_criacao__gte=hoje - timedelta(days=30)
    ).count()
    
    ultimos_90_dias = queryset.filter(
        data_criacao__gte=hoje - timedelta(days=90)
    ).count()
    
    # Distribuição por tempo de resolução (mock)
    # Você pode implementar cálculo real depois
    tempo_resolucao = {
        'menos_1h': 120,
        '1_2h': 210,
        '2_4h': 350,
        '4_8h': 280,
        '8_12h': 150,
        '12_24h': 90,
        'mais_24h': 48
    }
    
    return Response({
        'success': True,
        'data': {
            'kpis': {
                'total_chamados': total_chamados,
                'abertos': abertos,
                'em_andamento': em_andamento,
                'aguardando': aguardando,
                'realizado': realizado,
                'concluido': concluido,
                'cancelado': cancelado,
                'criticos_abertos': criticos.count(),
                'tempo_medio': tempo_medio,
            },
            'por_status': {
                'aberto': abertos,
                'em_andamento': em_andamento,
                'aguardando': aguardando,
                'realizado': realizado,
                'concluido': concluido,
                'cancelado': cancelado,
            },
            'por_urgencia': por_urgencia,
            'periodo': {
                'ultimos_7_dias': ultimos_7_dias,
                'ultimos_30_dias': ultimos_30_dias,
                'ultimos_90_dias': ultimos_90_dias,
            },
            'tempo_resolucao': tempo_resolucao,
            'criticos': criticos_detalhes,
        }
    })