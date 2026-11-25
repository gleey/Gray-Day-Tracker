import 'package:flutter/material.dart';
import '../models/tracker.dart';
import '../services/storage.dart';
import '../services/notifications.dart';
import '../widgets/tracker_tile.dart';
import '../widgets/app_colors.dart';
import '../widgets/decorations.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Tracker> _trackers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  Future<void> _load() async {
    final trackers = await StorageService.getTrackers();
    setState(() {
      _trackers = trackers;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await StorageService.saveTrackers(_trackers);
    await NotificationService.rescheduleAll(_trackers);
  }

  int get _totalDays => _trackers.fold(0, (sum, t) => sum + t.daysElapsed);
  int get _longestStreak => _trackers.isEmpty
      ? 0
      : _trackers.map((t) => t.bestStreak).reduce((a, b) => a > b ? a : b);

  void addTracker() {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '🎯');
    String? reminderTime;
    int selectedColor = _trackers.length % AppColors.gradients.length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        ctx,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tracker Baru',
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emojiCtrl,
                  decoration: InputDecoration(
                    labelText: 'Emoji',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nama (cth: Berhenti Vape)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Text('Warna', style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppColors.gradients.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final isSelected = i == selectedColor;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = i),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.getGradient(i),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(ctx).colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.getPrimary(selectedColor),
                    ),
                    title: Text(
                      reminderTime ?? 'Atur pengingat harian',
                      style: TextStyle(
                        color: reminderTime != null
                            ? null
                            : Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: reminderTime != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () =>
                                setSheetState(() => reminderTime = null),
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: const TimeOfDay(hour: 20, minute: 0),
                      );
                      if (time != null) {
                        setSheetState(() {
                          reminderTime =
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final tracker = Tracker(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      emoji: emojiCtrl.text.trim().isEmpty
                          ? '🎯'
                          : emojiCtrl.text.trim(),
                      startDate: DateTime.now(),
                      reminderTime: reminderTime,
                      colorIndex: selectedColor,
                    );
                    setState(() => _trackers.add(tracker));
                    _save();
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: AppColors.getPrimary(selectedColor),
                  ),
                  child: const Text(
                    'Mulai Tracking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteTracker(int index) {
    final tracker = _trackers[index];
    NotificationService.cancelReminder(tracker);
    setState(() => _trackers.removeAt(index));
    _save();
  }

  void _openDetail(int index) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(tracker: _trackers[index]),
      ),
    );
    if (result == true) {
      _save();
      setState(() {});
    } else if (result == 'deleted') {
      _deleteTracker(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DecorativeBackground(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              if (_trackers.isNotEmpty)
                SliverToBoxAdapter(child: _buildSummaryCard(context)),
              if (_trackers.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => TrackerTile(
                        tracker: _trackers[i],
                        onTap: () => _openDetail(i),
                        onDelete: () => _deleteTracker(i),
                      ),
                      childCount: _trackers.length,
                    ),
                  ),
                ),
            ],
          ),
          const PeekingMascot(),
          const PeekingMascot(), // Maskot kedua
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
            icon: Icons.track_changes_rounded,
            value: '${_trackers.length}',
            label: 'Tracker',
            theme: theme,
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _summaryItem(
            icon: Icons.calendar_today_rounded,
            value: '$_totalDays',
            label: 'Total Hari',
            theme: theme,
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _summaryItem(
            icon: Icons.local_fire_department_rounded,
            value: '$_longestStreak',
            label: 'Best Streak',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/home.png', width: 140, height: 140),
          const SizedBox(height: 24),
          Text(
            'Belum ada tracker!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan + untuk mulai tracking habit barumu 🌟',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
