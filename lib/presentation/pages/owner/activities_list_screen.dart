import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../models/activity_item.dart';
import '../../stores/activities_store.dart';
import 'event_details_page.dart';
import 'live_match_details_screen.dart';
import 'add_event_screen.dart';
import 'add_live_match_screen.dart';
import '../../widgets/activity_card.dart';
import '../../stores/event_store.dart';

class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  final ActivitiesStore _store = ActivitiesStore();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = _store.sortedItems;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'الفعاليات',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.add,
                color: Color(0xFF4BCB78),
              ),
              onSelected: (value) {
                if (value == 'event') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEventScreen(),
                    ),
                  );
                } else if (value == 'liveMatch') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddLiveMatchScreen(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'event',
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFF4BCB78)),
                      const SizedBox(width: 8),
                      Text(
                        'إضافة فعالية',
                        style: _cairoFont,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'liveMatch',
                  child: Row(
                    children: [
                      const Icon(Icons.sports_soccer, color: Color(0xFF4BCB78)),
                      const SizedBox(width: 8),
                      Text(
                        'إضافة مباراة مباشرة',
                        style: _cairoFont,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: activities.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'لا توجد فعاليات أو مباريات بعد',
                      style: AppTextStyles.h3.copyWith(
                        fontFamily: _cairoFont.fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ActivityCard(
                    activity: activity,
                    cairoFont: _cairoFont,
                    onTap: () {
                      if (activity.type == ActivityType.event) {
                        // Navigate to event details - get Event from EventStore
                        final eventStore = EventStore();
                        final event = eventStore.getEventById(activity.eventId ?? activity.id);
                        if (event != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailsPage(event: event),
                            ),
                          );
                        }
                      } else {
                        // Navigate to live match details
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LiveMatchDetailsScreen(
                              activityId: activity.liveMatchId ?? activity.id,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

