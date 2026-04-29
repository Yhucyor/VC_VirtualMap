import 'package:flutter/material.dart';

void main() {
  runApp(const CaroApp());
}

class CaroApp extends StatelessWidget {
  const CaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caro 3x3',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const CaroGamePage(),
    );
  }
}

class CaroGamePage extends StatefulWidget {
  const CaroGamePage({super.key});

  @override
  State<CaroGamePage> createState() => _CaroGamePageState();
}

class _CaroGamePageState extends State<CaroGamePage> {
  static const _winningLines = <List<int>>[
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;
  bool _isDraw = false;

  bool get _gameOver => _winner != null || _isDraw;

  String get _statusText {
    if (_winner != null) {
      return 'Nguoi choi $_winner thang!';
    }
    if (_isDraw) {
      return 'Hoa roi!';
    }
    return 'Luot cua nguoi choi $_currentPlayer';
  }

  void _playAt(int index) {
    if (_board[index].isNotEmpty || _gameOver) {
      return;
    }

    setState(() {
      _board[index] = _currentPlayer;
      _winner = _findWinner();

      if (_winner == null && !_board.contains('')) {
        _isDraw = true;
      }

      if (!_gameOver) {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  String? _findWinner() {
    for (final line in _winningLines) {
      final first = _board[line[0]];
      if (first.isEmpty) {
        continue;
      }

      if (first == _board[line[1]] && first == _board[line[2]]) {
        return first;
      }
    }

    return null;
  }

  void _resetGame() {
    setState(() {
      for (var i = 0; i < _board.length; i++) {
        _board[i] = '';
      }
      _currentPlayer = 'X';
      _winner = null;
      _isDraw = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Caro 3x3'),
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statusText,
                    key: const ValueKey('game-status'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Flexible(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF12312F),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 24,
                              color: Color(0x22000000),
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(10),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _board.length,
                          itemBuilder: (context, index) {
                            return _CaroCell(
                              value: _board[index],
                              index: index,
                              onTap: () => _playAt(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Choi lai'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaroCell extends StatelessWidget {
  const _CaroCell({
    required this.value,
    required this.index,
    required this.onTap,
  });

  final String value;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isX = value == 'X';

    return Material(
      color: const Color(0xFFFFFEF7),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        key: ValueKey('cell-$index'),
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              value,
              key: ValueKey(value),
              style: TextStyle(
                fontSize: 58,
                height: 1,
                fontWeight: FontWeight.w900,
                color: isX ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
