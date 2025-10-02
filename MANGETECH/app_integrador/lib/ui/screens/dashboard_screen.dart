import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/chamado_provider.dart';
import '../widgets/chamado_card.dart';
import 'chamado_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChamadoProvider>(context, listen: false).fetchChamados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF2563EB),
            child: Text(
              'MS',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<ChamadoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchChamados,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.chamados.isEmpty) {
            return const Center(
              child: Text('Nenhum chamado encontrado'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.chamados.length,
            itemBuilder: (context, index) {
              final chamado = provider.chamados[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChamadoCard(
                  chamado: chamado,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChamadoDetailScreen(
                          chamadoId: chamado.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Criar Chamado'),
      ),
    );
  }
}
