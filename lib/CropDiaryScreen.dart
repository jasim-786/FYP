import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/AboutUsScreen.dart';
import 'package:flutter_application_1/LoginScreen.dart';
import 'package:flutter_application_1/Onboarding1.dart';
import 'package:flutter_application_1/PreHomeScreen.dart';
import 'package:flutter_application_1/PreviousResultsScreen.dart';
import 'package:flutter_application_1/ProfileScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppConstants {
  static const primaryColor = Color(0xFF7B5228); // Rich brown
  static const accentColor = Color(0xFFE5D188); // Warm yellow
  static const gradientStart = Color(0xFF7B5228); // Primary brown
  static const gradientEnd = Color(0xFFB8975F); // Lighter brown shade
  static const cardGradientStart = Color(0xFFE5D188); // Accent yellow
  static const cardGradientEnd = Color(0xFFF5E8B8); // Softer yellow
  static const pageSize = 10;
  static const activityTypes = [
    'Sowing',
    'Irrigation',
    'Fertilizer',
    'Spray',
    'Harvest',
    'Other'
  ];
  static const cropStages = ['Germination', 'Tillering', 'Heading', 'Ripening'];
  static const activityColors = {
    'Sowing': Color(0xFF6D4C41), // Muted brown
    'Irrigation': Color(0xFF8D6E63), // Soft brown
    'Fertilizer': Color(0xFF9E7D60), // Earthy tone
    'Spray': Color(0xFF7B5228), // Primary brown
    'Harvest': Color(0xFFB8975F), // Lighter brown
    'Other': Color(0xFF5D4037), // Darker brown
  };
  static const stageProgress = {
    'Germination': 0.25,
    'Tillering': 0.5,
    'Heading': 0.75,
    'Ripening': 1.0,
  };
  static const regions = [
    'Punjab - Cotton Zone',
    'Punjab - Central/Mixed Zone',
    'Punjab - Rice Zone',
    'Sindh - Southern',
    'Sindh - Northern',
    'Khyber Pakhtunkhwa - Barani',
    'Khyber Pakhtunkhwa - Irrigated',
    'Balochistan'
  ];
  static const List<Map<String, dynamic>> growthStages = [
    {
      'stage': 'Germination',
      'daysAfterSowing': 0,
      'duration': 10,
      'tasks': {
        'general':
            'Ensure proper seedbed moisture; check for uniform germination.',
        'Punjab - Cotton Zone':
            'Use 100–120 kg/ha seed; adopt zero-tillage if following rice.',
        'Punjab - Central/Mixed Zone':
            'Use 100–120 kg/ha seed; ensure row spacing of 20–22.5 cm.',
        'Punjab - Rice Zone':
            'Use zero-tillage to save time after rice harvest.',
        'Sindh - Southern':
            'Sow early (Nov 1–20) for optimal yields; use 100–120 kg/ha seed.',
        'Sindh - Northern': 'Sow Nov 10–30; maintain sowing depth at 5–6 cm.',
        'Khyber Pakhtunkhwa - Barani':
            'Sow early (Oct) to utilize monsoon moisture; soak seeds 8–10 hours.',
        'Khyber Pakhtunkhwa - Irrigated':
            'Use 100–120 kg/ha seed; ensure uniform germination.',
        'Balochistan':
            'Use 100–120 kg/ha seed; deep plough to conserve moisture.'
      }
    },
    {
      'stage': 'Tillering',
      'daysAfterSowing': 20,
      'duration': 30,
      'tasks': {
        'general':
            'Apply first irrigation (21–25 DAS); apply potassium humate and nitrogen fertilizer.',
        'Punjab - Cotton Zone':
            'Irrigate at 21–25 DAS; apply N 100–120 kg/ha, P2O5 40–60 kg/ha.',
        'Punjab - Central/Mixed Zone':
            'Irrigate at tillering; use selective herbicides for weeds.',
        'Punjab - Rice Zone':
            'Irrigate at 30–40 DAS; apply zero-tillage fertilizers.',
        'Sindh - Southern':
            'Irrigate at 30–40 DAS; monitor for aphids with trap crops.',
        'Sindh - Northern': 'Irrigate at 30–40 DAS; apply N at tillering.',
        'Khyber Pakhtunkhwa - Barani':
            'Rely on rainfall; use pre-emergence herbicides.',
        'Khyber Pakhtunkhwa - Irrigated':
            'Irrigate at 21–25 DAS; apply potassium humate.',
        'Balochistan':
            'Irrigate if possible; apply farmyard manure (8–10 cart loads/ha).'
      }
    },
    {
      'stage': 'Stem Elongation',
      'daysAfterSowing': 45,
      'duration': 25,
      'tasks': {
        'general':
            'Apply second irrigation; monitor for aphids and rust with IPM.',
        'Punjab - Cotton Zone':
            'Irrigate at 45–50 DAS; control weeds with double bar harrow.',
        'Punjab - Central/Mixed Zone':
            'Irrigate at stem elongation; apply IPM for rust.',
        'Punjab - Rice Zone': 'Irrigate at 45–50 DAS; monitor for pests.',
        'Sindh - Southern':
            'Irrigate; use brassica campestris as trap crop for aphids.',
        'Sindh - Northern': 'Irrigate; apply IPM for pest control.',
        'Khyber Pakhtunkhwa - Barani':
            'Rely on rainfall; use green manuring with Arhar.',
        'Khyber Pakhtunkhwa - Irrigated': 'Irrigate; monitor for rust.',
        'Balochistan': 'Irrigate if water available; check for rust.'
      }
    },
    {
      'stage': 'Flowering/Anthesis',
      'daysAfterSowing': 90,
      'duration': 5,
      'tasks': {
        'general':
            'Apply third irrigation; apply potash and biostimulants for heat stress.',
        'Punjab - Cotton Zone':
            'Irrigate at 90–95 DAS; apply calcium for heat stress.',
        'Punjab - Central/Mixed Zone':
            'Irrigate; use biostimulants to counter heat.',
        'Punjab - Rice Zone': 'Irrigate; apply potash for grain formation.',
        'Sindh - Southern': 'Irrigate; prepare for early harvest (mid-Mar).',
        'Sindh - Northern': 'Irrigate; apply biostimulants.',
        'Khyber Pakhtunkhwa - Barani':
            'Rely on rainfall; monitor for heat stress.',
        'Khyber Pakhtunkhwa - Irrigated': 'Irrigate; apply potash.',
        'Balochistan': 'Irrigate if possible; use resistant varieties for rust.'
      }
    },
    {
      'stage': 'Grain Filling',
      'daysAfterSowing': 100,
      'duration': 5,
      'tasks': {
        'general':
            'Apply fourth irrigation; control weeds and pests (e.g., Hessian fly).',
        'Punjab - Cotton Zone': 'Irrigate at 100–105 DAS; use IPM for pests.',
        'Punjab - Central/Mixed Zone': 'Irrigate; keep fields weed-free.',
        'Punjab - Rice Zone': 'Irrigate; control weeds with herbicides.',
        'Sindh - Southern': 'Irrigate; ensure weed-free fields for harvest.',
        'Sindh - Northern': 'Irrigate; monitor for pests.',
        'Khyber Pakhtunkhwa - Barani': 'Rely on rainfall; manual weed control.',
        'Khyber Pakhtunkhwa - Irrigated': 'Irrigate; use IPM for Hessian fly.',
        'Balochistan': 'Irrigate if water available; prepare for harvest.'
      }
    },
    {
      'stage': 'Milky/Dough Stage',
      'daysAfterSowing': 120,
      'duration': 5,
      'tasks': {
        'general': 'Apply fifth irrigation (if needed); prepare for harvest.',
        'Punjab - Cotton Zone':
            'Irrigate at 120–125 DAS; plan harvest (Apr–May).',
        'Punjab - Central/Mixed Zone':
            'Irrigate; prepare combines for harvest.',
        'Punjab - Rice Zone':
            'Irrigate; store grain to avoid fungal infections.',
        'Sindh - Southern': 'Minimal irrigation; harvest from mid-Mar.',
        'Sindh - Northern': 'Irrigate; harvest by late Mar.',
        'Khyber Pakhtunkhwa - Barani': 'Rely on rainfall; harvest in May.',
        'Khyber Pakhtunkhwa - Irrigated': 'Irrigate; harvest in May.',
        'Balochistan': 'Irrigate if possible; harvest in Apr–May.'
      }
    },
    {
      'stage': 'Harvesting',
      'daysAfterSowing': 150,
      'duration': 50,
      'tasks': {
        'general':
            'Harvest using combines; store grain to avoid fungal infections.',
        'Punjab - Cotton Zone': 'Harvest mid-Apr to mid-May; use combines.',
        'Punjab - Central/Mixed Zone': 'Harvest in May; store properly.',
        'Punjab - Rice Zone': 'Harvest in May; ensure dry storage.',
        'Sindh - Southern': 'Harvest mid-Mar; store grain carefully.',
        'Sindh - Northern': 'Harvest late Mar; use combines.',
        'Khyber Pakhtunkhwa - Barani':
            'Harvest in May; manual or combine harvest.',
        'Khyber Pakhtunkhwa - Irrigated':
            'Harvest in May; store to avoid fungi.',
        'Balochistan': 'Harvest Apr–May; ensure dry storage.'
      }
    },
  ];
}

