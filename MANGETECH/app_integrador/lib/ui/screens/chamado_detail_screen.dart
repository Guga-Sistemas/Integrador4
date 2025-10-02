import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/chamado_provider.dart';
import '../../models/chamado.dart';
import '../widgets/timeline_item.dart';
import '../widgets/comentario_item.dart';
import '../widgets/image_gallery.dart';
import '../theme/app_theme.dart';
import '../widgets/mudar_status_dialog.dart';

class ChamadoDetailScreen extends StatelessWidget {
  final String chamadoId;

  const ChamadoDetailScreen({
    Key? key,
    required this.chamadoId,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ABERTO':
        return AppTheme.statusAberto;
      case 'AGUARDANDO RESP':
      case 'AGUARDANDO RESPONSÁVEIS':
        return AppTheme.statusAguardando;
      case 'EM ANDAMENTO':
        return AppTheme.statusAndamento;
      case 'REALIZADO':
        return AppTheme.statusRealizado;
      case 'CONCLUÍDO':
        return AppTheme.statusConcluido;
      case 'CANCELADO':
        return AppTheme.statusCancelado;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChamadoProvider>(context);
    final chamado = provider.getChamadoById(chamadoId);

    if (chamado == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chamado não encontrado')),
        body: const Center(
          child: Text('Chamado não encontrado'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este chamado está atrasado! O prazo sugerido foi 28/11/2023.',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        chamado.id,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(chamado.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          chamado.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(chamado.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ATRASADO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    chamado.titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Descrição
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Descrição do chamado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              chamado.descricao,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Anexos
                      if (chamado.anexos.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 8),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anexos (${chamado.anexos.length})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ImageGallery(images: chamado.anexos),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Comentários
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Comentários',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Adicionar comentário'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...chamado.comentarios.map((comentario) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ComentarioItem(comentario: comentario),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Timeline/Histórico
                      Container(
                        margin: const EdgeInsets.only(left: 16, right: 8),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Histórico do chamado',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Ir para último'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ...chamado.historico.asMap().entries.map((entry) {
                              final index = entry.key;
                              final history = entry.value;
                              return TimelineItem(
                                history: history,
                                isLast: index == chamado.historico.length - 1,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Right column
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Informações do chamado
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informações do chamado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Solicitante', chamado.solicitante),
                            _buildInfoRow(
                              'Criado em',
                              DateFormat('dd/MM/yyyy').format(chamado.dataCriacao),
                            ),
                            _buildInfoRow(
                              'Prazo sugerido',
                              chamado.dataSugerida != null
                                  ? DateFormat('dd/MM/yyyy').format(chamado.dataSugerida!)
                                  : '-',
                            ),
                            _buildInfoRow('Ambiente', chamado.ambiente),
                            _buildInfoRow('Ativo relacionado', chamado.ativo),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Responsáveis
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Responsáveis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...chamado.responsaveis.map((resp) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        _getInitials(resp),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            resp,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Assistente Técnico',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ações rápidas
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Ações rápidas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showMudarStatusDialog(context, chamado);
                              },
                              icon: const Icon(Icons.sync_alt),
                              label: const Text('Mudar status'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.note_add_outlined),
                              label: const Text('Adicionar nota'),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add_task_outlined),
                              label: const Text('Criar sub-tarefa'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }

  void _showMudarStatusDialog(BuildContext context, Chamado chamado) {
    showDialog(
      context: context,
      builder: (context) => MudarStatusDialog(chamado: chamado),
    );
  }
}
