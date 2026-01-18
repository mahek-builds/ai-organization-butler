// ==================== USER MODEL ====================
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isPremium;
  final int streakDays;
  final int totalItemsSorted;
  final DateTime joinedDate;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.isPremium = false,
    this.streakDays = 0,
    this.totalItemsSorted = 0,
    DateTime? joinedDate,
  }) : joinedDate = joinedDate ?? DateTime.now();

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    bool? isPremium,
    int? streakDays,
    int? totalItemsSorted,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      streakDays: streakDays ?? this.streakDays,
      totalItemsSorted: totalItemsSorted ?? this.totalItemsSorted,
      joinedDate: joinedDate,
    );
  }
}

// ==================== ROOM MODEL ====================
enum RoomStatus { pending, scanning, analyzed, cleaned }

class Room {
  final String id;
  final String name;
  final String imageUrl;
  final RoomStatus status;
  final int clutterScore;
  final DateTime? lastScanned;
  final DateTime? completedAt;
  final List<ClutterItem> clutterItems;

  Room({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.status = RoomStatus.pending,
    this.clutterScore = 0,
    this.lastScanned,
    this.completedAt,
    this.clutterItems = const [],
  });

  bool get isSpotless => clutterScore < 20;
  bool get isChaosMode => clutterScore > 80;

  Room copyWith({
    String? name,
    String? imageUrl,
    RoomStatus? status,
    int? clutterScore,
    DateTime? lastScanned,
    DateTime? completedAt,
    List<ClutterItem>? clutterItems,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      clutterScore: clutterScore ?? this.clutterScore,
      lastScanned: lastScanned ?? this.lastScanned,
      completedAt: completedAt ?? this.completedAt,
      clutterItems: clutterItems ?? this.clutterItems,
    );
  }
}

// ==================== CLUTTER ITEM MODEL ====================
enum ClutterAction { discard, relocate, keep, donate }

class ClutterItem {
  final String id;
  final String label;
  final ClutterAction suggestedAction;
  final double confidence;
  final Rect boundingBox;
  final bool isProcessed;

  ClutterItem({
    required this.id,
    required this.label,
    required this.suggestedAction,
    this.confidence = 0.9,
    required this.boundingBox,
    this.isProcessed = false,
  });

  ClutterItem copyWith({bool? isProcessed}) {
    return ClutterItem(
      id: id,
      label: label,
      suggestedAction: suggestedAction,
      confidence: confidence,
      boundingBox: boundingBox,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

class Rect {
  final double left, top, width, height;
  const Rect(this.left, this.top, this.width, this.height);
}

// ==================== TASK MODEL ====================
class CleanupTask {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final bool isCompleted;
  final String roomId;
  final int priority;

  CleanupTask({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.isCompleted = false,
    required this.roomId,
    this.priority = 0,
  });

  CleanupTask copyWith({bool? isCompleted, int? priority}) {
    return CleanupTask(
      id: id,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      roomId: roomId,
      priority: priority ?? this.priority,
    );
  }
}

// ==================== INSIGHT MODEL ====================
enum InsightType { tip, warning, achievement, stat }

class Insight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final String? value;
  final String? change;
  final DateTime createdAt;

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.value,
    this.change,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// ==================== ACHIEVEMENT MODEL ====================
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredValue;
  final int currentValue;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
    this.requiredValue = 0,
    this.currentValue = 0,
  });

  double get progress => requiredValue > 0 ? currentValue / requiredValue : 0;

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt, int? currentValue}) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requiredValue: requiredValue,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}

// ==================== CHAT MESSAGE MODEL ====================
enum MessageType { text, image, suggestion, system }

class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final MessageType type;
  final DateTime timestamp;
  final List<String>? suggestions;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.suggestions,
    this.imageUrl,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ==================== APP SETTINGS MODEL ====================
class AppSettings {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String aiPersonality;
  final String scanFrequency;
  final TimeOfDay scheduledScanTime;

  AppSettings({
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.aiPersonality = 'Sophisticated Butler',
    this.scanFrequency = 'Daily',
    this.scheduledScanTime = const TimeOfDay(hour: 8, minute: 0),
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? aiPersonality,
    String? scanFrequency,
    TimeOfDay? scheduledScanTime,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      aiPersonality: aiPersonality ?? this.aiPersonality,
      scanFrequency: scanFrequency ?? this.scanFrequency,
      scheduledScanTime: scheduledScanTime ?? this.scheduledScanTime,
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  const TimeOfDay({required this.hour, required this.minute});

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$m $period';
  }
}