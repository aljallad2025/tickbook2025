import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/common/ui/widgets/contact_now_alert_dialog_widget.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/organizers/data/models/organizer_model.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizerDetailsCard extends StatelessWidget {
  final OrganizersModel org;
  const OrganizerDetailsCard({super.key, required this.org});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SafeNetworkImage(
                org.image ?? '',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                placeholder: const ShimmerBox(
                  height: 80,
                  width: 80,
                  borderRadius: 8,
                ),
                errorWidget: Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(org.name ?? '', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpandableText(
                org.details ?? '',
                expandText: 'View More'.tr,
                collapseText: 'View Less'.tr,
                maxLines: 4,
                linkColor: Colors.blue,
                linkStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 24),
            infoRow('Email', org.email ?? 'example@organizer.com'),
            const SizedBox(height: 8),
            infoRow('Phone', org.phone ?? '0000000000'),
            const SizedBox(height: 8),
            infoRow('City', org.city ?? 'City not available'),
            const SizedBox(height: 8),
            infoRow('State', org.state ?? 'Not available'),
            const SizedBox(height: 8),
            infoRow('Address', org.address ?? 'Not available'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      ContactNowAlertDialogWidget(organizerID: org.id),
                );
              },
              child: Text('Contact Now'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

Widget infoRow(String key, String value, {Color? vColor}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          key.tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(color: vColor ?? Colors.black87),
        ),
      ),
    ],
  );
}
