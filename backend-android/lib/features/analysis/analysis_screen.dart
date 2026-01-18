import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/models.dart';
import '../strategy/strategy_screen.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final room = appState.currentRoom;

        if (room == null) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(child: Text('No room selected', style: TextStyle(color: Colors.white))),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Stack(
            children: [
              // Room image with detected objects overlay
              Positioned.fill(
                child: _buildRoomImage(room),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.backgroundDark.withOpacity(0.8),
                        AppColors.backgroundDark,
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, room),
                    const Spacer(),
                    _buildAnalysisCard(context, room, appState),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoomImage(Room room) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          room.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.cardDark,
            child: const Icon(Icons.image, size: 64, color: Colors.white24),
          ),
        ),
        // Detected objects overlay
        ...room.clutterItems.map((item) => _buildDetectionBox(item)),
      ],
    );
  }

  Widget _buildDetectionBox(ClutterItem item) {
    return Positioned(
      left: item.boundingBox.left * 400,
      top: item.boundingBox.top * 600,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getActionColor(item.suggestedAction).withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: _getActionColor(item.suggestedAction), width: 2),
        ),
        child: Text(
          item.label,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Color _getActionColor(ClutterAction action) {
    switch (action) {
      case ClutterAction.discard: return AppColors.softRose;
      case ClutterAction.relocate: return AppColors.electricTeal;
      case ClutterAction.donate: return AppColors.primary;
      case ClutterAction.keep: return AppColors.neonLime;
    }
  }

  Widget _buildHeader(BuildContext context, Room room) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: room.status == RoomStatus.analyzed ? AppColors.neonLime : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  room.status == RoomStatus.analyzed ? 'ANALYZED' : 'CLEANED',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, Room room, AppState appState) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${room.clutterItems.length} items detected',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  ),
                ],
              ),
              _buildScoreCircle(room.clutterScore),
            ],
          ),
          const SizedBox(height: 24),
          // Clutter breakdown
          Row(
            children: [
              _buildBreakdownItem('Discard', room.clutterItems.where((i) => i.suggestedAction == ClutterAction.discard).length, AppColors.softRose),
              _buildBreakdownItem('Relocate', room.clutterItems.where((i) => i.suggestedAction == ClutterAction.relocate).length, AppColors.electricTeal),
              _buildBreakdownItem('Keep', room.clutterItems.where((i) => i.suggestedAction == ClutterAction.keep).length, AppColors.neonLime),
            ],
          ),
          const SizedBox(height: 24),
          // Action button
          GestureDetector(
            onTap: () {
              appState.generateTasksForRoom(room.id, room.clutterItems);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StrategyScreen()));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Start Cleanup Strategy',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCircle(int score) {
    final color = score < 30 ? AppColors.neonLime : score < 70 ? Colors.orange : AppColors.softRose;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              'SCORE',
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}