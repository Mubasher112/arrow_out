import 'package:flutter/material.dart';
import '../../domain/models/event_model.dart';
import '../../domain/models/event_status.dart';
import '../../domain/repositories/game_repository.dart';
import '../../services/audio_service.dart';
import '../../services/event_service.dart';
import '../../services/reward_service.dart';
import '../theme/app_theme.dart';

class EventScreen extends StatefulWidget {
  final GameRepository repository;
  final AudioService audioService;

  const EventScreen({
    super.key,
    required this.repository,
    required this.audioService,
  });

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late EventService _eventService;
  EventModel? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final rewardService = RewardService(repository: widget.repository);
    _eventService = EventService(
      repository: widget.repository,
      rewardService: rewardService,
    );
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    final ev = await _eventService.evaluateEventProgress();

    if (mounted) {
      setState(() {
        _event = ev;
        _isLoading = false;
      });
    }
  }

  Future<void> _claimReward() async {
    widget.audioService.playSound(SoundType.levelComplete);
    final coins = await _eventService.claimEventReward();
    if (mounted && coins > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$coins Festival Event Coins Claimed!'),
          backgroundColor: AppTheme.goldStar,
        ),
      );
      await _loadEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;

    return Scaffold(
      appBar: AppBar(
        title: Text(event?.title ?? 'Limited-Time Event', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading || event == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Event Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accent.withAlpha(220),
                            AppTheme.primary.withAlpha(220),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.celebration_rounded, size: 54, color: AppTheme.goldStar),
                          const SizedBox(height: 8),
                          Text(
                            event.title.toUpperCase(),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.black, color: Colors.white, letterSpacing: 1.0),
                          ),
                          const SizedBox(height: 4),
                          Text(event.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_rounded, color: AppTheme.goldStar, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  event.status == EventStatus.expired ? 'Event Expired' : 'Ends in 4d 12h',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Objectives List
                    Expanded(
                      child: ListView.builder(
                        itemCount: event.objectives.length,
                        itemBuilder: (context, index) {
                          final obj = event.objectives[index];
                          final ratio = (obj.progress / obj.target).clamp(0.0, 1.0);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: obj.isCompleted ? AppTheme.goldStar : Colors.white10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(obj.description, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                    if (obj.isCompleted)
                                      const Icon(Icons.check_circle_rounded, color: AppTheme.secondary, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: ratio,
                                          minHeight: 8,
                                          backgroundColor: Colors.black26,
                                          color: obj.isCompleted ? AppTheme.goldStar : AppTheme.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('${obj.progress} / ${obj.target}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Claim Event Reward Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: event.isAllObjectivesCompleted && event.status != EventStatus.completed
                              ? AppTheme.goldStar
                              : AppTheme.cardBg,
                          foregroundColor: event.isAllObjectivesCompleted && event.status != EventStatus.completed
                              ? Colors.black
                              : Colors.white38,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: Icon(event.status == EventStatus.completed ? Icons.check_rounded : Icons.emoji_events_rounded),
                        label: Text(
                          event.status == EventStatus.completed
                              ? 'EVENT COMPLETED'
                              : 'CLAIM ${event.rewardAmount} EVENT COINS',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: event.isAllObjectivesCompleted && event.status != EventStatus.completed
                            ? _claimReward
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }
}
