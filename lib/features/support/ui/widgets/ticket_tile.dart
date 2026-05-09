import 'package:evento_app/network_services/core/navigation_service.dart';
import 'package:evento_app/features/support/data/models/support_ticket_models.dart';
import 'package:evento_app/features/support/ui/screens/ticket_details.dart';
import 'package:flutter/material.dart';
import 'package:evento_app/features/support/ui/widgets/attachment_button.dart';
import 'package:get/get.dart';

class TicketTile extends StatelessWidget {
  final SupportTicket ticket;
  const TicketTile({super.key, required this.ticket});

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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        NavigationService.pushAnimated(TicketDetails(ticketId: ticket.id));
      },
      child: Card(
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
                    child: Row(
                      children: [
                        Icon(Icons.support_agent_rounded, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${'Ticket ID'.tr}: ${ticket.id.toString()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(ticket.status).withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusText(ticket.status).tr,
                      style: TextStyle(
                        color: _statusColor(ticket.status),
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
                  Icon(Icons.subject_rounded, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 8,
                    child: RichText(
                      text: TextSpan(
                        text: ticket.subject,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  if ((ticket.attachment ?? '').isNotEmpty)
                    AttachmentButton(url: ticket.attachment!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
