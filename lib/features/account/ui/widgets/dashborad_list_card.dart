
import 'package:evento_app/features/account/ui/widgets/account_item_widget.dart';
import 'package:flutter/material.dart';

class DashboardListCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(BuildContext context, String title) onItemTap;

  const DashboardListCard({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            Divider(thickness: 1.5, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final item = items[index];
          return AccountItemWidget(
            title: item['title'] as String,
            svgIcon: item['icon'] as IconData,
            onTap: () => onItemTap(context, item['title'] as String),
          );
        },
      ),
    );
  }
}
