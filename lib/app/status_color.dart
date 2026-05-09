import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    // ✅ Accepted / Approved
    case 'accepted':
    case 'Accepted':
    case 'ACCEPTED':
    case 'approved':
    case 'Approved':
    case 'APPROVED':
    case 'مقبول':
    case 'تم القبول':
    case 'स्वीकार किया गया':
    case 'स्वीकृत':
    case 'akzeptiert':
    case 'Akzeptiert':
    case 'accepté':
    case 'Accepté':
    case 'aceptado':
    case 'Aceptado':
      return Colors.green;

    // 🟠 Pending / Waiting
    case 'pending':
    case 'Pending':
    case 'PENDING':
    case 'waiting':
    case 'Waiting':
    case 'قيد الانتظار':
    case 'بانتظار الموافقة':
    case 'معلق':
    case 'लंबित':
    case 'प्रतीक्षा में':
    case 'ausstehend':
    case 'Ausstehend':
    case 'en attente':
    case 'En attente':
    case 'pendiente':
    case 'Pendiente':
      return Colors.orange;

    // 🟢 Completed / Done
    case 'completed':
    case 'Completed':
    case 'COMPLETED':
    case 'done':
    case 'Done':
    case 'تم الإنجاز':
    case 'مكتمل':
    case 'पूरा हुआ':
    case 'समाप्त':
    case 'abgeschlossen':
    case 'Abgeschlossen':
    case 'terminé':
    case 'Terminé':
    case 'completado':
    case 'Completado':
      return Colors.green;

    // 🔴 Cancelled / Canceled
    case 'cancelled':
    case 'Cancelled':
    case 'CANCELLED':
    case 'canceled':
    case 'Canceled':
    case 'ملغي':
    case 'تم الإلغاء':
    case 'ألغيت':
    case 'रद्द किया गया':
    case 'रद्द':
    case 'abgesagt':
    case 'Abgesagt':
    case 'annulé':
    case 'Annulé':
    case 'cancelado':
    case 'Cancelado':
      return Colors.red;

    // 🔴 Rejected / Declined
    case 'rejected':
    case 'Rejected':
    case 'REJECTED':
    case 'declined':
    case 'Declined':
    case 'مرفوض':
    case 'تم الرفض':
    case 'अस्वीकृत':
    case 'अस्वीकार किया गया':
    case 'abgelehnt':
    case 'Abgelehnt':
    case 'rejeté':
    case 'Rejeté':
    case 'rechazado':
    case 'Rechazado':
      return Colors.redAccent;

    // ⚪ Default
    default:
      return Colors.grey;
  }
}
