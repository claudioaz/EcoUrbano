import 'package:flutter/material.dart';

import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'dart:convert';

void main() {
  runApp(const EcoUrbanoApp());
}

class EcoUrbanoApp extends StatelessWidget {
  const EcoUrbanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoUrbano',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16845B)),
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
      ),
      home: const HomePage(),
    );
  }
}

// TELA INICIAL

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _abertas = 0;
  int _resolvidas = 0;
  bool _carregandoIndicadores = true;

  @override
  void initState() {
    super.initState();
    _carregarIndicadores();
  }

  Future<void> _carregarIndicadores() async {
    try {
      final resposta = await http.get(
        Uri.parse('http://10.0.2.2:8000/indicadores'),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        final porStatus = dados['por_status'] ?? {};

        if (!mounted) return;

        setState(() {
          _abertas = porStatus['ABERTA'] ?? 0;
          _resolvidas = porStatus['RESOLVIDA'] ?? 0;
          _carregandoIndicadores = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _carregandoIndicadores = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregandoIndicadores = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16845B),
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.eco, size: 28),
            SizedBox(width: 10),
            Text('EcoUrbano', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificacoesPage(),
                ),
              );

              if (mounted) {
                setState(() {});
              }
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, size: 27),

                if (NotificacoesController.naoLidas > 0)
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        NotificacoesController.naoLidas > 9
                            ? '9+'
                            : '${NotificacoesController.naoLidas}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Notificações',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Olá! Bem-vindo ao EcoUrbano.',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20352B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Juntos por uma cidade mais limpa, sustentável e organizada.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF16845B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_city, color: Colors.white, size: 38),
                  SizedBox(height: 15),
                  Text(
                    'Sua cidade merece atenção.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registre problemas ambientais e ajude a melhorar seu bairro.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Acompanhe as ocorrências',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _indicatorCard(
                    _carregandoIndicadores ? '...' : _abertas.toString(),
                    'Abertas',
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _indicatorCard(
                    _carregandoIndicadores ? '...' : _resolvidas.toString(),
                    'Resolvidas',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'O que deseja fazer?',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _actionCard(
              context,
              Icons.add_location_alt_outlined,
              'Registrar ocorrência',
              'Informe um problema ambiental na sua região.',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrarOcorrenciaPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            _actionCard(
              context,
              Icons.list_alt,
              'Consultar ocorrências',
              'Visualize os registros realizados.',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConsultarOcorrenciasPage(),
                  ),
                ).then((_) {
                  if (mounted) {
                    setState(() {});
                    _carregarIndicadores();
                  }
                });
              },
            ),
            const SizedBox(height: 12),

_actionCard(
  context,
  Icons.map_outlined,
  'Mapa de Ocorrências',
  'Visualize no mapa os problemas registrados na cidade.',
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaOcorrenciasPage(),
      ),
    );
  },
),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConsultarOcorrenciasPage(),
              ),
            ).then((_) {
              if (mounted) {
                setState(() {});
                _carregarIndicadores();
              }
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PerfilPage()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            label: 'Ocorrências',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _indicatorCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF16845B), size: 32),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// TELA DE REGISTRO DE OCORRÊNCIA

// TELA DE CONSULTA DE OCORRÊNCIAS

class ConsultarOcorrenciasPage extends StatefulWidget {
  const ConsultarOcorrenciasPage({super.key});

  @override
  State<ConsultarOcorrenciasPage> createState() =>
      _ConsultarOcorrenciasPageState();
}

