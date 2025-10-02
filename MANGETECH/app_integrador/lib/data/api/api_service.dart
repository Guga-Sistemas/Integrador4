import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/chamado.dart';

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your API URL

  Future<List<Chamado>> getChamados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chamados'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Chamado.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar chamados');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<Chamado> getChamadoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chamados/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Chamado.fromJson(json.decode(response.body));
      } else {
        throw Exception('Chamado não encontrado');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<Chamado> createChamado(Chamado chamado) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chamados'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(chamado.toJson()),
      );

      if (response.statusCode == 201) {
        return Chamado.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao criar chamado');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<void> updateChamadoStatus(
    String id,
    String newStatus,
    String descricao,
    List<String>? fotos,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chamados/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': newStatus,
          'descricao': descricao,
          'fotos': fotos ?? [],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar status');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  Future<void> deleteChamado(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chamados/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir chamado');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }
}