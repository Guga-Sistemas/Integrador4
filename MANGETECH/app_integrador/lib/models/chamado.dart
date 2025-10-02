class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final String status;
  final String prioridade;
  final String ambiente;
  final String ativo;
  final String solicitante;
  final List<String> responsaveis;
  final DateTime dataCriacao;
  final DateTime? dataSugerida;
  final List<String> anexos;
  final List<ChamadoStatusHistory> historico;
  final List<Comentario> comentarios;

  Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.prioridade,
    required this.ambiente,
    required this.ativo,
    required this.solicitante,
    required this.responsaveis,
    required this.dataCriacao,
    this.dataSugerida,
    this.anexos = const [],
    this.historico = const [],
    this.comentarios = const [],
  });

  factory Chamado.fromJson(Map<String, dynamic> json) {
    return Chamado(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      status: json['status'] ?? '',
      prioridade: json['prioridade'] ?? '',
      ambiente: json['ambiente'] ?? '',
      ativo: json['ativo'] ?? '',
      solicitante: json['solicitante'] ?? '',
      responsaveis: List<String>.from(json['responsaveis'] ?? []),
      dataCriacao: DateTime.parse(json['dataCriacao']),
      dataSugerida: json['dataSugerida'] != null 
          ? DateTime.parse(json['dataSugerida']) 
          : null,
      anexos: List<String>.from(json['anexos'] ?? []),
      historico: (json['historico'] as List?)
          ?.map((h) => ChamadoStatusHistory.fromJson(h))
          .toList() ?? [],
      comentarios: (json['comentarios'] as List?)
          ?.map((c) => Comentario.fromJson(c))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'status': status,
      'prioridade': prioridade,
      'ambiente': ambiente,
      'ativo': ativo,
      'solicitante': solicitante,
      'responsaveis': responsaveis,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataSugerida': dataSugerida?.toIso8601String(),
      'anexos': anexos,
    };
  }
}

class ChamadoStatusHistory {
  final String id;
  final String status;
  final String descricao;
  final String usuario;
  final DateTime timestamp;
  final List<String> fotos;

  ChamadoStatusHistory({
    required this.id,
    required this.status,
    required this.descricao,
    required this.usuario,
    required this.timestamp,
    this.fotos = const [],
  });

  factory ChamadoStatusHistory.fromJson(Map<String, dynamic> json) {
    return ChamadoStatusHistory(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      descricao: json['descricao'] ?? '',
      usuario: json['usuario'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      fotos: List<String>.from(json['fotos'] ?? []),
    );
  }
}

class Comentario {
  final String id;
  final String usuario;
  final String texto;
  final DateTime timestamp;

  Comentario({
    required this.id,
    required this.usuario,
    required this.texto,
    required this.timestamp,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] ?? '',
      usuario: json['usuario'] ?? '',
      texto: json['texto'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