class CropDiaryScreen extends StatefulWidget {
  final String userId;

  const CropDiaryScreen({required this.userId, super.key});

  @override
  State<CropDiaryScreen> createState() => _CropDiaryScreenState();
}

class _CropDiaryScreenState extends State<CropDiaryScreen>
    with SingleTickerProviderStateMixin {
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isLoadingInitial = true;
  bool _showGuidance = false;
  bool _showSettings = false;
  List<DocumentSnapshot> _diaryEntries = [];
  TimeOfDay? _reminderTime;
  Set<String> _selectedActivities = {};
  String? _selectedRegion;
  DateTime? _sowingDate;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  User? user = FirebaseAuth.instance.currentUser;
  void logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog

                await FirebaseAuth.instance.signOut();

                // Show logout success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logged out successfully"),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Navigate back to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadInitialEntries();
    _checkFirstLaunch();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// Checks if this is the first launch and shows region dialog if needed, also checks for Tillering stage.
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInitialRegionDialog();
      });
      await prefs.setBool('isFirstLaunch', false);
    }

    // Load preferences
    setState(() {
      _selectedRegion = prefs.getString('region');
      final sowingDateString = prefs.getString('sowingDate');
      if (sowingDateString != null) {
        _sowingDate = DateTime.tryParse(sowingDateString);
      }
    });

    // Check for Tillering stage and send notification if needed
    await _checkAndNotifyTillering();
  }

  /// Checks if the crop is in Tillering stage and sends a rust scan notification if not already sent.
  Future<void> _checkAndNotifyTillering({bool fromScreenVisit = false}) async {
    if (_sowingDate == null) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final daysSinceSowing = now.difference(_sowingDate!).inDays;

    // Find current stage
    final currentStage = AppConstants.growthStages.firstWhere(
      (stage) {
        final start = stage['daysAfterSowing'] as int;
        final duration = stage['duration'] as int;
        return daysSinceSowing >= start && daysSinceSowing < start + duration;
      },
      orElse: () => AppConstants.growthStages.last,
    );

    if (currentStage['stage'] == 'Tillering') {
      final String notificationKey =
          'tillering_notification_${_sowingDate!.toIso8601String()}';
      final bool notificationSent = prefs.getBool(notificationKey) ?? false;

      if (!notificationSent || fromScreenVisit) {
        await _showNotification(
          'Rust Disease Alert',
          'Your crop is in the Tillering stage. Please scan for rust disease.',
        );
        // Mark notification as sent only for stage-based trigger, not screen visit
        if (!fromScreenVisit) {
          await prefs.setBool(notificationKey, true);
        }
      }
    }
  }

  /// Saves user preferences to SharedPreferences and resets Tillering notification if sowing date changes.
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final previousSowingDate = prefs.getString('sowingDate');

    if (_selectedRegion != null) {
      await prefs.setString('region', _selectedRegion!);
    }
    if (_sowingDate != null) {
      final newSowingDate = _sowingDate!.toIso8601String();
      await prefs.setString('sowingDate', newSowingDate);
      // Reset Tillering notification if sowing date changes
      if (previousSowingDate != newSowingDate) {
        final oldNotificationKey = 'tillering_notification_$previousSowingDate';
        await prefs.remove(oldNotificationKey);
      }
    }

    // Check for Tillering stage after saving new sowing date
    await _checkAndNotifyTillering();
  }

  /// Shows a dialog for initial region selection, preventing dismissal until a region is selected.
  void _showInitialRegionDialog() {
    String? selectedRegion = AppConstants.regions.first;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without selection
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Select Your Region',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRegion,
                    decoration: InputDecoration(
                      labelText: 'Region',
                      labelStyle:
                          const TextStyle(color: AppConstants.primaryColor),
                      filled: true,
                      fillColor: AppConstants.accentColor.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppConstants.accentColor.withOpacity(0.5)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: AppConstants.regions
                        .map((region) => DropdownMenuItem(
                              value: region,
                              child: Text(
                                region,
                                style: const TextStyle(
                                    color: AppConstants.primaryColor),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRegion = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    foregroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRegion = selectedRegion;
                      _savePreferences();
                    });
                    Navigator.pop(context);
                    _showNotification('Region Selected',
                        'Your region has been set to $selectedRegion.');
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Initializes notification settings for the app.
  Future<void> _initializeNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);
      await _flutterLocalNotificationsPlugin.initialize(settings);
    } catch (e) {
      _showErrorDialog('Notification Error',
          'Failed to initialize notifications. Please check permissions.');
    }
  }

  /// Displays a notification with the given title and body.
  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'crop_diary_channel',
      'Crop Diary Notifications',
      channelDescription: 'Channel for crop diary updates',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(
        0, title, body, platformDetails);
  }

  /// Schedules a reminder for the given activity at the selected time.
  Future<void> _scheduleReminder(String activity, DateTime? taskDate) async {
    if (_reminderTime == null || taskDate == null) return;

    final reminderDateTime = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
      _reminderTime!.hour,
      _reminderTime!.minute,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      Uuid().v4().hashCode,
      'Crop Task Reminder',
      'You have a $activity task scheduled.',
      tz.TZDateTime.from(reminderDateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'crop_diary_reminder',
          'Crop Task Reminders',
          channelDescription: 'Reminders for crop tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Loads the initial set of diary entries from Firestore.
  Future<void> _loadInitialEntries() async {
    setState(() => _isLoadingInitial = true);
    try {
      Query query = FirebaseFirestore.instance
          .collection('crop_diary')
          .doc(widget.userId)
          .collection('logs')
          .orderBy('date', descending: true)
          .limit(AppConstants.pageSize);

      final snapshot = await query.get();
      setState(() {
        _diaryEntries = snapshot.docs;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = snapshot.docs.length == AppConstants.pageSize;
        _isLoadingInitial = false;
      });
    } catch (e) {
      _showErrorDialog('Loading Error',
          'Failed to load diary entries. Please check your connection.');
      setState(() => _isLoadingInitial = false);
    }
  }

  /// Loads additional diary entries for infinite scrolling.
  Future<void> _loadMoreEntries() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    try {
      Query query = FirebaseFirestore.instance
          .collection('crop_diary')
          .doc(widget.userId)
          .collection('logs')
          .orderBy('date', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(AppConstants.pageSize);

      final snapshot = await query.get();
      setState(() {
        _diaryEntries.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMore = snapshot.docs.length == AppConstants.pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      _showErrorDialog(
          'Loading Error', 'Failed to load more entries. Please try again.');
      setState(() => _isLoadingMore = false);
    }
  }

  /// Deletes a diary entry with confirmation.
  Future<void> _deleteEntry(String entryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppConstants.primaryColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('crop_diary')
            .doc(widget.userId)
            .collection('logs')
            .doc(entryId)
            .delete();
        _showNotification('Entry Deleted', 'A diary entry has been deleted.');
        _loadInitialEntries();
      } catch (e) {
        _showErrorDialog(
            'Deletion Error', 'Failed to delete entry. Please try again.');
      }
    }
  }

  /// Shows a custom error dialog with the given title and message.
  Future<void> _showErrorDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
        content: Text(message,
            style: const TextStyle(color: AppConstants.primaryColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: AppConstants.primaryColor)),
          ),
        ],
      ),
    );
  }

  /// Reusable dialog for creating or editing entries.
  void _showEntryDialog({
    required BuildContext context,
    DocumentSnapshot? entry,
    bool isEdit = false,
    String? defaultActivity,
    String? defaultNotes,
  }) {
    final notesController =
        TextEditingController(text: entry?['notes'] ?? defaultNotes ?? '');
    String activity = defaultActivity ??
        entry?['activity_type'] ??
        AppConstants.activityTypes.first;
    String stage = entry?['crop_stage'] ?? AppConstants.cropStages.first;
    _reminderTime = null;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 10,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        AppConstants.gradientStart,
                        AppConstants.gradientEnd
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppConstants.accentColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? 'Edit Entry' : 'Add New Entry',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: activity,
                        decoration: const InputDecoration(
                          labelText: 'Activity Type',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppConstants.accentColor),
                          ),
                        ),
                        dropdownColor: AppConstants.primaryColor,
                        items: AppConstants.activityTypes
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => activity = value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: stage,
                        decoration: const InputDecoration(
                          labelText: 'Crop Stage',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppConstants.accentColor),
                          ),
                        ),
                        dropdownColor: AppConstants.primaryColor,
                        items: AppConstants.cropStages
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => stage = value!),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppConstants.accentColor),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                      ),
                      ListTile(
                        title: const Text('Reminder Time',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _reminderTime != null
                              ? _reminderTime!.format(context)
                              : 'No reminder set',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.alarm,
                            color: AppConstants.accentColor),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => _reminderTime = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.accentColor,
                              foregroundColor: AppConstants.primaryColor,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              final notes = notesController.text.trim();
                              if (notes.isEmpty) {
                                _showErrorDialog('Validation Error',
                                    'Please enter notes for the entry.');
                                return;
                              }
                              try {
                                if (isEdit) {
                                  await FirebaseFirestore.instance
                                      .collection('crop_diary')
                                      .doc(widget.userId)
                                      .collection('logs')
                                      .doc(entry!.id)
                                      .update({
                                    'activity_type': activity,
                                    'crop_stage': stage,
                                    'notes': notes,
                                  });
                                  _showNotification('Entry Updated',
                                      'Your crop diary entry has been updated.');
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('crop_diary')
                                      .doc(widget.userId)
                                      .collection('logs')
                                      .add({
                                    'activity_type': activity,
                                    'crop_stage': stage,
                                    'notes': notes,
                                    'date': Timestamp.now(),
                                  });
                                  _showNotification('Entry Added',
                                      'A new crop diary entry has been added.');
                                }
                                _scheduleReminder(activity, DateTime.now());
                                Navigator.pop(context);
                                _loadInitialEntries();
                              } catch (e) {
                                _showErrorDialog('Saving Error',
                                    'Failed to save entry. Please check your connection.');
                              }
                            },
                            child: Text(
                              isEdit ? 'Save' : 'Add',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Builds filter chips for activity types.
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppConstants.activityTypes.map((activity) {
          final isSelected = _selectedActivities.contains(activity);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(activity),
              selected: isSelected,
              selectedColor: AppConstants.accentColor,
              checkmarkColor: AppConstants.primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppConstants.primaryColor
                    : AppConstants.primaryColor.withOpacity(0.7),
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedActivities.add(activity);
                  } else {
                    _selectedActivities.remove(activity);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the settings section for region and sowing date.
  Widget _buildSettingsSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _showSettings
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crop Settings',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    decoration: InputDecoration(
                      labelText: 'Select Region',
                      labelStyle:
                          const TextStyle(color: AppConstants.primaryColor),
                      filled: true,
                      fillColor: AppConstants.accentColor.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppConstants.accentColor.withOpacity(0.5)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: AppConstants.regions
                        .map((region) => DropdownMenuItem(
                              value: region,
                              child: Text(region,
                                  style: const TextStyle(
                                      color: AppConstants.primaryColor)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                        _savePreferences();
                        _showNotification('Region Updated',
                            'Your region has been set to $value.');
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      'Sowing Date: ${_sowingDate != null ? DateFormat('yyyy-MM-dd').format(_sowingDate!) : 'Not set'}',
                      style: const TextStyle(color: AppConstants.primaryColor),
                    ),
                    trailing: const Icon(Icons.calendar_today,
                        color: AppConstants.accentColor),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _sowingDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppConstants.primaryColor,
                                onPrimary: Colors.white,
                                surface: AppConstants.accentColor,
                                onSurface: AppConstants.primaryColor,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _sowingDate = picked;
                          _savePreferences();
                          _showNotification('Sowing Date Updated',
                              'Sowing date set to ${DateFormat('yyyy-MM-dd').format(picked)}.');
                        });
                      }
                    },
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// Builds the kebab menu with actions.
  Widget _buildKebabMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppConstants.primaryColor),
          onSelected: (value) {
            setState(() {
              if (value == 'settings') {
                _showSettings = !_showSettings;
              } else if (value == 'guidance') {
                _showGuidance = !_showGuidance;
              } else if (value == 'refresh') {
                _loadInitialEntries();
              }
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(
                    _showSettings ? Icons.settings : Icons.settings_outlined,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showSettings ? 'Hide Settings' : 'Show Settings',
                    style: const TextStyle(color: AppConstants.primaryColor),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'guidance',
              child: Row(
                children: [
                  Icon(
                    _showGuidance ? Icons.info : Icons.info_outline,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showGuidance ? 'Hide Wheat Guide' : 'Show Wheat Guide',
                    style: const TextStyle(color: AppConstants.primaryColor),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: const [
                  Icon(Icons.refresh, color: AppConstants.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Refresh',
                    style: TextStyle(color: AppConstants.primaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the dynamic wheat management guidance based on region and sowing date.
  Widget _buildDynamicGuidance() {
    if (_selectedRegion == null || _sowingDate == null) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _showGuidance ? 100 : 0,
        child: _showGuidance
            ? const Center(
                child: Text(
                  'Please select region and sowing date in settings.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : const SizedBox.shrink(),
      );
    }

    // Check for Tillering stage on screen visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNotifyTillering(fromScreenVisit: true);
    });

    final now = DateTime.now();
    final daysSinceSowing = now.difference(_sowingDate!).inDays;
    final currentStage = AppConstants.growthStages.firstWhere(
      (stage) {
        final start = stage['daysAfterSowing'] as int;
        final duration = stage['duration'] as int;
        return daysSinceSowing >= start && daysSinceSowing < start + duration;
      },
      orElse: () => AppConstants.growthStages.last,
    );

    final upcomingStages = AppConstants.growthStages.where((stage) {
      final start = stage['daysAfterSowing'] as int;
      return start > daysSinceSowing;
    }).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showGuidance ? 400 : 0,
      child: _showGuidance
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Wheat Management Guide ($_selectedRegion)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 6,
                    color: Colors.white.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppConstants.accentColor,
                        width: 2,
                      ),
                    ),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.cardGradientStart.withOpacity(0.3),
                            AppConstants.cardGradientEnd.withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  currentStage['stage'] == 'Germination'
                                      ? Icons.grass
                                      : currentStage['stage'] == 'Tillering'
                                          ? Icons.water_drop
                                          : currentStage['stage'] ==
                                                  'Stem Elongation'
                                              ? Icons.spa
                                              : currentStage['stage'] ==
                                                      'Flowering/Anthesis'
                                                  ? Icons.local_florist
                                                  : currentStage['stage'] ==
                                                          'Grain Filling'
                                                      ? Icons.grain
                                                      : currentStage['stage'] ==
                                                              'Milky/Dough Stage'
                                                          ? Icons.water
                                                          : Icons.agriculture,
                                  color: AppConstants.accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Current Stage: ${currentStage['stage']} (~${currentStage['daysAfterSowing']}–${(currentStage['daysAfterSowing'] as int) + (currentStage['duration'] as int)} DAS)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'General: ${(currentStage['tasks'] as Map<String, String>?)?['general'] ?? 'No general guidance available.'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Region-Specific: ${(currentStage['tasks'] as Map<String, String>?)?[_selectedRegion] ?? 'No region-specific guidance available.'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: TextButton.icon(
                                icon: const Icon(Icons.add,
                                    size: 16, color: AppConstants.accentColor),
                                label: const Text(
                                  'Add to Diary',
                                  style: TextStyle(
                                      color: AppConstants.accentColor),
                                ),
                                onPressed: () {
                                  _showEntryDialog(
                                    context: context,
                                    defaultActivity: currentStage['stage'] ==
                                            'Germination'
                                        ? 'Sowing'
                                        : currentStage['stage'] == 'Tillering'
                                            ? 'Irrigation'
                                            : currentStage['stage'] ==
                                                    'Stem Elongation'
                                                ? 'Fertilizer'
                                                : currentStage['stage'] ==
                                                        'Flowering/Anthesis'
                                                    ? 'Fertilizer'
                                                    : currentStage['stage'] ==
                                                            'Grain Filling'
                                                        ? 'Spray'
                                                        : currentStage[
                                                                    'stage'] ==
                                                                'Milky/Dough Stage'
                                                            ? 'Irrigation'
                                                            : 'Harvest',
                                    defaultNotes:
                                        '${(currentStage['tasks'] as Map<String, String>?)?['general'] ?? ''}\n${(currentStage['tasks'] as Map<String, String>?)?[_selectedRegion] ?? ''}',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ...upcomingStages.map((stage) {
                    final taskDate = _sowingDate!
                        .add(Duration(days: stage['daysAfterSowing'] as int));
                    return Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.95),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppConstants.primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              AppConstants.cardGradientStart.withOpacity(0.2),
                              AppConstants.cardGradientEnd.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    stage['stage'] == 'Germination'
                                        ? Icons.grass
                                        : stage['stage'] == 'Tillering'
                                            ? Icons.water_drop
                                            : stage['stage'] ==
                                                    'Stem Elongation'
                                                ? Icons.spa
                                                : stage['stage'] ==
                                                        'Flowering/Anthesis'
                                                    ? Icons.local_florist
                                                    : stage['stage'] ==
                                                            'Grain Filling'
                                                        ? Icons.grain
                                                        : stage['stage'] ==
                                                                'Milky/Dough Stage'
                                                            ? Icons.water
                                                            : Icons.agriculture,
                                    color: AppConstants.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${stage['stage']} (~${DateFormat('MMM dd').format(taskDate)})',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'General: ${(stage['tasks'] as Map<String, String>?)?['general'] ?? 'No general guidance available.'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Region-Specific: ${(stage['tasks'] as Map<String, String>?)?[_selectedRegion] ?? 'No region-specific guidance available.'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.add,
                                      size: 16,
                                      color: AppConstants.accentColor),
                                  label: const Text(
                                    'Set Reminder',
                                    style: TextStyle(
                                        color: AppConstants.accentColor),
                                  ),
                                  onPressed: () async {
                                    final picked = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => _reminderTime = picked);
                                      _scheduleReminder(
                                        stage['stage'] as String,
                                        taskDate,
                                      );
                                      _showNotification('Reminder Set',
                                          'Reminder for ${stage['stage']} on ${DateFormat('MMM dd').format(taskDate)}.');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Crop Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: daysSinceSowing /
                              200.0, // Assume 200 days total cycle
                          backgroundColor:
                              AppConstants.primaryColor.withOpacity(0.2),
                          color: AppConstants.accentColor,
                          minHeight: 8,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(daysSinceSowing / 200.0 * 100).toStringAsFixed(1)}% Complete',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// Builds a single diary entry card.
  Widget _buildEntryCard(DocumentSnapshot entry) {
    final date = (entry['date'] as Timestamp).toDate();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final activity = entry['activity_type'] as String;
    final stage = entry['crop_stage'] as String;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..scale(1.0)
            ..rotateZ(
                isToday ? 0.02 : 0.0), // Slight rotation for today entries
          child: Card(
            elevation: 8,
            color: Colors.white.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: AppConstants.accentColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.cardGradientStart.withOpacity(0.2),
                        AppConstants.cardGradientEnd.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppConstants.activityColors[activity] ??
                                    Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                activity,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (entry['notes'] != null &&
                            entry['notes'].toString().isNotEmpty)
                          Text(
                            'Notes: ${entry['notes']}',
                            style: const TextStyle(
                                fontSize: 14, color: AppConstants.primaryColor),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Crop Stage: $stage',
                          style: const TextStyle(
                              fontSize: 14, color: AppConstants.primaryColor),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                          child: LinearProgressIndicator(
                            value: AppConstants.stageProgress[stage] ?? 0.0,
                            backgroundColor:
                                AppConstants.primaryColor.withOpacity(0.2),
                            color: isToday
                                ? AppConstants.accentColor.withOpacity(0.8)
                                : AppConstants.accentColor,
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isToday)
                  Positioned(
                    top: 8,
                    right: 50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppConstants.accentColor,
                            AppConstants.cardGradientEnd
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppConstants.primaryColor),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEntryDialog(
                            context: context, entry: entry, isEdit: true);
                      } else if (value == 'delete') {
                        _deleteEntry(entry.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit,
                                size: 20, color: AppConstants.primaryColor),
                            SizedBox(width: 8),
                            Text('Edit',
                                style: TextStyle(
                                    color: AppConstants.primaryColor)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete,
                                size: 20, color: AppConstants.primaryColor),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(
                                    color: AppConstants.primaryColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _diaryEntries.where((entry) {
      final activity = entry['activity_type'] as String;
      return _selectedActivities.isEmpty ||
          _selectedActivities.contains(activity);
    }).toList();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Color(0xFFE5D188), // Light yellow background
          child: Stack(
            children: [
              Column(
                children: [
                  // Top Section with Background Image
                  Container(
                    height: screenHeight * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/Sidebar_Top.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(height: 20), // Spacing

                  // Sidebar Buttons
                  buildSidebarButton(
                    customIconPath: "assets/icons/Home_icon.png",
                    text: 'Home'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreHomeScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/profile_icon.png",
                    text: 'Profile'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/history_icon.png",
                    text: 'History'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreviousResultsScreen()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/help_icon.png",
                    text: 'Help'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Onboarding1()),
                      );
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/feedback_icon.png",
                    text: 'Feedback'.tr(),
                    onTap: () {
                      // Handle Profile Navigation
                    },
                  ),
                  buildSidebarButton(
                    customIconPath: "assets/icons/info_icon.png",
                    text: 'About Us'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AboutUsScreen()),
                      );
                    },
                  ),
                  Column(
                    children: [
                      if (user != null)
                        buildSidebarButton(
                          customIconPath: "assets/icons/logout_icon.png",
                          text: 'Logout'.tr(),
                          onTap: () {
                            logout();
                          },
                        ),
                    ],
                  ),
                ],
              ),

              // Logo Positioned Below Top Section
              Positioned(
                top: screenHeight * 0.1, // Adjust for desired position
                left: 0,
                right: 140,
                child: Center(
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 140, // Adjust size as needed
                    width: 140, // Adjust size as needed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 80,
                  floating: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Crop Diary',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  backgroundColor: AppConstants.primaryColor,
                  leading: IconButton(
                    icon: Image.asset(
                      "assets/icons/Back_arrow.png",
                      height: 35,
                      width: 35,
                      color: Colors
                          .white, // Optional: tint with white to match theme
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        // Optional: Handle case where back navigation isn't possible
                        _showErrorDialog('Navigation Error',
                            'No previous screen to go back to.');
                      }
                    },
                    tooltip: 'Back',
                  ),
                ),
                SliverToBoxAdapter(child: _buildKebabMenu()),
                SliverToBoxAdapter(child: _buildSettingsSection()),
                SliverToBoxAdapter(child: _buildDynamicGuidance()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: _buildFilterChips(),
                  ),
                ),
                if (_isLoadingInitial)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(AppConstants.accentColor),
                      ),
                    ),
                  )
                else if (filteredEntries.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.grass,
                            size: 100,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppConstants.accentColor,
                                AppConstants.primaryColor
                              ],
                            ).createShader(bounds),
                            child: Text(
                              _selectedActivities.isEmpty
                                  ? 'No entries yet. Start your crop diary!'
                                  : 'No entries for selected activities.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == filteredEntries.length &&
                            _hasMore &&
                            _selectedActivities.isEmpty) {
                          _loadMoreEntries();
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                    AppConstants.accentColor),
                              ),
                            ),
                          );
                        }
                        return _buildEntryCard(filteredEntries[index]);
                      },
                      childCount: filteredEntries.length +
                          (_hasMore && _selectedActivities.isEmpty ? 1 : 0),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/Bottom.png",
              fit: BoxFit.cover,
              height: screenHeight * 0.2,
              width: screenWidth,
            ),
          ),
          Positioned(
            top: 25,
            right: 5,
            child: Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Image.asset(
                  "assets/icons/menu.png",
                  height: 62,
                  width: 62,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            _fabAnimationController
                .forward()
                .then((_) => _fabAnimationController.reverse());
            _showEntryDialog(context: context);
          },
          backgroundColor: AppConstants.accentColor,
          elevation: 6,
          child: const Icon(Icons.grass, color: AppConstants.primaryColor),
          tooltip: 'Add Entry',
        ),
      ),
    );
  }

  /// Custom Sidebar Button
  Widget buildSidebarButton({
    IconData? icon,
    String? customIconPath,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 6, horizontal: 15), // Button Spacing
      child: GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: Offset(-10, 0), // Move button slightly left
          child: Container(
            height: 64,
            width: 250,
            decoration: BoxDecoration(
              color: Color(0xFF7B5228), // Brown background for button
              borderRadius: BorderRadius.circular(30), // Rounded button shape
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              children: [
                // Circular icon background
                Transform.translate(
                  offset: Offset(-8, 0), // Moves the icon slightly left
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE5D188), // Light background for icon
                      shape: BoxShape.circle,
                    ),
                    padding:
                        EdgeInsets.all(10), // Adjust for proper icon placement
                    child: customIconPath != null
                        ? Image.asset(
                            customIconPath,
                            height: 26,
                            width: 26,
                          )
                        : Icon(icon, color: Colors.black, size: 24),
                  ),
                ),
                SizedBox(width: 10), // Space between icon and text

                // Profile text
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
