import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/reminder.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = StorageService.loadReminders();
    setState(() => _reminders = loaded);
  }

  Future<void> _saveAndSchedule() async {
    await StorageService.saveReminders(_reminders);
    // schedule notifications for enabled reminders
    final globalEnabled = StorageService.notificationsEnabled();
    for (final r in _reminders) {
      final id = r.id.hashCode;
      if (!globalEnabled) {
        await NotificationService.cancel(id);
        continue;
      }
      if (r.enabled) {
        final body = StorageService.defaultMessage();
        // NotificationService expects (id, title, body, time)
        await NotificationService.scheduleDaily(
          id,
          r.title,
          body,
          TimeOfDay.fromDateTime(r.time),
        );
      } else {
        await NotificationService.cancel(id);
      }
    }
  }

  Future<void> _addReminder() async {
    final titleController = TextEditingController();
    TimeOfDay selected = TimeOfDay.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Waktu: '),
                TextButton(
                  child: Text(selected.format(context)),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: selected,
                    );
                    if (t != null) {
                      setState(() => selected = t);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final now = DateTime.now();
              final dt = DateTime(
                now.year,
                now.month,
                now.day,
                selected.hour,
                selected.minute,
              );
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final reminder = Reminder(
                id: id,
                title: titleController.text.trim(),
                time: dt,
              );
              _reminders.add(reminder);
              _saveAndSchedule();
              Navigator.of(context).pop(true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) setState(() {});
  }

  Future<void> _toggleEnabled(Reminder r) async {
    r.enabled = !r.enabled;
    await _saveAndSchedule();
    setState(() {});
  }

  Future<void> _remove(Reminder r) async {
    _reminders.removeWhere((e) => e.id == r.id);
    await StorageService.saveReminders(_reminders);
    await NotificationService.cancel(r.id.hashCode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drink Reminder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
              // Reload settings in case default message or notifications were changed
              setState(() {});
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _reminders.isEmpty ? _buildEmpty() : _buildList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Reminder'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.cyan.shade200],
              ),
            ),
            padding: const EdgeInsets.all(18),
            child: const Icon(Icons.local_drink, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada reminder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text('Tambahkan reminder untuk tetap terhidrasi'),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      key: const ValueKey('list'),
      padding: const EdgeInsets.all(12),
      itemCount: _reminders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final r = _reminders[i];
        final formatted = DateFormat.Hm().format(r.time);
        return Dismissible(
          key: ValueKey(r.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _remove(r),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: r.enabled
                    ? Colors.blue.shade100
                    : Colors.grey.shade300,
                child: Icon(
                  Icons.local_drink,
                  color: r.enabled ? Colors.blue : Colors.grey.shade700,
                ),
              ),
              title: Text(
                r.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(formatted),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(value: r.enabled, onChanged: (_) => _toggleEnabled(r)),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editReminder(r),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editReminder(Reminder r) async {
    final titleController = TextEditingController(text: r.title);
    TimeOfDay selected = TimeOfDay.fromDateTime(r.time);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Waktu: '),
                TextButton(
                  child: Text(selected.format(context)),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: selected,
                    );
                    if (t != null) {
                      setState(() => selected = t);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              final now = DateTime.now();
              final dt = DateTime(
                now.year,
                now.month,
                now.day,
                selected.hour,
                selected.minute,
              );
              r.title = titleController.text.trim();
              r.time = dt;
              _saveAndSchedule();
              Navigator.of(context).pop(true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) setState(() {});
  }
}
