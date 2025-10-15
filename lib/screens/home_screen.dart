import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sound.dart';
import '../providers/providers.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import 'player_screen.dart';
import 'upload_screen.dart';
import '../services/supabase_config.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoundVault'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await SupabaseService().signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          _ExploreList(),
          _MySoundsList(userId: userId),
          const UploadScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_music_outlined), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.queue_music_outlined), label: 'Mis sonidos'),
          NavigationDestination(icon: Icon(Icons.upload_file), label: 'Subir'),
        ],
      ),
    );
  }
}

class _TagFilterBar extends ConsumerWidget {
  const _TagFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(filterTagProvider);
    return Row(
      children: [
        const Text('Filtrar por etiqueta:'),
        const SizedBox(width: 8),
        DropdownButton<String?>(
          value: current,
          items: [
            const DropdownMenuItem(value: null, child: Text('Todas')),
            ...defaultTags.map((t) => DropdownMenuItem(value: t, child: Text(t))),
          ],
          onChanged: (v) => ref.read(filterTagProvider.notifier).state = v,
        )
      ],
    );
  }
}

class _ExploreList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsAsync = ref.watch(soundsProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TagFilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: soundsAsync.when(
              data: (list) => _SoundsList(list: list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error al cargar: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MySoundsList extends ConsumerWidget {
  final String? userId;
  const _MySoundsList({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundsAsync = ref.watch(mySoundsProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TagFilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: soundsAsync.when(
              data: (list) => _SoundsList(list: list, showDelete: true),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error al cargar: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundsList extends StatelessWidget {
  final List<Sound> list;
  final bool showDelete;
  const _SoundsList({required this.list, this.showDelete = false});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text('No hay sonidos disponibles'));
    }
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final s = list[index];
        return Card(
          child: ListTile(
            title: Text(s.name),
            subtitle: Text('${s.tag} · ${fmt.format(s.createdAt)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Reproducir',
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlayerScreen(sound: s)),
                    );
                  },
                ),
                if (showDelete)
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Eliminar sonido'),
                          content: const Text('¿Deseas eliminar este sonido?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try {
                          await StorageService().deleteSound(s);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Eliminado')));
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}