class _ConsultarOcorrenciasPageState extends State<ConsultarOcorrenciasPage> {
  List<dynamic> _ocorrencias = [];
  bool _carregando = true;
  String? _erro;
  String? _categoriaSelecionada;
  String? _statusSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarOcorrencias();
  }

  Future<void> _carregarOcorrencias() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resposta = await http.get(
        Uri.parse('http://10.0.2.2:8000/ocorrencias'),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        setState(() {
          _ocorrencias = dados;
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = 'Erro ao carregar ocorrências: ${resposta.statusCode}';
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível conectar ao servidor.';
        _carregando = false;
      });
    }
  }

  Future<void> _atualizarStatus(int id, String novoStatus) async {
    try {
      // Localiza a ocorrência e verifica seu status atual.
      final ocorrenciasEncontradas = _ocorrencias
          .where((ocorrencia) => ocorrencia['id'] == id)
          .toList();

      final statusAnterior = ocorrenciasEncontradas.isNotEmpty
          ? ocorrenciasEncontradas.first['status']
          : null;

      final resposta = await http.patch(
        Uri.parse('http://10.0.2.2:8000/ocorrencias/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': novoStatus}),
      );

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        // Cria uma notificação somente se o status realmente mudou.
        if (statusAnterior != novoStatus) {
          String titulo;
          String mensagem;

          switch (novoStatus) {
            case 'EM_ANALISE':
              titulo = 'Ocorrência em análise';
              mensagem = 'Uma ocorrência foi encaminhada para análise.';
              break;

            case 'RESOLVIDA':
              titulo = 'Ocorrência resolvida';
              mensagem = 'Uma ocorrência foi marcada como resolvida.';
              break;

            case 'ABERTA':
              titulo = 'Ocorrência reaberta';
              mensagem = 'Uma ocorrência voltou para o status aberta.';
              break;

            default:
              titulo = 'Status atualizado';
              mensagem = 'O status de uma ocorrência foi alterado.';
          }

          NotificacoesController.adicionar(titulo: titulo, mensagem: mensagem);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        _carregarOcorrencias();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: ${resposta.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível conectar ao servidor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _nomeCategoria(String? categoria) {
    const nomes = {
      'POLUICAO_AR': 'Poluição do ar',
      'ALAGAMENTO': 'Alagamento',
      'LIXO_IRREGULAR': 'Lixo irregular',
      'DESMATAMENTO': 'Desmatamento',
      'MANANCIAL': 'Manancial',
      'TRANSITO': 'Trânsito',
      'OUTRA': 'Outra',
    };

    return nomes[categoria] ?? categoria ?? 'Não informada';
  }

  List<dynamic> get _ocorrenciasFiltradas {
    return _ocorrencias.where((ocorrencia) {
      final categoriaCorreta =
          _categoriaSelecionada == null ||
          ocorrencia['categoria'] == _categoriaSelecionada;

      final statusCorreto =
          _statusSelecionado == null ||
          ocorrencia['status'] == _statusSelecionado;

      return categoriaCorreta && statusCorreto;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocorrências registradas'),
        backgroundColor: const Color(0xFF16845B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _carregarOcorrencias,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_erro!),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _carregarOcorrencias,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _categoriaSelecionada ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por categoria',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Todas')),
                          DropdownMenuItem(
                            value: 'POLUICAO_AR',
                            child: Text('Poluição do ar'),
                          ),
                          DropdownMenuItem(
                            value: 'ALAGAMENTO',
                            child: Text('Alagamento'),
                          ),
                          DropdownMenuItem(
                            value: 'LIXO_IRREGULAR',
                            child: Text('Lixo irregular'),
                          ),
                          DropdownMenuItem(
                            value: 'DESMATAMENTO',
                            child: Text('Desmatamento'),
                          ),
                          DropdownMenuItem(
                            value: 'MANANCIAL',
                            child: Text('Manancial'),
                          ),
                          DropdownMenuItem(
                            value: 'TRANSITO',
                            child: Text('Trânsito'),
                          ),
                          DropdownMenuItem(
                            value: 'OUTRA',
                            child: Text('Outra'),
                          ),
                        ],
                        onChanged: (valor) {
                          setState(() {
                            _categoriaSelecionada = valor == '' ? null : valor;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _statusSelecionado ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('Todos')),
                          DropdownMenuItem(
                            value: 'ABERTA',
                            child: Text('Aberta'),
                          ),
                          DropdownMenuItem(
                            value: 'EM_ANALISE',
                            child: Text('Em análise'),
                          ),
                          DropdownMenuItem(
                            value: 'RESOLVIDA',
                            child: Text('Resolvida'),
                          ),
                        ],
                        onChanged: (valor) {
                          setState(() {
                            _statusSelecionado = valor == '' ? null : valor;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _carregarOcorrencias,
                    child: _ocorrenciasFiltradas.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Text('Nenhuma ocorrência encontrada.'),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _ocorrenciasFiltradas.length,
                            itemBuilder: (context, index) {
                              final ocorrencia = _ocorrenciasFiltradas[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 14),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ocorrencia['titulo'] ?? 'Sem título',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(ocorrencia['descricao'] ?? ''),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Categoria: ${_nomeCategoria(ocorrencia['categoria'])}',
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Localização: ${ocorrencia['localizacao'] ?? 'Não informada'}',
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Data de registro: ${ocorrencia['criada_em'] != null ? DateTime.parse(ocorrencia['criada_em']).toLocal().toString().substring(0, 16).split('-').reversed.join('/') : 'Não informada'}',
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Atualizar status:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF16845B),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        initialValue:
                                            [
                                              'ABERTA',
                                              'EM_ANALISE',
                                              'RESOLVIDA',
                                            ].contains(ocorrencia['status'])
                                            ? ocorrencia['status']
                                            : 'ABERTA',
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'ABERTA',
                                            child: Text('Aberta'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'EM_ANALISE',
                                            child: Text('Em análise'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'RESOLVIDA',
                                            child: Text('Resolvida'),
                                          ),
                                        ],
                                        onChanged: (novoStatus) {
                                          if (novoStatus != null) {
                                            _atualizarStatus(
                                              ocorrencia['id'],
                                              novoStatus,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class RegistrarOcorrenciaPage extends StatefulWidget {
  const RegistrarOcorrenciaPage({super.key});

  @override
  State<RegistrarOcorrenciaPage> createState() =>
      _RegistrarOcorrenciaPageState();
}

class _RegistrarOcorrenciaPageState extends State<RegistrarOcorrenciaPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();

  final TextEditingController _descricaoController = TextEditingController();

  final TextEditingController _localizacaoController = TextEditingController();

  String? _categoriaSelecionada;
  LatLng? _localizacaoSelecionada;

  final Map<String, String> _categorias = {
    'POLUICAO_AR': 'Poluição do ar',
    'ALAGAMENTO': 'Alagamento',
    'LIXO_IRREGULAR': 'Lixo irregular',
    'DESMATAMENTO': 'Desmatamento',
    'MANANCIAL': 'Manancial',
    'TRANSITO': 'Trânsito',
    'OUTRA': 'Outra',
  };

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _localizacaoController.dispose();
    super.dispose();
  }

  Future<void> _registrarOcorrencia() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('http://10.0.2.2:8000/ocorrencias'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': _tituloController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'categoria': _categoriaSelecionada,
          'localizacao': _localizacaoController.text.trim(),
          'latitude': _localizacaoSelecionada?.latitude,
          'longitude': _localizacaoSelecionada?.longitude,
        }),
      );

      if (!mounted) return;

      if (resposta.statusCode == 201) {
        NotificacoesController.adicionar(
          titulo: 'Nova ocorrência registrada',
          mensagem:
              'A ocorrência "${_tituloController.text.trim()}" foi cadastrada com sucesso.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorrência registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar: ${resposta.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível conectar ao servidor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16845B),
        foregroundColor: Colors.white,
        title: const Text(
          'Registrar ocorrência',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nova ocorrência',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20352B),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Descreva o problema ambiental encontrado para ajudar a melhorar sua região.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 25),

              const Text(
                'Título da ocorrência',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _tituloController,
                decoration: _inputDecoration(
                  'Ex.: Alagamento na rua',
                  Icons.edit_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título da ocorrência.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Categoria',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _categoriaSelecionada,
                decoration: _inputDecoration(
                  'Selecione uma categoria',
                  Icons.category_outlined,
                ),
                items: _categorias.entries.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria.key,
                    child: Text(categoria.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSelecionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma categoria.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Descrição do problema',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Descreva o que aconteceu...',
                  Icons.description_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a descrição do problema.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Localização',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _localizacaoController,
                decoration: _inputDecoration(
                  'Ex.: Bairro, rua e cidade',
                  Icons.location_on_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a localização.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final localizacao = await Navigator.push<LatLng>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelecionarLocalizacaoPage(),
                      ),
                    );

                    if (localizacao != null) {
                      setState(() {
                        _localizacaoSelecionada = localizacao;
                      });
                    }
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Selecionar localização no mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF16845B),
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ),

              if (_localizacaoSelecionada != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Latitude: ${_localizacaoSelecionada!.latitude.toStringAsFixed(6)}\n'
                  'Longitude: ${_localizacaoSelecionada!.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: Color(0xFF16845B)),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _registrarOcorrencia,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Enviar ocorrência',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16845B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF16845B)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E8E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF16845B), width: 1.5),
      ),
    );
  }
}

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF16845B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o EcoUrbano'),
        backgroundColor: verde,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),

            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFE4F3EC),
              child: Icon(Icons.eco, size: 55, color: verde),
            ),

            const SizedBox(height: 15),

            const Text(
              'EcoUrbano',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: verde,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Tecnologia a favor de cidades melhores.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            _infoCard(
              icon: Icons.info_outline,
              title: 'Sobre o projeto',
              description:
                  'O EcoUrbano é um aplicativo desenvolvido para '
                  'registrar e acompanhar ocorrências ambientais e '
                  'urbanas, contribuindo para a identificação de '
                  'problemas nas cidades.',
            ),

            _infoCard(
              icon: Icons.lightbulb_outline,
              title: 'Nosso objetivo',
              description:
                  'Utilizar a tecnologia para facilitar o registro '
                  'de ocorrências, organizar informações e apoiar '
                  'o acompanhamento de problemas urbanos.',
            ),

            _infoCard(
              icon: Icons.apps,
              title: 'Funcionalidades',
              description:
                  '• Cadastro de ocorrências\n'
                  '• Consulta de registros\n'
                  '• Filtros por categoria e status\n'
                  '• Atualização de ocorrências\n'
                  '• Indicadores de acompanhamento',
            ),

            _infoCard(
              icon: Icons.school_outlined,
              title: 'Projeto acadêmico',
              description:
                  'Projeto desenvolvido como parte das atividades '
                  'acadêmicas do curso de Ciência da Computação '
                  'da Universidade Paulista (UNIP).',
            ),

            const SizedBox(height: 20),

            const Text(
              'EcoUrbano • Versão 1.0',
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF16845B), size: 25),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificacoesController {
  static final List<Map<String, dynamic>> notificacoes = [];

  static void adicionar({required String titulo, required String mensagem}) {
    notificacoes.insert(0, {
      'titulo': titulo,
      'mensagem': mensagem,
      'data': DateTime.now(),
      'lida': false,
    });
  }

  static int get naoLidas =>
      notificacoes.where((n) => n['lida'] == false).length;
}

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF16845B);
    final notificacoes = NotificacoesController.notificacoes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: verde,
        foregroundColor: Colors.white,
        actions: [
          if (NotificacoesController.naoLidas > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (final notificacao in notificacoes) {
                    notificacao['lida'] = true;
                  }
                });
              },
              child: const Text(
                'Marcar todas como lidas',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: notificacoes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 75,
                    color: Colors.black38,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Nenhuma notificação',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'As atualizações das ocorrências aparecerão aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: notificacoes.length,
              itemBuilder: (context, index) {
                final notificacao = notificacoes[index];
                final data = notificacao['data'] as DateTime;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE4F3EC),
                      child: Icon(Icons.notifications_active, color: verde),
                    ),
                    title: Text(
                      notificacao['titulo'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(notificacao['mensagem']),
                        const SizedBox(height: 5),
                        Text(
                          '${data.day.toString().padLeft(2, '0')}/'
                          '${data.month.toString().padLeft(2, '0')}/'
                          '${data.year} às '
                          '${data.hour.toString().padLeft(2, '0')}:'
                          '${data.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: notificacao['lida'] == false
                        ? const Icon(Icons.circle, color: verde, size: 12)
                        : const Icon(
                            Icons.check_circle_outline,
                            color: Colors.grey,
                          ),
                    onTap: () {
                      setState(() {
                        notificacao['lida'] = true;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}

class SelecionarLocalizacaoPage extends StatefulWidget {
  const SelecionarLocalizacaoPage({super.key});

  @override
  State<SelecionarLocalizacaoPage> createState() =>
      _SelecionarLocalizacaoPageState();
}

class _SelecionarLocalizacaoPageState extends State<SelecionarLocalizacaoPage> {
  // Centro inicial do mapa: São Paulo.
  LatLng? _pontoSelecionado;

  static const LatLng _centroInicial = LatLng(-23.5505, -46.6333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar localização'),
        backgroundColor: const Color(0xFF16845B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Toque no mapa para marcar o local da ocorrência.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ),

          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _centroInicial,
                initialZoom: 13,
                onTap: (tapPosition, ponto) {
                  setState(() {
                    _pontoSelecionado = ponto;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mobile',
                ),

                if (_pontoSelecionado != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pontoSelecionado!,
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 45,
                        ),
                      ),
                    ],
                  ),

                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_pontoSelecionado != null)
                  Text(
                    'Latitude: ${_pontoSelecionado!.latitude.toStringAsFixed(6)}\n'
                    'Longitude: ${_pontoSelecionado!.longitude.toStringAsFixed(6)}',
                    textAlign: TextAlign.center,
                  )
                else
                  const Text('Nenhum ponto selecionado.'),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _pontoSelecionado == null
                        ? null
                        : () {
                            Navigator.pop(context, _pontoSelecionado);
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar localização'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16845B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class MapaOcorrenciasPage extends StatefulWidget {
  const MapaOcorrenciasPage({super.key});

  @override
  State<MapaOcorrenciasPage> createState() =>
      _MapaOcorrenciasPageState();
}

class _MapaOcorrenciasPageState extends State<MapaOcorrenciasPage> {
  static const LatLng _centroInicial = LatLng(-23.5505, -46.6333);

  List<dynamic> _ocorrencias = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarOcorrencias();
  }

  Future<void> _carregarOcorrencias() async {
    try {
      final resposta = await http.get(
        Uri.parse('http://10.0.2.2:8000/ocorrencias'),
      );

      if (resposta.statusCode != 200) {
        throw Exception('Erro ao consultar API');
      }

      final dados = jsonDecode(resposta.body) as List;

      if (!mounted) return;

      setState(() {
        _ocorrencias = dados.where((item) {
          return item['latitude'] != null &&
              item['longitude'] != null;
        }).toList();
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as ocorrências.';
        _carregando = false;
      });
    }
  }

  void _mostrarDetalhes(dynamic ocorrencia) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ocorrencia['titulo'] ?? 'Ocorrência',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Categoria: ${ocorrencia['categoria']}'),
            Text('Local: ${ocorrencia['localizacao']}'),
            Text('Status: ${ocorrencia['status']}'),
            const SizedBox(height: 8),
            Text('Descrição: ${ocorrencia['descricao']}'),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Ocorrências'),
        backgroundColor: const Color(0xFF16845B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _carregando = true;
                _erro = null;
              });
              _carregarOcorrencias();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _ocorrencias.isNotEmpty
                        ? LatLng(
                            (_ocorrencias.first['latitude'] as num).toDouble(),
                            (_ocorrencias.first['longitude'] as num).toDouble(),
                          )
                        : _centroInicial,
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mobile',
                    ),
                    MarkerLayer(
                      markers: _ocorrencias.map((ocorrencia) {
                        return Marker(
                          point: LatLng(
                            (ocorrencia['latitude'] as num).toDouble(),
                            (ocorrencia['longitude'] as num).toDouble(),
                          ),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => _mostrarDetalhes(ocorrencia),
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 45,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}