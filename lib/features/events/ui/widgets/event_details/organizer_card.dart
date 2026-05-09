import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/app_text_styles.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/events/data/models/event_details_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizerCard extends StatelessWidget {
  const OrganizerCard({super.key, required this.details, required this.event});

  final EventDetailsPageModel details;
  final EventDetailsModel event;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: SafeNetworkImage(
                    details.organizer.image ?? details.admin.image,
                    fit: BoxFit.cover,
                    placeholder: const ShimmerBox(
                      width: 80,
                      height: 80,
                      borderRadius: 80,
                    ),
                    errorWidget: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.organizer.name ?? details.admin.firstName,

                    style: AppTextStyles.bodyLargeGrey.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    details.organizer.address ?? details.admin.address ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLargeGrey.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.organizerDetails,
                        arguments: {
                          'id': event.organizerId,
                          'isAdmin': event.organizerId == null ? true : false,
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text('View Profile'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
