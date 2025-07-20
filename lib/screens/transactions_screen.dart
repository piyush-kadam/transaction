import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/add_transaction_modal.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  late Future<void> _fetchFuture;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _fetchFuture =
        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).fetchTransactions();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get unique categories from transactions
    final allCategories =
        txProvider.transactions
            .map((tx) => tx.category)
            .where((category) => category != null && category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    // Filter transactions based on selected category
    final filteredTransactions =
        _selectedCategory == null
            ? txProvider.transactions
            : txProvider.transactions
                .where((tx) => tx.category == _selectedCategory)
                .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Transactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (allCategories.isNotEmpty)
              PopupMenuButton<String?>(
                icon: Icon(
                  Icons.filter_list,
                  color:
                      _selectedCategory != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.7),
                ),
                onSelected: (String? category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(
                            Icons.clear,
                            size: 20,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          const Text('All Categories'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    ...allCategories.map(
                      (category) => PopupMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 20,
                              color: colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Filter Chips (if category is selected)
          if (_selectedCategory != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                children: [
                  Chip(
                    label: Text(_selectedCategory!),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                    backgroundColor: colorScheme.primary,
                    labelStyle: TextStyle(color: colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

          // Summary Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCategory != null
                            ? 'Filtered Transactions'
                            : 'Total Transactions',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${filteredTransactions.length}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: FutureBuilder(
              future: _fetchFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading transactions...',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.error_outline,
                            color: colorScheme.onErrorContainer,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _fetchFuture = txProvider.fetchTransactions();
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (txProvider.transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            color: colorScheme.onSurface.withOpacity(0.4),
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first transaction',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.filter_list_off,
                            color: colorScheme.onSurface.withOpacity(0.4),
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No transactions match the selected category',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                          child: const Text('Clear Filter'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _fetchFuture = txProvider.fetchTransactions();
                    });
                    return _fetchFuture;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredTransactions.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (i * 50)),
                        curve: Curves.easeOutBack,
                        transform: Matrix4.translationValues(0, 0, 0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: colorScheme.outline.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: TransactionTile(filteredTransactions[i]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed:
              () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (_) => Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: const AddTransactionModal(),
                    ),
              ),
          icon: const Icon(Icons.add),
          label: const Text('Add Transaction'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
