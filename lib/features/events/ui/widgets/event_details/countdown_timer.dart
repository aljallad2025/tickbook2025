import 'dart:async';

import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountdownTimer extends StatefulWidget {
  final EventDetailsModel event;
  final DateTime? targetOverride; // When running, target points to end
  final DateTime? startOverride;  // For multi-date occurrences
  final DateTime? endOverride;    // For multi-date occurrences
  const CountdownTimer({
    super.key,
    required this.event,
    this.targetOverride,
    this.startOverride,
    this.endOverride,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _ticker;
  Duration _remaining = Duration.zero;
  DateTime? _target;

  DateTime? _combine(DateTime? d, String? t) {
    if (d == null) return null;
    int hour = 0, minute = 0;
    if (t != null && t.trim().isNotEmpty) {
      var s = t.trim().toLowerCase();
      final am = s.contains('am');
      final pm = s.contains('pm');
      s = s.replaceAll('am', '').replaceAll('pm', '').trim();
      final parts = s.split(':');
      if (parts.isNotEmpty) {
        hour = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      if (parts.length > 1) {
        minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      if (pm && hour < 12) hour += 12;
      if (am && hour == 12) hour = 0;
    } else {
      hour = d.hour;
      minute = d.minute;
    }
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  @override
  void initState() {
    super.initState();
    _computeTarget();
    _start();
  }

  void _computeTarget() {
    // Multi-date override path
    final DateTime? start = widget.startOverride ??
        _combine(widget.event.startDate, widget.event.startTime);
    final DateTime? end = widget.endOverride ??
        widget.event.endDateTime ?? _combine(widget.event.endDate, widget.event.endTime);

    if (start == null) {
      _target = null;
      _updateRemaining();
      return;
    }

    // If widget.targetOverride provided, we assume event already started and counting down to end.
    if (widget.targetOverride != null) {
      _target = widget.targetOverride;
      _updateRemaining();
      return;
    }

    final now = DateTime.now();
    // Choose start if before start; else if during run and end exists choose end; else end/start whichever later.
    if (now.isBefore(start)) {
      _target = start;
    } else if (end != null && now.isBefore(end)) {
      _target = end; // running
    } else {
      // Event passed; target = end if exists else start (will display zeros)
      _target = end ?? start;
    }
    _updateRemaining();
  }

  void _start() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (!mounted) return;
    if (_target == null) return;
    final now = DateTime.now();
    final diff = _target!.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetOverride != widget.targetOverride ||
        oldWidget.startOverride != widget.startOverride ||
        oldWidget.endOverride != widget.endOverride ||
        oldWidget.event.startDate != widget.event.startDate ||
        oldWidget.event.startTime != widget.event.startTime ||
        oldWidget.event.endDate != widget.event.endDate ||
        oldWidget.event.endTime != widget.event.endTime ||
        oldWidget.event.endDateTime != widget.event.endDateTime) {
      _computeTarget();
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool noDates = _target == null;
    final days = noDates ? 0 : _remaining.inDays;
    final hours = noDates ? 0 : _remaining.inHours % 24;
    final minutes = noDates ? 0 : _remaining.inMinutes % 60;
    final seconds = noDates ? 0 : _remaining.inSeconds % 60;
    String fmt(int v) => v.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TimeCircleWidget(title: 'Days', time: fmt(days)),
        TimeCircleWidget(title: 'Hours', time: fmt(hours)),
        TimeCircleWidget(title: 'Minutes', time: fmt(minutes)),
        TimeCircleWidget(title: 'Seconds', time: fmt(seconds)),
      ],
    );
  }
}

class TimeCircleWidget extends StatelessWidget {
  final String time;
  final String title;
  const TimeCircleWidget({super.key, required this.time, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
          child: Container(
            alignment: Alignment.center,
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(99),
              color: Colors.white,
            ),
            child: Text(
              time,
              style: AppTextStyles.headingMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title.tr,
          style: AppTextStyles.bodyLargeGrey.copyWith(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
