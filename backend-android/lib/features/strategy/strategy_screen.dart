import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/models.dart';

class StrategyScreen extends StatelessWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final tasks = appState.tasks;
        final completedCount = tasks.where((t) => t.isCompleted).length;
        final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;
        final currentRoom = appState.currentRoom;

        return Scaffold(
          backgroundColor: const Color(0xFF121216),
          body: Column(
            children: [
              _buildHeader(context, currentRoom),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildProgressSection(context, completedCount, tasks.length, progress),
                      const SizedBox(height: 24),
                      _buildTaskList(context, tasks, appState),
                      const SizedBox(height: 24),
                      _buildAITipCard(context, appState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Room? room) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF121216).withOpacity(0.7),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFa65eed).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFa65eed), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Strategy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                        room?.name.toUpperCase() ?? 'ORGANIZATION BUTLER',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ),
                color: AppColors.cardDark,
                onSelected: (value) {
                  // Handle menu actions
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'reset', child: Text('Reset Tasks', style: TextStyle(color: Colors.white))),
                  const PopupMenuItem(value: 'share', child: Text('Share Progress', style: TextStyle(color: Colors.white))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, int completed, int total, double progress) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Refined Cleanup', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('$completed of $total tasks completed', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${(progress * 100).toInt()}', style: const TextStyle(color: Color(0xFFa65eed), fontSize: 32, fontWeight: FontWeight.w700)),
                    const TextSpan(text: '%', style: TextStyle(color: Color(0xFFa65eed), fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: const Color(0xFFa65eed),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: const Color(0xFFa65eed).withOpacity(0.4), blurRadius: 15)],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          progress < 0.5
              ? 'Great start! Keep the momentum going.'
              : progress < 1.0
              ? 'Almost there! Your focus is peak.'
              : '🎉 All tasks completed!',
          style: TextStyle(color: AppColors.textTertiary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, List<CleanupTask> tasks, AppState appState) {
    // Sort tasks: incomplete first, then by priority
    final sortedTasks = [...tasks]..sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.priority.compareTo(b.priority);
    });

    return Column(
      children: sortedTasks.map((task) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildTaskCard(context, task, appState),
      )).toList(),
    );
  }

  Widget _buildTaskCard(BuildContext context, CleanupTask task, AppState appState) {
    final isActive = !task.isCompleted && appState.tasks.where((t) => !t.isCompleted).first.id == task.id;

    return GestureDetector(
      onTap: () => appState.toggleTask(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFFa65eed).withOpacity(0.2) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: task.isCompleted
                    ? const RadialGradient(colors: [Color(0xFFA11BEB), Color(0xFF8822DD)])
                    : null,
                border: Border.all(
                  color: task.isCompleted
                      ? Colors.transparent
                      : isActive
                      ? const Color(0xFFa65eed).withOpacity(0.6)
                      : Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: task.isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
            const SizedBox(width: 16),
            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.isCompleted ? Colors.white.withOpacity(0.5) : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFFa65eed).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(task.description, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
            // Duration
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFa65eed).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${task.durationMinutes} min',
                style: TextStyle(
                  color: isActive ? const Color(0xFFa65eed) : AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAITipCard(BuildContext context, AppState appState) {
    final tips = [
      "Studies show that a clear desk reduces cortisol levels by 15%. You're not just cleaning; you're optimizing your mental bandwidth.",
      "Try the 'one in, one out' rule: for every new item you bring in, remove one old item.",
      "The 20/20 rule: If you can replace something for under \$20 in under 20 minutes, you probably don't need to keep it.",
      "Cleaning in 15-minute bursts is more effective than marathon sessions.",
    ];

    final tip = tips[DateTime.now().minute % tips.length];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFa65eed).withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFa65eed).withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFa65eed).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFFa65eed), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Butler's Insight", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(tip, style: TextStyle(color: AppColors.textTertiary, fontSize: 12, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}