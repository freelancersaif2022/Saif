import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import 'explore_screen.dart';
import 'map_screen.dart';
import 'memories_screen.dart';
import 'walks_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    (Icons.map_outlined, Icons.map_rounded, 'Map'),
    (Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'Explore'),
    (Icons.directions_walk_rounded, Icons.directions_walk_rounded, 'Walks'),
    (Icons.mic_none_rounded, Icons.mic_rounded, 'Memories'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GC.ground,
      extendBody: false,
      body: IndexedStack(
        index: _index,
        children: [
          // Only the visible tab takes part in photo hero animations.
          for (final (i, tab) in const [MapScreen(), ExploreScreen(), WalksScreen(), MemoriesScreen()].indexed)
            HeroMode(enabled: i == _index, child: tab),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: GC.ground,
          border: Border(top: BorderSide(color: GC.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: Semantics(
                      selected: i == _index,
                      button: true,
                      label: _tabs[i].$3,
                      child: InkResponse(
                        onTap: () {
                          if (i == _index) return;
                          HapticFeedback.selectionClick();
                          setState(() => _index = i);
                        },
                        radius: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: i == _index ? GC.amberDeep : Colors.transparent,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Icon(
                                i == _index ? _tabs[i].$2 : _tabs[i].$1,
                                size: 23,
                                color: i == _index ? GC.amber : GC.faint,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _tabs[i].$3,
                              style: GC.body(11.5,
                                  color: i == _index ? GC.amber : GC.faint,
                                  weight: i == _index ? FontWeight.w700 : FontWeight.w600,
                                  height: 1),
                            ),
                          ],
                        ),
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
