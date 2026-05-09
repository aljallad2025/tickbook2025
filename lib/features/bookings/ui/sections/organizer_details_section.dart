import 'package:evento_app/features/bookings/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';

import '../widgets/info_row.dart';

class OrganizerDetailsSection extends StatelessWidget {
  final bool hasOrganizer;
  final bool hasAdmin;
  final String organizerUsername;
  final String organizerName;
  final String organizerEmail;
  final String organizerPhone;
  final String organizerCity;
  final String organizerState;
  final String organizerCountry;
  final String organizerAddress;
  final String adminUsername;
  final String adminFullName;
  final String adminEmail;
  final String adminPhone;
  final String adminAddress;

  const OrganizerDetailsSection({
    super.key,
    required this.hasOrganizer,
    required this.hasAdmin,
    required this.organizerUsername,
    required this.organizerName,
    required this.organizerEmail,
    required this.organizerPhone,
    required this.organizerCity,
    required this.organizerState,
    required this.organizerCountry,
    required this.organizerAddress,
    required this.adminUsername,
    required this.adminFullName,
    required this.adminEmail,
    required this.adminPhone,
    required this.adminAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Organizer Details',
      children: [
        if (hasOrganizer) ...[
          if (organizerUsername.isNotEmpty)
            infoRow('Username', organizerUsername),
          if (organizerName.isNotEmpty) infoRow('Name', organizerName),
          if (organizerEmail.isNotEmpty) infoRow('Email', organizerEmail),
          if (organizerPhone.isNotEmpty) infoRow('Phone', organizerPhone),
          if (organizerCity.isNotEmpty) infoRow('City', organizerCity),
          if (organizerState.isNotEmpty) infoRow('State', organizerState),
          if (organizerCountry.isNotEmpty) infoRow('Country', organizerCountry),
          if (organizerAddress != '-') infoRow('Address', organizerAddress),
        ] else if (hasAdmin) ...[
          if (adminUsername.isNotEmpty) infoRow('Email', adminUsername),
          if (adminFullName != '-') infoRow('Name', adminFullName),
          if (adminEmail.isNotEmpty) infoRow('Email', adminEmail),
          if (adminPhone.isNotEmpty) infoRow('Phone', adminPhone),
          if (adminAddress.isNotEmpty) infoRow('Address', adminAddress),
        ],
      ],
    );
  }
}