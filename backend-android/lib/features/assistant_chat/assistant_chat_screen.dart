import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/state/app_state.dart';
import '../../core/models/models.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage(AppState appState, String content) {
    if (content.trim().isEmpty) return;

    setState(() => _isTyping = true);
    appState.sendMessage(content);
    _messageController.clear();
    _scrollToBottom();

    // Simulate AI thinking
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isTyping = false);
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Column(
            children: [
              _buildHeader(context, appState),
              Expanded(child: _buildChatArea(appState)),
              _buildInputArea(context, appState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    final currentRoom = appState.currentRoom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withOpacity(0.8),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const SizedBox(width: 40, height: 40, child: Icon(Icons.chevron_left, color: Colors.white, size: 28)),
              ),
              Column(
                children: [
                  const Text('BUTLER AI', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF39FF14), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        currentRoom?.name.toUpperCase() ?? 'READY TO HELP',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
                color: AppColors.cardDark,
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      appState.clearChat();
                      break;
                    case 'settings':
                    // Navigate to settings
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'clear', child: Row(children: [Icon(Icons.delete_outline, color: Colors.white70, size: 20), SizedBox(width: 8), Text('Clear Chat', style: TextStyle(color: Colors.white))])),
                  const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings, color: Colors.white70, size: 20), SizedBox(width: 8), Text('AI Settings', style: TextStyle(color: Colors.white))])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(AppState appState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: appState.messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == appState.messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(context, appState.messages[index], appState);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, AppState appState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: message.isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4, right: 4),
            child: Text(
              message.isFromUser ? 'YOU' : 'BUTLER',
              style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: message.isFromUser
                  ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)])
                  : null,
              color: message.isFromUser ? null : AppColors.cardDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(message.isFromUser ? 16 : 0),
                topRight: Radius.circular(message.isFromUser ? 0 : 16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              border: message.isFromUser ? null : Border.all(color: Colors.white.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: message.isFromUser ? const Color(0xFF8659f8).withOpacity(0.2) : Colors.black.withOpacity(0.3),
                  blurRadius: message.isFromUser ? 12 : 16,
                  offset: Offset(0, message.isFromUser ? 4 : 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(color: message.isFromUser ? Colors.white : Colors.grey[300], fontSize: 15, height: 1.5),
                ),
                if (message.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(message.imageUrl!, height: 150, fit: BoxFit.cover),
                  ),
                ],
              ],
            ),
          ),
          // Quick reply suggestions
          if (!message.isFromUser && message.suggestions != null && message.suggestions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestions!.map((suggestion) => _buildSuggestionChip(suggestion, appState)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, AppState appState) {
    return GestureDetector(
      onTap: () => _sendMessage(appState, text),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
            ),
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(150),
                const SizedBox(width: 4),
                _buildDot(300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      builder: (_, value, child) => Opacity(
        opacity: 0.3 + (0.7 * ((value * 2) > 1 ? 2 - value * 2 : value * 2)),
        child: child,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          // AI status indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFFA383F7), Color(0xFF8B5CF6)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 15)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Butler is thinking...', style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          Row(
            children: [
              // Message input
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 4, offset: Offset(0, 2), spreadRadius: -2)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Tell Butler what to do...',
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onSubmitted: (text) => _sendMessage(appState, text),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _sendMessage(appState, _messageController.text),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF39FF14).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_upward, color: Color(0xFF39FF14), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Camera button
              GestureDetector(
                onTap: () => _showImageOptions(context, appState),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Icon(Icons.photo_camera, color: Colors.grey[500], size: 24),
                ),
              ),
            ],
          ),
          // Home indicator
          const SizedBox(height: 16),
          Container(width: 128, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  void _showImageOptions(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Photo', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            _buildImageOption(Icons.camera_alt, 'Take Photo', () {
              Navigator.pop(context);
              // TODO: Implement camera
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera feature coming soon!')));
            }),
            _buildImageOption(Icons.photo_library, 'Choose from Gallery', () {
              Navigator.pop(context);
              // TODO: Implement gallery picker
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery feature coming soon!')));
            }),
            _buildImageOption(Icons.view_in_ar, 'Scan Room', () {
              Navigator.pop(context);
              // Navigate to processing
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF8B5CF6)),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}