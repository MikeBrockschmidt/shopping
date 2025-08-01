import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping/src/features/memory/domain/memory_item.dart';
import 'package:shopping/src/features/memory/presentation/memory_provider.dart';

class MemoryScreen extends StatefulWidget {
  final String groupId;

  const MemoryScreen({super.key, required this.groupId});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final List<double> _glassesOpacity = List.generate(8, (_) => 0.5);

  double _currentLiters = 0.0;

  void _memoryProviderListener() {
    final memoryProvider = context.read<MemoryProvider>();
    if (memoryProvider.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(memoryProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        memoryProvider.clearErrorMessage();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<MemoryProvider>().addListener(_memoryProviderListener);
    _calculateCurrentLiters();
  }

  @override
  void dispose() {
    context.read<MemoryProvider>().removeListener(_memoryProviderListener);
    super.dispose();
  }

  void _calculateCurrentLiters() {
    _currentLiters =
        _glassesOpacity.where((opacity) => opacity == 1.0).length * 0.2;
  }

  void _toggleGlassState(int index) {
    setState(() {
      if (index >= 0 && index < _glassesOpacity.length) {
        _glassesOpacity[index] = _glassesOpacity[index] == 0.5 ? 1.0 : 0.5;
        _calculateCurrentLiters();
      }
    });
  }

  Widget _buildGlassColumn(int index) {
    final Color glassColor = _glassesOpacity[index] == 1.0
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return Column(
      children: [
        IconButton(
          icon: Opacity(
            opacity: _glassesOpacity[index],
            child: Icon(Icons.local_drink, size: 60, color: glassColor),
          ),
          onPressed: () => _toggleGlassState(index),
        ),
        const SizedBox(height: 4),
        Text('0,2L', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.watch<MemoryProvider>();

    final Brightness brightness = Theme.of(context).brightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final String backgroundImage = isDarkMode
        ? 'assets/images/wedoshopping_dr.png'
        : 'assets/images/wedoshopping_dr-d.png';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 200,
        elevation: 16,
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(backgroundImage, fit: BoxFit.cover),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Trinkverhalten protokollieren',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        4,
                        (index) => _buildGlassColumn(index),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        4,
                        (index) => _buildGlassColumn(index + 4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'Stand: ${_currentLiters.toStringAsFixed(1)} von 1,6 Litern',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              memoryProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : memoryProvider.memories
                        .where((memory) => !memory.isArchived)
                        .isEmpty
                  ? const SizedBox.shrink()
                  : Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: memoryProvider.memories
                            .where((memory) => !memory.isArchived)
                            .length,
                        itemBuilder: (context, index) {
                          final memory = memoryProvider.memories
                              .where((memory) => !memory.isArchived)
                              .toList()[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      memory.name,
                                      style: TextStyle(
                                        decoration: memory.isArchived
                                            ? TextDecoration.lineThrough
                                            : null,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          memory.isArchived
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color: memory.isArchived
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          memoryProvider.toggleMemoryArchived(
                                            memory,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          memoryProvider.removeMemory(memory);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
