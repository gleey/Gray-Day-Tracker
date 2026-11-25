import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tracker.dart';
import '../services/storage.dart';
import '../widgets/decorations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  Profile _profile = Profile();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await StorageService.getProfile();
    setState(() {
      _profile = profile;
      _nameCtrl.text = profile.name;
      _loading = false;
    });
  }

  Future<void> _save() async {
    _profile.name = _nameCtrl.text.trim();
    await StorageService.saveProfile(_profile);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile =
        await File(picked.path).copy('${appDir.path}/$fileName');

    if (_profile.photoPath != null) {
      final old = File(_profile.photoPath!);
      if (await old.exists()) await old.delete();
    }

    setState(() => _profile.photoPath = savedFile.path);
    _save();
  }

  void _removePhoto() async {
    if (_profile.photoPath != null) {
      final old = File(_profile.photoPath!);
      if (await old.exists()) await old.delete();
    }
    setState(() => _profile.photoPath = null);
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final theme = Theme.of(context);

    return DecorativeBackground(
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Avatar with gradient border
          GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: _profile.photoPath != null
                    ? FileImage(File(_profile.photoPath!))
                    : null,
                child: _profile.photoPath == null
                    ? Icon(Icons.person_rounded,
                        size: 56, color: theme.colorScheme.outline)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Edit photo / remove photo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                label: const Text('Ganti Foto'),
              ),
              if (_profile.photoPath != null)
                TextButton.icon(
                  onPressed: _removePhoto,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nama',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => _save(),
          ),
          const SizedBox(height: 32),

          // About card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.08),
                  const Color(0xFF4834DF).withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded,
                          size: 20, color: Color(0xFF6C63FF)),
                    ),
                    const SizedBox(width: 12),
                    Text('Tentang',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Day Tracker membantu kamu menghitung hari dan mempertahankan streak untuk kebiasaan baik.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
