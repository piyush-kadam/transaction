import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  const TransactionTile(this.transaction, {super.key});

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Format currency in Indian number system
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: amount == amount.truncate() ? 0 : 2,
    );
    return formatter.format(amount);
  }

  // Get category icon based on category name
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'restaurant':
      case 'dining':
        return Icons.restaurant;
      case 'transport':
      case 'travel':
      case 'fuel':
        return Icons.directions_car;
      case 'shopping':
      case 'clothes':
        return Icons.shopping_bag;
      case 'entertainment':
      case 'movie':
        return Icons.movie;
      case 'health':
      case 'medical':
        return Icons.medical_services;
      case 'education':
      case 'books':
        return Icons.school;
      case 'bills':
      case 'utilities':
        return Icons.receipt_long;
      case 'salary':
      case 'income':
        return Icons.work;
      case 'investment':
      case 'stocks':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'groceries':
        return Icons.local_grocery_store;
      default:
        return widget.transaction.type == 'credit'
            ? Icons.add_circle
            : Icons.remove_circle;
    }
  }

  // Get time ago string
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCredit = widget.transaction.type == 'credit';

    // Define colors based on transaction type
    final primaryColor =
        isCredit
            ? const Color(0xFF4CAF50) // Green for credit
            : const Color(0xFFFF5722); // Red for debit

    final backgroundColor =
        isCredit
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : const Color(0xFFFF5722).withOpacity(0.1);

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        // Add haptic feedback
        HapticFeedback.lightImpact();
        // You can add navigation to detail screen here
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(widget.transaction.category),
                  color: primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Title
                    Text(
                      widget.transaction.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category only
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.transaction.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Date Only (without time)
                    Text(
                      DateFormat(
                        'MMM dd, yyyy',
                      ).format(widget.transaction.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Amount Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Amount with Sign
                  Text(
                    '${isCredit ? '+' : '-'}${_formatCurrency(widget.transaction.amount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Transaction Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      isCredit ? 'CREDIT' : 'DEBIT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
