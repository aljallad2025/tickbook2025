import 'package:evento_app/features/bookings/ui/widgets/section_card.dart';
import 'package:flutter/material.dart';

import '../widgets/info_row.dart';

class BillingDetailsSection extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String address;
  final String zipCode;

  const BillingDetailsSection({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.address,
    required this.zipCode,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Billing Details',
      children: [
        if (name.trim().isNotEmpty) infoRow('Name', name.trim()),
        if (email.isNotEmpty) infoRow('Email', email),
        if (phone.isNotEmpty) infoRow('Phone', phone),
        if (country.isNotEmpty) infoRow('Country', country),
        if (city.isNotEmpty) infoRow('City', city),
        if (address != '-') infoRow('Address', address),
        if (zipCode.isNotEmpty) infoRow('Zip Code', zipCode),
      ],
    );
  }
}
