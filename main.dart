import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BehajTasbihApp());
}

const Color green = Color(0xFF176B50);
const Color darkGreen = Color(0xFF104C3B);
const Color gold = Color(0xFFD8B56D);
const Color background = Color(0xFFF5F8F5);
const Color softGreen = Color(0xFFE5F0E9);
const Color grey = Color(0xFF738078);

class BehajTasbihApp extends StatelessWidget {
  const BehajTasbihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behaj Tasbih',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          primary: green,
          secondary: gold,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: darkGreen,
          elevation: 0,
        ),
      ),
      home: const TasbihHomePage(),
    );
  }
}

class TasbihHomePage extends StatefulWidget {
  const TasbihHomePage({super.key});

  @override
  State<TasbihHomePage> createState() => _TasbihHomePageState();
}

class _TasbihHomePageState extends State<TasbihHomePage> {
  String mode = '33';
  int count = 0;
  int stage = 0;
  bool soundOn = true;
  bool vibrationOn = true;
  bool completed = false;

  final Map<String, List<int>> routines = {
    'Lazim': [100, 100, 100],
    'Wazeefat': [30, 50, 100, 12],
  };

  bool get isRoutine => mode == 'Lazim' || mode == 'Wazeefat';

  int get target {
    if (mode == '33') return 33;
    if (mode == '100') return 100;
    if (mode == '12') return 12;
    if (isRoutine) return routines[mode]![stage];
    return 0;
  }

  double get progress {
    if (target == 0) return 1;
    return (count / target).clamp(0.0, 1.0);
  }

  Future<void> alert() async {
    if (vibrationOn) {
      await HapticFeedback.mediumImpact();
    }
    if (soundOn) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  void chooseMode(String newMode) {
    setState(() {
      mode = newMode;
      count = 0;
      stage = 0;
      completed = false;
    });
  }

  Future<void> increment() async {
    if (completed) return;

    setState(() {
      count++;
    });

    if (target > 0 && count >= target) {
      await alert();
      if (!mounted) return;

      if (isRoutine && stage < routines[mode]!.length - 1) {
        setState(() {
          stage++;
          count = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stage completed! Continue to stage ${stage + 1}.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          completed = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alhamdulillah! Target completed.'),
          ),
        );
      }
    }
  }

  void undo() {
    if (count == 0 || completed) return;

    setState(() {
      count--;
    });
  }

  void reset() {
    setState(() {
      count = 0;
      stage = 0;
      completed = false;
    });
  }

  Future<void> showSettings() async {
    bool tempSound = soundOn;
    bool tempVibration = vibrationOn;

    final result = await showDialog<List<bool>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Alert settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Completion sound'),
                    value: tempSound,
                    onChanged: (value) {
                      setDialogState(() => tempSound = value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Vibration'),
                    value: tempVibration,
                    onChanged: (value) {
                      setDialogState(() => tempVibration = value);
                    },
                  ),
                  const Text(
                    'Sound and vibration depend on your device '
                    'or browser.',
                    style: TextStyle(fontSize: 12, color: grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                    [tempSound, tempVibration],
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        soundOn = result[0];
        vibrationOn = result[1];
      });
    }
  }

  Widget modeButton(String value, String title, String subtitle) {
    final selected = mode == value;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => chooseMode(value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 3,
            ),
            decoration: BoxDecoration(
              color: selected ? green : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? gold : const Color(0xFFDDE7DF),
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? Colors.white70 : grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.circle_outlined, color: green, size: 27),
            SizedBox(width: 9),
            Text(
              'BEHAJ TASBIH',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: showSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Alert settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkGreen, green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 36,
                    color: gold,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your Daily Dhikr Companion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Count with focus. Remember with peace.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFDCECE1),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'CHOOSE YOUR COUNT',
              style: TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                modeButton('33', '33', 'General'),
                modeButton('100', '100', 'General'),
                modeButton('12', '12', 'Tijaniyya'),
                modeButton('∞', '∞', 'Unlimited'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'GUIDED ROUTINES',
              style: TextStyle(
                color: darkGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => chooseMode('Lazim'),
                    icon: const Icon(Icons.repeat),
                    label: const Text('Lazim'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      side: const BorderSide(color: gold),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => chooseMode('Wazeefat'),
                    icon: const Icon(Icons.format_list_numbered),
                    label: const Text('Wazeefat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: green,
                      side: const BorderSide(color: gold),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFDDE7DF)),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isRoutine
                        ? '$mode • Stage ${stage + 1} of ${routines[mode]!.length}'
                        : mode == '∞'
                            ? 'FREE COUNT'
                            : '$mode COUNT',
                    style: const TextStyle(
                      color: grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isRoutine
                        ? 'Current target: $target'
                        : mode == '∞'
                            ? 'No limit'
                            : 'Target: $target',
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Tap the large counter itself to count.
                  Semantics(
                    button: true,
                    label: 'Tasbih count $count',
                    hint: 'Tap to increase the count',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: increment,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 9,
                                backgroundColor: softGreen,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(gold),
                              ),
                            ),
                            Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                color: background,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: softGreen,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$count',
                                    style: const TextStyle(
                                      color: darkGreen,
                                      fontSize: 62,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    target == 0 ? 'repetitions' : 'of $target',
                                    style: const TextStyle(
                                      color: grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    completed
                                        ? 'COMPLETED ✓'
                                        : 'TAP HERE TO COUNT',
                                    style: TextStyle(
                                      color: completed ? green : grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: completed ? null : increment,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        'COUNT',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: undo,
                          icon: const Icon(Icons.undo),
                          label: const Text('Undo'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ),
                    ],
                  ),
                  if (isRoutine) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Stages: ${routines[mode]!.join(' → ')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: softGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_none, color: darkGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sound ${soundOn ? 'ON' : 'OFF'}'
                      ' • Vibration ${vibrationOn ? 'ON' : 'OFF'}',
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: showSettings,
                    child: const Text('Settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Powered by Behaj Construction Tech Hub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Made with care',
                style: TextStyle(color: grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
