import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/tracker.dart';
import '../services/notifications.dart';
import '../widgets/app_colors.dart';
import '../widgets/circular_progress.dart';
import '../widgets/decorations.dart';

class DetailScreen extends StatefulWidget {
  final Tracker tracker;
  const DetailScreen({super.key, required this.tracker});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _changed = false;
  late ConfettiController _confettiController;

  Tracker get t => widget.tracker;
  List<Color> get colors => AppColors.getGradient(t.colorIndex);

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    final days = t.daysElapsed;
    final milestones = [7, 14, 30, 60, 90, 180, 365];
    if (days > 0 && milestones.contains(days) && days >= t.bestStreak) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Tracker'),
        content: Text(
            'Reset "${t.name}"?\nStreak saat ini (${t.daysElapsed} hari) akan disimpan sebagai best streak jika lebih tinggi.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Reset')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        t.reset();
        _changed = true;
      });
      _confettiController.play();
    }
  }

  void _editReminder() async {
    final time = await showTimePicker(
      context: context,
      initialTime: t.reminderTime != null
          ? TimeOfDay(
              hour: int.parse(t.reminderTime!.split(':')[0]),
              minute: int.parse(t.reminderTime!.split(':')[1]),
            )
          : const TimeOfDay(hour: 20, minute: 0),
    );
    if (time != null) {
      setState(() {
        t.reminderTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        _changed = true;
      });
      await NotificationService.scheduleDailyReminder(t);
    }
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tracker'),
        content: Text('Apakah kamu yakin ingin menghapus "${t.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    }
  }

  void _editTracker() {
    final nameCtrl = TextEditingController(text: t.name);
    final emojiCtrl = TextEditingController(text: t.emoji);
    int selectedColor = t.colorIndex;
    DateTime tempStartDate = t.startDate;

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
                      color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Edit Tracker',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 20),
                TextField(
                  controller: emojiCtrl,
                  decoration: InputDecoration(
                    labelText: 'Emoji',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    filled: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Tracker',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    filled: true,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                // Edit Tanggal Mulai
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    leading: Icon(Icons.calendar_month_rounded,
                        color: AppColors.getPrimary(selectedColor)),
                    title: const Text('Tanggal Mulai'),
                    subtitle: Text(_formatDate(tempStartDate)),
                    trailing: const Icon(Icons.edit_calendar_rounded),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: tempStartDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        if (!mounted) return;
                        setSheetState(() => tempStartDate = picked);
                      }
                    },
                  ),
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
                                    width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _delete();
                      },
                      icon: const Icon(Icons.delete_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
                        foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final newName = nameCtrl.text.trim();
                          if (newName.isEmpty) return;
                          setState(() {
                            t.name = newName;
                            t.emoji = emojiCtrl.text.trim().isEmpty
                                ? '🎯'
                                : emojiCtrl.text.trim();
                            t.colorIndex = selectedColor;
                            t.startDate = tempStartDate;
                            _changed = true;
                          });
                          if (t.reminderTime != null) {
                            NotificationService.scheduleDailyReminder(t);
                          }
                          Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppColors.getPrimary(selectedColor),
                        ),
                        child: const Text('Simpan Perubahan',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = t.daysElapsed;
    t.updateBestStreak();
    if (days >= t.bestStreak) _changed = true;

    return DecorativeBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 310,
                  pinned: true,
                  backgroundColor: colors[0],
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context, _changed),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      onPressed: _editTracker,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Text(t.emoji, style: const TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                t.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CircularProgress(
                              days: days,
                              gradient: const [Colors.white, Colors.white70],
                              size: 110,
                              strokeWidth: 9,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                theme,
                                icon: Icons.calendar_today_rounded,
                                label: 'Mulai',
                                value: _formatDate(t.startDate),
                                color: colors[0],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                theme,
                                icon: Icons.local_fire_department_rounded,
                                label: 'Best Streak',
                                value: '${t.bestStreak} hari',
                                color: colors[1],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                theme,
                                icon: Icons.notifications_active_rounded,
                                label: 'Pengingat',
                                value: t.reminderTime ?? 'Tidak aktif',
                                color: colors[0],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                theme,
                                icon: Icons.trending_up_rounded,
                                label: 'Streak Saat Ini',
                                value: '$days hari',
                                color: colors[1],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _milestoneSection(theme, days),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _editReminder,
                                icon: const Icon(Icons.notifications_outlined),
                                label: const Text('Pengingat'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  side: BorderSide(color: colors[0]),
                                  foregroundColor: colors[0],
                                  backgroundColor: theme.colorScheme.surface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _reset,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reset'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 100,
                minBlastForce: 80,
                gravity: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _milestoneSection(ThemeData theme, int days) {
    final milestones = [7, 14, 30, 60, 90, 180, 365];
    final nextMilestone =
        milestones.firstWhere((m) => m > days, orElse: () => days + 30);
    final progress = (days / nextMilestone).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Milestone Berikutnya',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[0].withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$nextMilestone hari',
                    style: TextStyle(
                      color: colors[0],
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colors[0]),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$days / $nextMilestone hari (${(progress * 100).toInt()}%)',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: milestones.map((m) {
              final achieved = days >= m;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: achieved
                      ? colors[0].withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: achieved
                        ? colors[0].withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (achieved)
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: colors[0]),
                    if (achieved) const SizedBox(width: 4),
                    Text(
                      '$m hari',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            achieved ? FontWeight.w600 : FontWeight.w400,
                        color: achieved
                            ? colors[0]
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
