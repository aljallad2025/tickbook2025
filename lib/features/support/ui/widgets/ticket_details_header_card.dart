import 'package:evento_app/features/support/data/models/support_ticket_details_models.dart';
import 'package:evento_app/features/support/ui/widgets/attachment_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketDetailsHeaderCard extends StatelessWidget {
  final SupportTicketDetails details;
  const TicketDetailsHeaderCard({super.key, required this.details});

  Color _statusColor(int s) {
    switch (s) {
      case 1: // Pending
        return Colors.orange;
      case 2: // Open
        return Colors.blue;
      case 3: // Closed
        return Colors.green;
      case 4: // Rejected
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(int s, {String locale = 'en'}) {
    switch (locale.toLowerCase()) {
      // 🇺🇸 English
      case 'en':
        switch (s) {
          case 1:
            return 'Pending';
          case 2:
            return 'Open';
          case 3:
            return 'Closed';
          case 4:
            return 'Rejected';
          default:
            return 'Unknown';
        }

      // 🇸🇦 Arabic
      case 'ar':
        switch (s) {
          case 1:
            return 'قيد الانتظار';
          case 2:
            return 'مفتوح';
          case 3:
            return 'مغلق';
          case 4:
            return 'مرفوض';
          default:
            return 'غير معروف';
        }

      // 🇮🇳 Hindi
      case 'hi':
        switch (s) {
          case 1:
            return 'लंबित';
          case 2:
            return 'खुला';
          case 3:
            return 'बंद';
          case 4:
            return 'अस्वीकृत';
          default:
            return 'अज्ञात';
        }

      // 🇩🇪 German
      case 'de':
        switch (s) {
          case 1:
            return 'Ausstehend';
          case 2:
            return 'Offen';
          case 3:
            return 'Geschlossen';
          case 4:
            return 'Abgelehnt';
          default:
            return 'Unbekannt';
        }

      // 🇫🇷 French
      case 'fr':
        switch (s) {
          case 1:
            return 'En attente';
          case 2:
            return 'Ouvert';
          case 3:
            return 'Fermé';
          case 4:
            return 'Rejeté';
          default:
            return 'Inconnu';
        }

      // 🇪🇸 Spanish
      case 'es':
        switch (s) {
          case 1:
            return 'Pendiente';
          case 2:
            return 'Abierto';
          case 3:
            return 'Cerrado';
          case 4:
            return 'Rechazado';
          default:
            return 'Desconocido';
        }

      // 🌐 Default fallback to English
      default:
        switch (s) {
          case 1:
            return 'Pending';
          case 2:
            return 'Open';
          case 3:
            return 'Closed';
          case 4:
            return 'Rejected';
          default:
            return 'Unknown';
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'Ticket ID'.tr} #${details.ticketNumber ?? details.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(details.status).withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusText(details.status).tr,
                    style: TextStyle(
                      color: _statusColor(details.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${'Subject'.tr}: ${details.subject}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: '${'Message'.tr}:  ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  TextSpan(
                    text: details.description,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if ((details.attachment ?? '').isNotEmpty ||
                details.attachment != null)
              Align(
                alignment: Alignment.centerLeft,
                child: AttachmentButton(url: details.attachment!),
              ),
          ],
        ),
      ),
    );
  }
}
