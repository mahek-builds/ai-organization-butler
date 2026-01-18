import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // ==================== USER STATE ====================
  UserProfile _user = UserProfile(
    id: 'user_1',
    name: 'Julian',
    email: 'julian.vane@organizationbutler.ai',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    isPremium: true,
    streakDays: 7,
    totalItemsSorted: 1248,
  );

  UserProfile get user => _user;

  void updateUser(UserProfile user) {
    _user = user;
    notifyListeners();
  }

  void incrementStreak() {
    _user = _user.copyWith(streakDays: _user.streakDays + 1);
    notifyListeners();
  }

  void addSortedItems(int count) {
    _user = _user.copyWith(totalItemsSorted: _user.totalItemsSorted + count);
    _checkAchievements();
    notifyListeners();
  }

  // ==================== ROOMS STATE ====================
  List<Room> _rooms = [
    Room(
      id: 'room_1',
      name: 'Main Bedroom',
      imageUrl: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=400',
      status: RoomStatus.cleaned,
      clutterScore: 12,
      completedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Room(
      id: 'room_2',
      name: 'Home Office',
      imageUrl: 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400',
      status: RoomStatus.analyzed,
      clutterScore: 88,
      lastScanned: DateTime.now().subtract(const Duration(hours: 2)),
      clutterItems: [
        ClutterItem(
          id: 'item_1',
          label: 'Old magazines',
          suggestedAction: ClutterAction.discard,
          boundingBox: const Rect(0.15, 0.20, 0.25, 0.20),
        ),
        ClutterItem(
          id: 'item_2',
          label: 'Unused cables',
          suggestedAction: ClutterAction.relocate,
          boundingBox: const Rect(0.55, 0.50, 0.30, 0.25),
        ),
      ],
    ),
    Room(
      id: 'room_3',
      name: 'Living Room',
      imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
      status: RoomStatus.cleaned,
      clutterScore: 8,
      completedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Room(
      id: 'room_4',
      name: 'Guest Room',
      imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400',
      status: RoomStatus.cleaned,
      clutterScore: 15,
      completedAt: DateTime.now().subtract(const Duration(days: 33)),
    ),
  ];

  Room? _currentRoom;
  Room? _scanningRoom;

  List<Room> get rooms => _rooms;
  List<Room> get cleanedRooms => _rooms.where((r) => r.status == RoomStatus.cleaned).toList();
  Room? get currentRoom => _currentRoom;
  Room? get scanningRoom => _scanningRoom;

  void selectRoom(String roomId) {
    _currentRoom = _rooms.firstWhere((r) => r.id == roomId, orElse: () => _rooms.first);
    notifyListeners();
  }

  void startScanning(String roomName, String imageUrl) {
    final newRoom = Room(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      name: roomName,
      imageUrl: imageUrl,
      status: RoomStatus.scanning,
      lastScanned: DateTime.now(),
    );
    _scanningRoom = newRoom;
    notifyListeners();
  }

  void completeScan(int clutterScore, List<ClutterItem> items) {
    if (_scanningRoom != null) {
      final analyzed = _scanningRoom!.copyWith(
        status: RoomStatus.analyzed,
        clutterScore: clutterScore,
        clutterItems: items,
      );
      _rooms.insert(0, analyzed);
      _currentRoom = analyzed;
      _scanningRoom = null;
      notifyListeners();
    }
  }

  void markRoomCleaned(String roomId) {
    final index = _rooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        status: RoomStatus.cleaned,
        clutterScore: 0,
        completedAt: DateTime.now(),
      );
      addSortedItems(_rooms[index].clutterItems.length);
      notifyListeners();
    }
  }

  // ==================== TASKS STATE ====================
  List<CleanupTask> _tasks = [
    CleanupTask(id: 't1', title: 'Organize desk surface', description: 'Clear all non-essential hardware items', durationMinutes: 12, isCompleted: true, roomId: 'room_2', priority: 1),
    CleanupTask(id: 't2', title: 'Categorize tech cables', description: 'Group power cords by device type', durationMinutes: 8, isCompleted: true, roomId: 'room_2', priority: 2),
    CleanupTask(id: 't3', title: 'Clear floor periphery', description: 'Move items to designated storage containers', durationMinutes: 15, isCompleted: false, roomId: 'room_2', priority: 3),
    CleanupTask(id: 't4', title: 'Dust shelving units', description: 'Wipe down high-surface areas', durationMinutes: 5, isCompleted: false, roomId: 'room_2', priority: 4),
    CleanupTask(id: 't5', title: 'Archive paper files', description: 'Sort mail and sensitive documents', durationMinutes: 20, isCompleted: false, roomId: 'room_2', priority: 5),
  ];

  List<CleanupTask> get tasks => _tasks;
  List<CleanupTask> getTasksForRoom(String roomId) => _tasks.where((t) => t.roomId == roomId).toList();

  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  double get taskProgress => _tasks.isEmpty ? 0 : completedTasksCount / _tasks.length;

  void toggleTask(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      if (_tasks[index].isCompleted) {
        addSortedItems(1);
      }
      notifyListeners();
    }
  }

  void addTask(CleanupTask task) {
    _tasks.add(task);
    notifyListeners();
  }

  void generateTasksForRoom(String roomId, List<ClutterItem> items) {
    int priority = 0;
    final newTasks = items.map((item) {
      priority++;
      String title, description;
      int duration;

      switch (item.suggestedAction) {
        case ClutterAction.discard:
          title = 'Discard ${item.label}';
          description = 'Remove and properly dispose of this item';
          duration = 5;
          break;
        case ClutterAction.relocate:
          title = 'Relocate ${item.label}';
          description = 'Move to appropriate storage location';
          duration = 10;
          break;
        case ClutterAction.donate:
          title = 'Donate ${item.label}';
          description = 'Set aside for donation';
          duration = 5;
          break;
        case ClutterAction.keep:
          title = 'Organize ${item.label}';
          description = 'Find a proper place for this item';
          duration = 8;
          break;
      }

      return CleanupTask(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}_$priority',
        title: title,
        description: description,
        durationMinutes: duration,
        roomId: roomId,
        priority: priority,
      );
    }).toList();

    _tasks.addAll(newTasks);
    notifyListeners();
  }

  // ==================== CHAT STATE ====================
  List<ChatMessage> _messages = [
    ChatMessage(
      id: 'msg_1',
      content: "Good evening! I've analyzed your home office. The clutter score is quite high at 88. Shall we begin organizing?",
      isFromUser: false,
      suggestions: ['Yes, let\'s start', 'Show me the analysis', 'Not now'],
    ),
  ];

  List<ChatMessage> get messages => _messages;

  void sendMessage(String content, {String? imageUrl}) {
    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isFromUser: true,
      imageUrl: imageUrl,
      type: imageUrl != null ? MessageType.image : MessageType.text,
    );
    _messages.add(userMessage);
    notifyListeners();

    // Simulate AI response (replace with actual AI integration later)
    Future.delayed(const Duration(milliseconds: 800), () {
      _generateAIResponse(content);
    });
  }

  void _generateAIResponse(String userMessage) {
    String response;
    List<String>? suggestions;

    final lowerMsg = userMessage.toLowerCase();

    if (lowerMsg.contains('start') || lowerMsg.contains('yes')) {
      response = "Great! Let's begin with the desk area. I've identified cables and papers that need organizing. Use the 3-category method:\n\n• Essential: Items used daily\n• Legacy: Occasional use items\n• Waste: Damaged or obsolete";
      suggestions = ['Show me how', 'Next area', 'Set a timer'];
    } else if (lowerMsg.contains('analysis') || lowerMsg.contains('show')) {
      response = "Here's what I found:\n\n🔴 High Priority: Desk surface clutter\n🟡 Medium: Cable management needed\n🟢 Good: Shelving is organized\n\nWould you like me to create a cleanup plan?";
      suggestions = ['Create plan', 'Focus on desk', 'Later'];
    } else if (lowerMsg.contains('timer')) {
      response = "I'll set a 15-minute focus timer for this task. Remember: short focused bursts are more effective than long sessions!\n\n⏱️ Timer: 15:00";
      suggestions = ['Start timer', 'Change duration', 'Skip'];
    } else if (lowerMsg.contains('next')) {
      response = "Moving to the floor area. I see items that should be in storage containers. This will free up 40% more floor space!";
      suggestions = ['Start cleaning', 'See storage tips', 'Go back'];
    } else {
      response = "I understand. Is there anything specific you'd like help with? I can analyze rooms, create cleanup plans, or give organization tips.";
      suggestions = ['Scan a room', 'See my progress', 'Tips'];
    }

    final aiMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: response,
      isFromUser: false,
      suggestions: suggestions,
    );
    _messages.add(aiMessage);
    notifyListeners();
  }

  void clearChat() {
    _messages = [
      ChatMessage(
        id: 'msg_welcome',
        content: "Hello! I'm your Organization Butler. How can I help you today?",
        isFromUser: false,
        suggestions: ['Scan a room', 'View my spaces', 'Get tips'],
      ),
    ];
    notifyListeners();
  }

  // ==================== ACHIEVEMENTS STATE ====================
  List<Achievement> _achievements = [
    Achievement(id: 'a1', name: 'The Purge', description: 'Discard 50 items', iconName: 'cleaning_services', isUnlocked: true, unlockedAt: DateTime.now().subtract(const Duration(days: 5)), requiredValue: 50, currentValue: 50),
    Achievement(id: 'a2', name: 'Zen Master', description: 'Maintain 7-day streak', iconName: 'self_improvement', isUnlocked: true, unlockedAt: DateTime.now().subtract(const Duration(days: 1)), requiredValue: 7, currentValue: 7),
    Achievement(id: 'a3', name: 'Categorizer', description: 'Sort 100 items by category', iconName: 'category', isUnlocked: true, requiredValue: 100, currentValue: 100),
    Achievement(id: 'a4', name: 'Space Maker', description: 'Clean 5 rooms', iconName: 'space_dashboard', requiredValue: 5, currentValue: 3),
    Achievement(id: 'a5', name: 'Minimalist', description: 'Achieve score under 10 in all rooms', iconName: 'minimize', requiredValue: 1, currentValue: 0),
    Achievement(id: 'a6', name: 'Butler Pro', description: 'Use app for 30 days', iconName: 'workspace_premium', requiredValue: 30, currentValue: 14),
  ];

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();

  void _checkAchievements() {
    // Check Space Maker
    final cleanedCount = cleanedRooms.length;
    final spaceMakerIndex = _achievements.indexWhere((a) => a.id == 'a4');
    if (spaceMakerIndex != -1) {
      _achievements[spaceMakerIndex] = _achievements[spaceMakerIndex].copyWith(
        currentValue: cleanedCount,
        isUnlocked: cleanedCount >= 5,
        unlockedAt: cleanedCount >= 5 ? DateTime.now() : null,
      );
    }
    notifyListeners();
  }

  // ==================== SETTINGS STATE ====================
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void toggleNotifications() {
    _settings = _settings.copyWith(notificationsEnabled: !_settings.notificationsEnabled);
    notifyListeners();
  }

  void setAIPersonality(String personality) {
    _settings = _settings.copyWith(aiPersonality: personality);
    notifyListeners();
  }

  void setScanFrequency(String frequency) {
    _settings = _settings.copyWith(scanFrequency: frequency);
    notifyListeners();
  }

  // ==================== INSIGHTS STATE ====================
  List<Insight> get todayInsights => [
    Insight(
      id: 'i1',
      title: 'Items Sorted Today',
      description: 'Great progress!',
      type: InsightType.stat,
      value: '24',
      change: '+8',
    ),
    Insight(
      id: 'i2',
      title: 'Clutter Reduction',
      description: 'Your spaces are cleaner',
      type: InsightType.stat,
      value: '-12%',
    ),
  ];

  // Weekly cleanliness data for chart
  List<int> get weeklyScores => [82, 75, 70, 60, 55, 45, 88];
  int get currentCleanlinessScore => weeklyScores.last;
  int get scoreChange => weeklyScores.last - weeklyScores[weeklyScores.length - 2];
}