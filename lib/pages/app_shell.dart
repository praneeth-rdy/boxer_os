import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shell_provider.dart';
import 'home_page.dart';
import 'progress_page.dart';
import 'skills_page.dart';
import 'train_page.dart';

/// Four-tab shell: Home, Train, Skills, Progress.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellProvider>();
    return Scaffold(
      body: IndexedStack(
        index: shell.tabIndex,
        children: const [HomePage(), TrainPage(), SkillsPage(), ProgressPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.tabIndex,
        onDestinationSelected: shell.showTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.sports_mma_rounded),
            label: 'Train',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_rounded),
            label: 'Skills',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_rounded),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
