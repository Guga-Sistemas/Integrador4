from django.db import models
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError


class Chamado(models.Model):
    """Modelo principal de Chamado/Task"""
    
    STATUS_CHOICES = [
        ('ABERTO', 'Aberto'),
        ('AGUARDANDO RESP', 'Aguardando Responsáveis'),
        ('EM ANDAMENTO', 'Em Andamento'),
        ('REALIZADO', 'Realizado'),
        ('CONCLUÍDO', 'Concluído'),
        ('CANCELADO', 'Cancelado'),
    ]

    URGENCIA_CHOICES = [
        ('Crítico', 'Crítico'),
        ('Alta', 'Alta'),
        ('Média', 'Média'),
        ('Baixa', 'Baixa'),
    ]

    # Campos principais
    titulo = models.CharField(max_length=255, verbose_name="Título")
    descricao = models.TextField(verbose_name="Descrição")
    ativo = models.CharField(max_length=200, verbose_name="Ativo/Equipamento")
    ambiente = models.CharField(max_length=200, verbose_name="Ambiente", default="Não informado")
    
    # Usuários
    solicitante = models.ForeignKey(
        User, 
        related_name='chamados_solicitados', 
        on_delete=models.SET_NULL, 
        null=True,
        verbose_name="Solicitante"
    )
    responsaveis = models.ManyToManyField(
        User, 
        related_name='chamados_responsaveis', 
        blank=True,
        verbose_name="Responsáveis"
    )
    
    # Status e prioridade
    urgencia = models.CharField(
        max_length=20, 
        choices=URGENCIA_CHOICES,
        default='Média',
        verbose_name="Nível de Urgência"
    )
    status = models.CharField(
        max_length=30, 
        choices=STATUS_CHOICES,
        default='ABERTO',
        verbose_name="Status"
    )
    
    # Datas
    data_criacao = models.DateTimeField(auto_now_add=True, verbose_name="Data de Criação")
    data_sugerida = models.DateTimeField(null=True, blank=True, verbose_name="Data Sugerida")
    data_atualizacao = models.DateTimeField(auto_now=True, verbose_name="Última Atualização")
    
    class Meta:
        verbose_name = "Chamado"
        verbose_name_plural = "Chamados"
        ordering = ['-data_criacao']

    def __str__(self):
        return f"#{self.id} - {self.titulo}"

    def delete(self, *args, **kwargs):
        if self.status == 'EM ANDAMENTO':
            raise ValidationError("Não é possível excluir um chamado que está em andamento.")
        super().delete(*args, **kwargs)


class ChamadoStatusHistory(models.Model):
    """Histórico de mudanças de status do chamado"""
    
    chamado = models.ForeignKey(
        Chamado, 
        related_name='historico', 
        on_delete=models.CASCADE
    )
    status = models.CharField(max_length=30)
    descricao = models.TextField(verbose_name="Descrição da Mudança")
    usuario = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True,
        verbose_name="Usuário Responsável"
    )
    data_criacao = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Histórico de Status"
        verbose_name_plural = "Históricos de Status"
        ordering = ['-data_criacao']

    def __str__(self):
        return f"Histórico #{self.id} - Chamado #{self.chamado.id}"


class ChamadoStatusImage(models.Model):
    """Imagens anexadas ao histórico de status"""
    
    historico = models.ForeignKey(
        ChamadoStatusHistory,
        related_name='fotos',
        on_delete=models.CASCADE
    )
    imagem = models.ImageField(upload_to='chamados/historico/%Y/%m/%d/')
    data_upload = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Imagem do Histórico"
        verbose_name_plural = "Imagens do Histórico"

    def __str__(self):
        return f"Imagem {self.id} - Histórico #{self.historico.id}"


class ChamadoAnexo(models.Model):
    """Anexos gerais do chamado"""
    
    chamado = models.ForeignKey(
        Chamado,
        related_name='anexos',
        on_delete=models.CASCADE
    )
    arquivo = models.FileField(upload_to='chamados/anexos/%Y/%m/%d/')
    nome_original = models.CharField(max_length=255)
    data_upload = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Anexo"
        verbose_name_plural = "Anexos"

    def __str__(self):
        return f"Anexo {self.nome_original} - Chamado #{self.chamado.id}"


class Comentario(models.Model):
    """Comentários no chamado"""
    
    chamado = models.ForeignKey(
        Chamado, 
        related_name='comentarios', 
        on_delete=models.CASCADE
    )
    autor = models.ForeignKey(
        User, 
        on_delete=models.SET_NULL, 
        null=True,
        verbose_name="Autor"
    )
    texto = models.TextField(verbose_name="Comentário")
    data_criacao = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Comentário"
        verbose_name_plural = "Comentários"
        ordering = ['-data_criacao']

    def __str__(self):
        return f"Comentário de {self.autor} em Chamado #{self.chamado.id}"


class Ativo(models.Model):
    """Modelo para gestão de ativos/equipamentos"""
    
    STATUS_CHOICES = [
        ('Ativo', 'Ativo'),
        ('Inativo', 'Inativo'),
        ('Manutenção', 'Manutenção'),
    ]
    
    codigo = models.CharField(max_length=50, unique=True, verbose_name="Código/Tag QR")
    nome = models.CharField(max_length=200, verbose_name="Nome")
    modelo = models.CharField(max_length=200, verbose_name="Modelo")
    fabricante = models.CharField(max_length=200, blank=True, verbose_name="Fabricante")
    numero_serie = models.CharField(max_length=200, blank=True, verbose_name="Número de Série")
    fornecedor = models.CharField(max_length=200, blank=True, verbose_name="Fornecedor")
    
    ambiente = models.CharField(max_length=200, verbose_name="Ambiente/Localização", default="Não informado")
    status = models.CharField(
        max_length=20, 
        choices=STATUS_CHOICES,
        default='Ativo',
        verbose_name="Status"
    )
    
    data_cadastro = models.DateTimeField(auto_now_add=True)
    data_atualizacao = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Ativo"
        verbose_name_plural = "Ativos"
        ordering = ['nome']

    def __str__(self):
        return f"{self.codigo} - {self.nome}"


class AtivoHistorico(models.Model):
    """Histórico de movimentações e alterações do ativo"""
    
    ativo = models.ForeignKey(
        Ativo,
        related_name='historico_movimentacoes',
        on_delete=models.CASCADE
    )
    tipo = models.CharField(max_length=100, verbose_name="Tipo de Movimentação")
    descricao = models.TextField(verbose_name="Descrição")
    usuario = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        verbose_name="Responsável"
    )
    data_criacao = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        verbose_name = "Histórico do Ativo"
        verbose_name_plural = "Históricos dos Ativos"
        ordering = ['-data_criacao']

    def __str__(self):
        return f"{self.tipo} - {self.ativo.codigo}"