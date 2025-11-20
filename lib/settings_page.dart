import 'package:flutter/material.dart';

import 'services/storage_service.dart';
import 'services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _notificationsEnabled;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = StorageService.notificationsEnabled();
    _messageController = TextEditingController(
      text: StorageService.defaultMessage(),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await StorageService.setNotificationsEnabled(_notificationsEnabled);
    await StorageService.setDefaultMessage(_messageController.text.trim());
    if (!mounted) return;
    // If notifications were disabled, cancel all scheduled notifications.
    // If enabled, schedule notifications for reminders that are enabled.
    final reminders = StorageService.loadReminders();
    if (!_notificationsEnabled) {
      for (final r in reminders) {
        await NotificationService.cancel(r.id.hashCode);
      }
    } else {
      final body = StorageService.defaultMessage();
      for (final r in reminders) {
        if (r.enabled) {
          await NotificationService.scheduleDaily(
            r.id.hashCode,
            r.title,
            body,
            TimeOfDay.fromDateTime(r.time),
          );
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable notifications'),
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            const SizedBox(height: 12),
            const Text('Default reminder message'),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(onPressed: _save, child: const Text('Save')),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
