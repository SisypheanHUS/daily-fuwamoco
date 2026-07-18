import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/section_label.dart';
import '../../greeting/data/greeting_context.dart';
import '../../greeting/logic/greeting_providers.dart';
import '../logic/settings_controller.dart';

/// Settings per PRD §7. The "Test greeting" button never touches the
/// greeted-today flags (NFR: testability).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(Gap.md),
        children: [
          const SectionLabel('Preferences'),
          const SizedBox(height: Gap.sm),
          _DisplayNameField(
            initialValue: settings.displayName,
            onChanged: controller.setDisplayName,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduce motion'),
            subtitle: const Text('Stops the twins\' idle breathing animation'),
            value: settings.reduceMotion,
            onChanged: controller.setReduceMotion,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable morning greeting'),
            subtitle: const Text('Off skips the whole sequence, straight to home'),
            value: settings.greetingEnabled,
            onChanged: controller.setGreetingEnabled,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Greeting volume'),
            subtitle: Slider(
              value: settings.greetingVolume,
              onChanged: settings.audioAllowed
                  ? controller.setGreetingVolume
                  : null,
              divisions: 20,
              label: '${(settings.greetingVolume * 100).round()}%',
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Random greeting'),
            subtitle: const Text('Off always plays the first clip'),
            value: settings.randomGreeting,
            onChanged:
                settings.audioAllowed ? controller.setRandomGreeting : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mute all voice playback'),
            subtitle: const Text('Overrides everything else'),
            value: settings.muteAll,
            onChanged: controller.setMuteAll,
          ),
          const SizedBox(height: Gap.lg),
          const SectionLabel('About'),
          const SizedBox(height: Gap.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Test greeting'),
            subtitle: const Text('Plays one clip now — does not affect the daily greeting'),
            trailing: FilledButton.tonal(
              onPressed: () => _testGreeting(context, ref),
              child: const Text('Play'),
            ),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Daily FUWAMOCO'),
            subtitle: Text('v0.1.0 · local-only, no accounts'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Reset my data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Clears everything on this device — can\'t be undone'),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _testGreeting(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (settings.muteAll) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Muted — turn off "Mute all" to test.')),
      );
      return;
    }

    final pack = await ref.read(greetingPackProvider.future);
    final provider = ref.read(greetingContentProvider);
    final eligible = provider.getEligibleClips(
      GreetingContext(date: DateTime.now()),
      pack.clips,
    );
    final clip = provider.pickOne(eligible, random: settings.randomGreeting);
    if (clip == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No greeting clips available.')),
      );
      return;
    }
    await ref
        .read(greetingAudioProvider)
        .play(pack, clip, volume: settings.greetingVolume);
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset my data?'),
        content: const Text(
          'This clears your streak, habits, check-ins, notifications and '
          'collected charms on this device. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appResetProvider)();
    }
  }
}

class _DisplayNameField extends StatefulWidget {
  const _DisplayNameField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_DisplayNameField> createState() => _DisplayNameFieldState();
}

class _DisplayNameFieldState extends State<_DisplayNameField> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: const InputDecoration(
          labelText: 'Your name',
          hintText: 'What should we call you?',
        ),
      ),
    );
  }
}
