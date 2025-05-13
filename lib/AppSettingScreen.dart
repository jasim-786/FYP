import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:async';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  String _deviceInfo = 'Unknown';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceInfo = '${iosInfo.name} (${iosInfo.model})';
        });
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceInfo = '${androidInfo.brand} ${androidInfo.model}';
        });
      } else {
        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        setState(() {
          _deviceInfo = 'Running on ${webInfo.browserName}';
        });
      }
    } catch (e) {
      setState(() {
        _deviceInfo = 'Unable to retrieve device info';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('App Settings'),
          elevation: 2,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          shadowColor: Theme.of(context).shadowColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'General Settings',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 20),
              _AnimatedInfoRow(
                icon: Icons.info_outline,
                title: 'App Version',
                value: 'v1.0.0',
              ),
              const SizedBox(height: 16),
              _AnimatedInfoRow(
                icon: Icons.memory,
                title: 'Model Name',
                value: 'Hybrid Model (InceptionV3 + MobileNet)',
              ),
              const SizedBox(height: 16),
              _AnimatedInfoRow(
                icon: Icons.device_unknown,
                title: 'Running On',
                value: _deviceInfo,
              ),
              const SizedBox(height: 24),
              Text(
                'Fun Zone',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 20),
              _SettingCard(
                icon: Icons.gamepad,
                title: 'Play Tic-Tac-Toe',
                subtitle: 'Enjoy a quick game of Tic-Tac-Toe',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TicTacToeGame(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SettingCard(
                icon: Icons.ballot,
                title: 'Balloon Popper',
                subtitle: 'Pop balloons for fun!',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BalloonPopperGame(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  _SettingCardState createState() => _SettingCardState();
}

class _SettingCardState extends State<_SettingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        elevation: _isHovered ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Icon(
                widget.icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              subtitle: Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedInfoRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;

  const _AnimatedInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  _AnimatedInfoRowState createState() => _AnimatedInfoRowState();
}

class _AnimatedInfoRowState extends State<_AnimatedInfoRow>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardTheme.color ?? Colors.white,
                Theme.of(context).cardTheme.color?.withOpacity(0.8) ??
                    Colors.grey.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Icon(
                widget.icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              subtitle: AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    widget.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              trailing: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.expand_more,
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late List<String> board;
  late String currentPlayer;
  late bool gameEnded;
  late String winner;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      board = List.generate(9, (_) => '');
      currentPlayer = 'X';
      gameEnded = false;
      winner = '';
    });
  }

  void _makeMove(int index) {
    if (board[index] == '' && !gameEnded) {
      setState(() {
        board[index] = currentPlayer;
        if (_checkWinner()) {
          gameEnded = true;
          winner = currentPlayer;
        } else if (board.every((cell) => cell != '')) {
          gameEnded = true;
          winner = 'Draw';
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      });
    }
  }

  bool _checkWinner() {
    const List<List<int>> winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var combo in winningCombinations) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final gridSize = screenWidth * 0.8; // 80% of screen width for grid
    final textScaleFactor =
        screenWidth < 400 ? 0.8 : 1.0; // Scale text for small screens

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tic-Tac-Toe'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Dynamic padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameEnded
                      ? winner == 'Draw'
                          ? 'It\'s a Draw!'
                          : 'Player $winner Wins!'
                      : 'Player $currentPlayer\'s Turn',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 24 * textScaleFactor,
                      ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Container(
                  width: gridSize,
                  height: gridSize,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _makeMove(index),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: board[index] == 'X'
                                ? Colors.blue.withOpacity(0.2)
                                : board[index] == 'O'
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              board[index],
                              style: Theme.of(
                                context,
                              ).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: board[index] == 'X'
                                        ? Colors.blue
                                        : Colors.red,
                                    fontSize: 40 * textScaleFactor,
                                  ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Reset Game',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18 * textScaleFactor,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BalloonPopperGame extends StatefulWidget {
  const BalloonPopperGame({super.key});

  @override
  _BalloonPopperGameState createState() => _BalloonPopperGameState();
}

class _BalloonPopperGameState extends State<BalloonPopperGame>
    with SingleTickerProviderStateMixin {
  List<Balloon> balloons = [];
  int score = 0;
  late AnimationController _controller;
  Timer? _spawnTimer;
  final Random _random = Random();
  double screenWidth = 0;
  double screenHeight = 0;
  bool _isGameRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    )..addListener(_update);
    // Delay initialization until the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    _startGame();
  }

  void _startGame() {
    setState(() {
      balloons.clear();
      score = 0;
      _isGameRunning = true;
    });
    _controller.repeat();
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: 1000 + _random.nextInt(1000)),
      (timer) {
        if (!_isGameRunning) {
          timer.cancel();
          return;
        }
        _spawnBalloon();
      },
    );
  }

  double _getSpeedMultiplier() {
    // Increase speed by 10% for every 50 points, cap at 2x speed
    double multiplier = 1.0 + (score ~/ 50) * 0.1;
    return multiplier.clamp(1.0, 2.0);
  }

  void _spawnBalloon() {
    if (!mounted || !_isGameRunning) return;

    setState(() {
      balloons.add(
        Balloon(
          position: Offset(
            _random.nextDouble() *
                (screenWidth - 50), // Adjust for balloon width
            screenHeight,
          ),
          speed: (_random.nextDouble() * 2 + 1) * _getSpeedMultiplier(),
          drift: (_random.nextDouble() - 0.5) * 0.5, // Slight horizontal drift
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        ),
      );
    });
  }

  void _update() {
    if (!mounted || !_isGameRunning) return;

    setState(() {
      for (var balloon in balloons.toList()) {
        balloon.position = Offset(
          (balloon.position.dx + balloon.drift).clamp(0, screenWidth - 50),
          balloon.position.dy - balloon.speed,
        );
        if (balloon.position.dy < -80) {
          // Adjust for balloon height
          balloons.remove(balloon);
        }
      }
    });
  }

  void _popBalloon(Balloon balloon) {
    if (!mounted || !_isGameRunning) return;

    setState(() {
      balloons.remove(balloon);
      score += 10;
    });
  }

  @override
  void dispose() {
    _isGameRunning = false;
    _spawnTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = screenWidth < 400 ? 0.8 : 1.0;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Balloon Popper'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: screenWidth == 0 || screenHeight == 0
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Text(
                      'Score: $score',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 24 * textScaleFactor,
                          ),
                    ),
                  ),
                  ...balloons.map((balloon) {
                    return Positioned(
                      left: balloon.position.dx,
                      top: balloon.position.dy,
                      child: GestureDetector(
                        onTap: () => _popBalloon(balloon),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 50,
                              height: 70,
                              decoration: BoxDecoration(
                                color: balloon.color,
                                borderRadius: BorderRadius.circular(
                                  50,
                                ), // Oval shape
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, 5),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: HSLColor.fromColor(balloon.color)
                                      .withLightness(
                                        (HSLColor.fromColor(
                                                  balloon.color,
                                                ).lightness *
                                                0.8)
                                            .clamp(0.0, 1.0),
                                      )
                                      .toColor(),
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  Positioned(
                    bottom: 20,
                    left: screenWidth / 2 - 75,
                    child: ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset Game',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18 * textScaleFactor,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class Balloon {
  Offset position;
  double speed;
  double drift;
  Color color;

  Balloon({
    required this.position,
    required this.speed,
    required this.drift,
    required this.color,
  });
}
