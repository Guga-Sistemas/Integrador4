import 'package:flutter/material.dart';
import '../../models/chamado.dart';

class ChamadoProvider with ChangeNotifier {
  List<Chamado> _chamados = [];
  bool _isLoading = false;
  String? _error;

  List<Chamado> get chamados => _chamados;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchChamados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _chamados = _getMockChamados();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Chamado? getChamadoById(String id) {
    try {
      return _chamados.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Chamado> _getMockChamados() {
    return [
      Chamado(
        id: '#REQ-2025-3043',
        titulo: 'Problema com impressora no setor financeiro',
        descricao: 'A impressora do setor financeiro HP LaserJet Pro M404dn está apresentando problemas de conexão de alimentação. Quando tentamos conectar o cabo, o display, papéis tra impressora para não funcionar. Já tentamos trocar os cabos e verificar a configuração, mas o problema persiste. Necessário verificar se não existe interrupções no circuito de alimentação.',
        status: 'EM ANDAMENTO',
        prioridade: 'Alta',
        ambiente: 'Setor Financeiro - Sala 204',
        ativo: 'HP LaserJet Pro M404dn (HKKT-0542)',
        solicitante: 'Maria Souza',
        responsaveis: ['Carlos Silva', 'João Mendes'],
        dataCriacao: DateTime(2023, 11, 26, 10, 6),
        dataSugerida: DateTime(2023, 11, 28),
        anexos: [
          'https://via.placeholder.com/300x200',
          'https://via.placeholder.com/300x200',
          'https://via.placeholder.com/300x200',
        ],
        historico: [
          ChamadoStatusHistory(
            id: '1',
            status: 'ABERTO',
            descricao: 'Chamado aberto para resolver problema em impressoras do setor financeiro.',
            usuario: 'Maria Souza',
            timestamp: DateTime(2023, 11, 26, 10, 6),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '2',
            status: 'EM ANDAMENTO',
            descricao: 'Atribuído para equipe técnica. Vou verificar o equipamento amanhã pela manhã.',
            usuario: 'Carlos Silva',
            timestamp: DateTime(2023, 11, 26, 14, 51),
            fotos: ['https://via.placeholder.com/300x200'],
          ),
          ChamadoStatusHistory(
            id: '3',
            status: 'AGUARDANDO RESP',
            descricao: 'Identifiquei problema no mecanismo de alimentação. Necessário substituir a correia da impressora, mas faltam peças disponíveis.',
            usuario: 'Carlos Silva',
            timestamp: DateTime(2023, 11, 26, 17, 45),
            fotos: [
              'https://via.placeholder.com/300x200',
              'https://via.placeholder.com/300x200',
            ],
          ),
          ChamadoStatusHistory(
            id: '4',
            status: 'EM ANDAMENTO',
            descricao: 'Peça chegou. Vou substituir e verificar o funcionamento hoje ainda neste mês.',
            usuario: 'Carlos Silva',
            timestamp: DateTime(2023, 11, 28, 9, 31),
            fotos: [],
          ),
        ],
        comentarios: [
          Comentario(
            id: '1',
            usuario: 'Carlos Silva',
            texto: 'Verifiquei o equipamento e realmente tem problemas na conexão de alimentação. Vou precisar abrir e avaliar os demais internos.',
            timestamp: DateTime(2023, 11, 26, 14, 50),
          ),
          Comentario(
            id: '2',
            usuario: 'Ana Oliveira',
            texto: 'Por favor, avise quando for realizar o reparo para que possamos organizar o trabalho do setor financeiro. Obrigada!',
            timestamp: DateTime(2023, 11, 27, 8, 13),
          ),
        ],
      ),
    ];
  }
}
