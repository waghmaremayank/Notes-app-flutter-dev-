import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const NotesApp());

class Note {
  Note(this.text);
  String text;
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: NotesColors.paper,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(
          seedColor: NotesColors.ink,
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

abstract final class NotesColors {
  static const paper = Color(0xffcccbc1);
  static const ink = Color(0xff5d5c50);
  static const muted = Color(0xff939186);
  static const cream = Color(0xffddd7b1);
  static const secondary = Color(0xff726f64);
  static const yellow = Color(0xfffff21f);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: .82, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotesBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const StatusBar(),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      'NOTES',
                      style: NotesText.logo.copyWith(fontSize: 42),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: -20,
                right: -20,
                child: CustomPaint(
                  size: const Size(double.infinity, 310),
                  painter: OrbitPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final notes = <Note>[
    Note('Type Anything To Remember'),
    Note('Type Anything To Remember'),
  ];
  String query = '';
  bool searching = false;

  Future<void> openEditor([Note? note]) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => EditorScreen(initialText: note?.text),
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    setState(() {
      if (note == null) {
        notes.insert(0, Note(result.trim()));
      } else {
        note.text = result.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleNotes = notes
        .where((note) => note.text.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Scaffold(
      body: NotesBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const StatusBar(),
              Positioned(
                top: 42,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => searching = !searching),
                      icon: Icon(
                        searching ? Icons.close : Icons.menu,
                        color: NotesColors.ink,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showProfile(context),
                      icon: const Icon(Icons.person, color: NotesColors.ink),
                    ),
                  ],
                ),
              ),
              if (searching)
                Positioned(
                  top: 92,
                  left: 20,
                  right: 20,
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => setState(() => query = value),
                    style: NotesText.profile,
                    decoration: InputDecoration(
                      hintText: 'Search notes',
                      hintStyle: NotesText.profile.copyWith(
                        color: NotesColors.secondary,
                      ),
                      filled: true,
                      fillColor: NotesColors.muted,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: searching ? 160 : 110,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        text: '09',
                        style: NotesText.clock,
                        children: [
                          TextSpan(
                            text: ':20',
                            style: NotesText.clock.copyWith(
                              color: NotesColors.secondary.withValues(
                                alpha: .62,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('March 19-3-2026', style: NotesText.caption),
                  ],
                ),
              ),
              Positioned(
                top: searching ? 270 : 220,
                left: 7,
                right: 7,
                bottom: 0,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 0, bottom: 12),
                        itemCount: visibleNotes.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 9),
                        itemBuilder: (context, index) {
                          final note = visibleNotes[index];
                          return NoteCard(
                            note: note,
                            onTap: () => openEditor(note),
                            onDelete: () => setState(() => notes.remove(note)),
                          );
                        },
                      ),
                    ),
                    Weekdays(onSelected: (_) {}),
                    const SizedBox(height: 10),
                    const Text(
                      'Keep Your\nNotes',
                      textAlign: TextAlign.center,
                      style: NotesText.footer,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 95,
                      width: 210,
                      child: CustomPaint(painter: FooterCirclePainter()),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: FloatingActionButton(
                  backgroundColor: NotesColors.ink,
                  foregroundColor: NotesColors.cream,
                  onPressed: () => openEditor(),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSheet(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, this.initialText});
  final String? initialText;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final controller = TextEditingController(
    text: widget.initialText == 'Type Anything To Remember'
        ? ''
        : widget.initialText,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotesBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const StatusBar(),
              Positioned(
                top: 46,
                left: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: NotesColors.ink),
                ),
              ),
              Positioned(
                top: 108,
                left: 7,
                right: 7,
                bottom: 28,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 20, 18, 18),
                  decoration: BoxDecoration(
                    color: NotesColors.ink,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    maxLines: null,
                    expands: true,
                    style: NotesText.editor,
                    cursorColor: NotesColors.cream,
                    decoration: const InputDecoration(
                      hintText: 'Type Anything To Remember',
                      hintStyle: NotesText.editor,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 50,
                child: IconButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  icon: const Icon(Icons.check, color: NotesColors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final fields = [
      'Add Your Name Here',
      'Your Age',
      'College Name',
      'About You',
      'Give Rating To Us',
      'Feedback',
      'How To Use ?',
    ];
    return Container(
      height: 650,
      margin: const EdgeInsets.only(top: 90),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: const BoxDecoration(
        color: NotesColors.ink,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: NotesColors.muted,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person, color: NotesColors.cream, size: 22),
                    SizedBox(width: 6),
                    Text('Profile', style: NotesText.profile),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: NotesColors.cream,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...fields.map(
            (field) => Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: NotesColors.muted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(field, style: NotesText.profile),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(note),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade300,
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(Icons.delete_outline),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.fromLTRB(22, 20, 18, 12),
          decoration: BoxDecoration(
            color: NotesColors.ink,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Text(
            note.text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: NotesText.editor,
          ),
        ),
      ),
    );
  }
}

class Weekdays extends StatelessWidget {
  const Weekdays({super.key, required this.onSelected});
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(days.length, (index) {
        final selected = index == 1;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? NotesColors.muted : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(days[index], style: NotesText.caption),
          ),
        );
      }),
    );
  }
}

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 8,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('09:41', style: NotesText.status),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 15, color: NotesColors.ink),
              SizedBox(width: 7),
              Icon(Icons.wifi, size: 18, color: NotesColors.ink),
              SizedBox(width: 7),
              Icon(Icons.battery_full, size: 19, color: NotesColors.ink),
            ],
          ),
        ],
      ),
    );
  }
}

class NotesBackground extends StatelessWidget {
  const NotesBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NotesColors.paper,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: DotPatternPainter())),
          child,
        ],
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = NotesColors.ink.withValues(alpha: .18);
    for (double y = 4; y < size.height; y += 8) {
      for (double x = 4; x < size.width; x += 8) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NotesColors.ink.withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    final rect = Rect.fromLTWH(
      size.width * .1,
      -60,
      size.width * .8,
      size.height * 1.1,
    );
    canvas.drawArc(rect, .15, 2.75, false, paint);
    canvas.drawArc(rect.deflate(22), .2, 2.5, false, paint..strokeWidth = 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FooterCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromLTWH(-20, 0, size.width + 40, size.height * 2.4),
      Paint()..color = NotesColors.yellow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

abstract final class NotesText {
  static const status = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: NotesColors.ink,
  );
  static const logo = TextStyle(
    fontSize: 32,
    letterSpacing: 2,
    color: NotesColors.ink,
    fontWeight: FontWeight.bold,
  );
  static const clock = TextStyle(
    fontSize: 72,
    height: .95,
    color: NotesColors.ink,
    fontWeight: FontWeight.w700,
  );
  static const caption = TextStyle(
    fontSize: 14,
    color: NotesColors.secondary,
    fontWeight: FontWeight.bold,
  );
  static const editor = TextStyle(
    fontSize: 14,
    height: 1.35,
    color: NotesColors.cream,
    fontWeight: FontWeight.bold,
  );
  static const profile = TextStyle(
    fontSize: 15,
    color: NotesColors.cream,
    fontWeight: FontWeight.bold,
  );
  static const footer = TextStyle(
    fontSize: 14,
    height: .95,
    color: NotesColors.secondary,
  );
}
