import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:evento_app/features/common/ui/widgets/safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loggedIn = auth.token != null;
    final customer = auth.customer;
    final name = loggedIn
        ? '${(customer?['fname'] ?? '').trim()} ${(customer?['lname'] ?? '').trim()}'
              .trim()
        : 'Guest';

    final subtitle = loggedIn
        ? (customer?['email']?.toString() ?? '')
        : 'Not logged in';
    final rawPhoto = loggedIn ? (customer?['photo']?.toString() ?? '') : '';
    final photo = rawPhoto.trim();
    final isDefaultServerPlaceholder = photo.contains(
      '/assets/front/images/user.png',
    );
    final useNetworkPhoto =
        photo.isNotEmpty &&
        photo.startsWith('http') &&
        !isDefaultServerPlaceholder;

    return Card(
      elevation: 0.5,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),

                child: useNetworkPhoto
                    ? SafeNetworkImage(
                        photo,
                        height: 48,
                        width: 48,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          height: 48,
                          width: 48,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : Icon(Icons.person),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Customer'.tr : name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Get.toNamed(AppRoutes.updateProfile),
              child: Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  AssetsPath.userEdit,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
