import 'package:intl/intl.dart';

class AppConstants {
  // Light Theme Colors
  static const backgroundColor = 0xFFF8F8FF;
  static const surfaceColor = 0xFFFAFAFC;
  static const primaryColor = 0xFF7C3AED;
  static const secondaryColor = 0xFFA78BFA;
  static const successColor = 0xFF10B981;
  static const errorColor = 0xFFEF4444;
  static const warningColor = 0xFFF59E0B;
  static const textPrimaryColor = 0xFF1F2937;
  static const textSecondaryColor = 0xFF6B7280;
  static const borderColor = 0xFFE5E7EB;

  // Payment Methods
  static const paymentMethods = ['Dinheiro', 'Débito', 'Crédito', 'Pix'];

  // Date Format
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ').format(value);
  }
}
