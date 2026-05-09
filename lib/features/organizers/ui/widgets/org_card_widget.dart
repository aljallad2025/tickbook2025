import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:evento_app/features/common/ui/widgets/shimmer_widgets.dart';
import 'package:evento_app/features/organizers/data/models/organizer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrgCardWidget extends StatelessWidget {
  final OrganizersModel organizers;
  const OrgCardWidget({super.key, required this.organizers});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Get.toNamed(
          AppRoutes.organizerDetails,
          arguments: {'id': organizers.id, 'isAdmin': false},
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SafeNetworkImage(
                  organizers.image ?? '',
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  placeholder: const ShimmerBox(
                    height: 100,
                    width: 100,
                    borderRadius: 12,
                  ),
                  errorWidget: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                organizers.name ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                organizers.username ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "${organizers.totalEvents.toString()} ${'Events'.tr}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.organizerDetails,
                      arguments: {'id': organizers.id, 'isAdmin': false},
                    );
                  },
                  child: Text('View Profile'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
