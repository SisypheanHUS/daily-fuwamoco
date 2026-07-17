import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
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
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        children: [
          SwitchListTile(
            title: const Text('Enable morning greeting'),
            subtitle: const Text('Off skips the whole sequence, straight to home'),
            value: settings.greetingEnabled,
            onChanged: controller.setGreetingEnabled,
          ),
          ListTile(
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
            title: const Text('Random greeting'),
            subtitle: const Text('Off always plays the first clip'),
            value: settings.randomGreeting,
            onChanged:
                settings.audioAllowed ? controller.setRandomGreeting : null,
          ),
          SwitchListTile(
            title: const Text('Mute all voice playback'),
            subtitle: const Text('Overrides everything else'),
            value: settings.muteAll,
            onChanged: controller.setMuteAll,
          ),
          const Divider(height: Gap.xl),
          ListTile(
            title: const Text('Test greeting'),
            subtitle: const Text('Plays one clip now — does not affect the daily greeting'),
            trailing: FilledButton.tonal(
              onPressed: () => _testGreeting(context, ref),
              child: const Text('Play'),
            ),
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
}
