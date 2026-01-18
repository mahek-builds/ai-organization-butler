import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/models.dart';
import '../processing/processing_screen.dart';
import '../analysis/analysis_screen.dart';
import '../strategy/strategy_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, appState.user),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildPrimaryActionCard(context, appState),
                        const SizedBox(height: 24),
                        _buildStreakCard(context, appState),
                        const SizedBox(height: 24),
                        _buildInsightsSection(context, appState),
                        const SizedBox(height: 24),
                        _buildActiveTasksSection(context, appState),
                        const SizedBox(height: 24),
                        _buildRecentRoomsSection(context, appState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile user) {
    final greeting = _getGreeting();
    final now = DateTime.now();
    final dateStr = '${_getDayName(now.weekday).toUpperCase()}, ${_getMonthName(now.month).toUpperCase()} ${now.day}, ${now.year}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user.name}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _IconButton(
                icon: Icons.notifications_outlined,
                onTap: () => _showNotifications(context),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  // Navigate to profile (tab 3)
                  // Will be handled by MainNavigation
                },
                child: Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      user.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardDark,
                        child: const Icon(Icons.person, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard(BuildContext context, AppState appState) {
    // Get the room that needs attention (highest clutter score)
    final roomToOptimize = appState.rooms.where((r) => r.status == RoomStatus.analyzed).isNotEmpty
        ? appState.rooms.where((r) => r.status == RoomStatus.analyzed).reduce((a, b) => a.clutterScore > b.clutterScore ? a : b)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top highlight line
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI VISION ACTIVE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          roomToOptimize != null
                              ? 'Ready to optimize\nyour ${roomToOptimize.name.toLowerCase()}?'
                              : 'Ready to scan\na new room?',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.view_in_ar, color: AppColors.softLavender, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Room preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          roomToOptimize?.imageUrl ?? 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.cardDark,
                            child: const Icon(Icons.image, size: 48),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16, bottom: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.neonLime,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: AppColors.neonLime.withOpacity(0.6), blurRadius: 8)],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Spatial mapping ready',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Scan button
                GestureDetector(
                  onTap: () {
                    if (roomToOptimize != null) {
                      // Go to analysis of existing room
                      appState.selectRoom(roomToOptimize.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AnalysisScreen()),
                      );
                    } else {
                      // Start new scan
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProcessingScreen()),
                      );
                    }
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepLavender.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.center_focus_strong, color: AppColors.backgroundDark, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          roomToOptimize != null ? 'View Analysis' : 'Scan Room',
                          style: const TextStyle(
                            color: AppColors.backgroundDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

  Widget _buildStreakCard(BuildContext context, AppState appState) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardDark.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neonLime.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonLime.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.local_fire_department, color: AppColors.neonLime, size: 24),
                  ),
                  Positioned(
                    top: -2, right: -2,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.neonLime,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardDark, width: 2),
                        boxShadow: [BoxShadow(color: AppColors.neonLime.withOpacity(0.6), blurRadius: 8)],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${appState.user.streakDays} Day Streak',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appState.user.streakDays >= 7 ? 'Consistent for ${appState.user.streakDays ~/ 7} week(s). Keep it up!' : 'Build your streak by organizing daily!',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to insights tab
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Text('STATS', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context, AppState appState) {
    final insights = appState.todayInsights;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'DAILY INSIGHTS',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _InsightCard(
              icon: Icons.inventory_2,
              iconColor: AppColors.primary,
              label: 'Sorted',
              value: insights[0].value ?? '0',
              suffix: 'items',
            )),
            const SizedBox(width: 16),
            Expanded(child: _InsightCard(
              icon: Icons.cleaning_services,
              iconColor: AppColors.neonLime,
              label: 'Clutter',
              value: insights[1].value ?? '0%',
              suffix: 'today',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveTasksSection(BuildContext context, AppState appState) {
    final incompleteTasks = appState.tasks.where((t) => !t.isCompleted).take(2).toList();
    if (incompleteTasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ACTIVE TASKS', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StrategyScreen())),
              child: Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...incompleteTasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TaskCard(task: task, onTap: () {
            appState.toggleTask(task.id);
          }),
        )),
      ],
    );
  }

  Widget _buildRecentRoomsSection(BuildContext context, AppState appState) {
    final recentRooms = appState.cleanedRooms.take(2).toList();
    if (recentRooms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RECENT SPACES', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        ...recentRooms.map((room) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RoomCard(room: room, onTap: () {
            appState.selectRoom(room.id);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalysisScreen()));
          }),
        )),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _NotificationItem(icon: Icons.check_circle, color: AppColors.neonLime, title: 'Task Completed!', subtitle: 'You organized your desk surface', time: '2h ago'),
            _NotificationItem(icon: Icons.local_fire_department, color: Colors.orange, title: 'Streak Extended!', subtitle: '7 days of consistent organizing', time: '1d ago'),
            _NotificationItem(icon: Icons.emoji_events, color: AppColors.primary, title: 'Achievement Unlocked', subtitle: 'You earned "Zen Master" badge', time: '2d ago'),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getDayName(int day) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day];
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}

// ==================== REUSABLE WIDGETS ====================

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? suffix;

  const _InsightCard({required this.icon, required this.iconColor, required this.label, required this.value, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(label.toUpperCase(), style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(suffix!, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final CleanupTask task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: task.isCompleted ? AppColors.neonLime.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? AppColors.neonLime : Colors.transparent,
                border: Border.all(color: task.isCompleted ? AppColors.neonLime : AppColors.primary.withOpacity(0.5), width: 2),
              ),
              child: task.isCompleted ? const Icon(Icons.check, color: AppColors.backgroundDark, size: 16) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.isCompleted ? Colors.white.withOpacity(0.5) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(task.description, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
            Text('${task.durationMinutes} min', style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const _RoomCard({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56, height: 56,
                child: Image.network(room.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceDark, child: const Icon(Icons.home, size: 24))),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: room.isSpotless ? Colors.green : Colors.orange, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(room.isSpotless ? 'Spotless' : 'Score: ${room.clutterScore}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}