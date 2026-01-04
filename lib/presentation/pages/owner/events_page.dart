import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_card.dart';
import '../../stores/event_store.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  final EventStore _eventStore = EventStore();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this page
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventStore.events;

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
        ),
        body: events.isEmpty
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
                      'لا توجد فعاليات بعد',
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
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return EventCard(event: event);
                },
              ),
      ),
    );
  }

}

