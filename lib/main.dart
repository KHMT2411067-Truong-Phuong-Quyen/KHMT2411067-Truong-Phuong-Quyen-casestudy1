import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const ExpenseManagerApp());
}

const Color primaryBlue = Color(0xFF246BFD);
const Color backgroundColor = Color(0xFFF5F7FB);

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 110,
                  color: primaryBlue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Expense Manager',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Quản lý chi tiêu cá nhân\n'
                      'đơn giản và hiệu quả',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Bắt đầu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================
// THANH ĐIỀU HƯỚNG CHÍNH
// ==================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  void refreshScreen() {
    setState(() {});
  }

  Future<void> openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );

    refreshScreen();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onAdd: openAddTransaction),
      const TransactionListScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        onPressed: openAddTransaction,
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

// ==================================================
// HÀM HỖ TRỢ
// ==================================================

bool isIncome(Map<String, dynamic> transaction) {
  return transaction['type'] == 'Thu nhập';
}

double getAmount(Map<String, dynamic> transaction) {
  return (transaction['amount'] as num).toDouble();
}

String money(double amount) {
  final value = amount.round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    buffer.write(value[i]);

    final remaining = value.length - i - 1;

    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }

  return '${buffer.toString()} đ';
}

IconData categoryIcon(String category) {
  switch (category) { case 'Ăn uống':
    return Icons.restaurant;
    case 'Mua sắm':
      return Icons.shopping_cart;
    case 'Lương':
      return Icons.work;
    case 'Đi lại':
      return Icons.directions_car;
    case 'Học tập':
      return Icons.menu_book;
    case 'Giải trí':
      return Icons.movie;
    default:
      return Icons.category;
  }
}

Color categoryColor(String category) {
  switch (category) {
    case 'Ăn uống':
      return Colors.red;
    case 'Mua sắm':
      return Colors.lightBlue;
    case 'Lương':
      return Colors.green;
    case 'Đi lại':
      return Colors.purple;
    case 'Học tập':
      return Colors.indigo;
    default:
      return Colors.orange;
  }
}

String displayDate(String? date) {
  if (date == null || date.isEmpty) {
    return '';
  }

  try {
    final parsed = DateTime.parse(date);

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  } catch (_) {
    return date;
  }
}

// ==================================================
// MÀN HÌNH DASHBOARD
// ==================================================

class DashboardScreen extends StatefulWidget {
  final VoidCallback onAdd;

  const DashboardScreen({
    super.key,
    required this.onAdd,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
List<Map<String, dynamic>> transactions = [];
bool loading = true;

@override
void initState() {
super.initState();
loadTransactions();
}

Future<void> loadTransactions() async {
final data =
await DatabaseHelper.instance.getTransactions();

if (!mounted) return;

setState(() {
transactions = data;
loading = false;
});
}

@override
Widget build(BuildContext context) {
final income = transactions
.where(isIncome)
.fold<double>(
0,
(sum, item) => sum + getAmount(item),
);

final expense = transactions
.where((item) => !isIncome(item))
.fold<double>(
0,
(sum, item) => sum + getAmount(item),
);

return Scaffold(
appBar: AppBar(
title: const Text(
'Expense Manager',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
actions: [
IconButton(
onPressed: loadTransactions,
icon: const Icon(Icons.refresh),
),
],
),
body: loading
? const Center(
child: CircularProgressIndicator(),
)
: RefreshIndicator(
onRefresh: loadTransactions,
child: ListView(
padding: const EdgeInsets.all(16),
children: [
Container(
padding: const EdgeInsets.all(22),decoration: BoxDecoration(
  color: primaryBlue,
  borderRadius: BorderRadius.circular(20),
),
  child: Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
      const Text(
        'Số dư hiện tại',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        money(income - expense),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),
  const SizedBox(height: 16),
  Row(
    children: [
      Expanded(
        child: SummaryCard(
          title: 'Thu nhập',
          amount: income,
          color: Colors.green,
          icon: Icons.arrow_downward,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: SummaryCard(
          title: 'Chi tiêu',
          amount: expense,
          color: Colors.red,
          icon: Icons.arrow_upward,
        ),
      ),
    ],
  ),
  const SizedBox(height: 24),
  const Text(
    'Giao dịch gần đây',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 10),
  if (transactions.isEmpty)
    const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Chưa có giao dịch.\n'
            'Nhấn nút + để thêm giao dịch nhé!',
        textAlign: TextAlign.center,
      ),
    )
  else
    ...transactions.take(5).map(
          (item) => TransactionTile(
        transaction: item,
        onChanged: loadTransactions,
      ),
    ),
],
),
),
);
}
}

// ==================================================
// THẺ THU NHẬP VÀ CHI TIÊU
// ==================================================

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: color),
          ),
          const SizedBox(height: 6),
          Text(
            money(amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends State<TransactionListScreen> {
List<Map<String, dynamic>> transactions = [];
String keyword = '';
String typeFilter = 'Tất cả';

@override
void initState() {
super.initState();
loadTransactions();
}

Future<void> loadTransactions() async {
final data =
await DatabaseHelper.instance.getTransactions();

if (!mounted) return;

setState(() {
transactions = data;
});
}

Future<void> editTransaction(
Map<String, dynamic> item) async {
await Navigator.push(
context,
MaterialPageRoute(
builder: (_) => TransactionFormScreen(
transaction: item,
),
),
);

await loadTransactions();
}

@override
Widget build(BuildContext context) {
final filtered = transactions.where((item) {
final title =
(item['title'] ?? '').toString().toLowerCase();

final category =
(item['category'] ?? '').toString().toLowerCase();

final matchesKeyword =
title.contains(keyword.toLowerCase()) ||
category.contains(keyword.toLowerCase());

final matchesType =
typeFilter == 'Tất cả' ||
item['type'] == typeFilter;

return matchesKeyword && matchesType;
}).toList();

return Scaffold(
appBar: AppBar(
title: const Text('Giao dịch'),
),
body: Column(
children: [
Padding(
padding: const EdgeInsets.all(16),
child: TextField(
decoration: const InputDecoration(
hintText: 'Tìm kiếm giao dịch...',
prefixIcon: Icon(Icons.search),
border: OutlineInputBorder(),
),
onChanged: (value) {
setState(() {
keyword = value;
});
},
),
),
Wrap(
spacing: 8,
children: [
'Tất cả',
'Thu nhập',
'Chi tiêu',
].map((type) {
return ChoiceChip(
label: Text(type),
selected: typeFilter == type,
onSelected: (_) {
setState(() {
typeFilter = type;
});
},
);
}).toList(),
),
const SizedBox(height: 8),
Expanded(
child: filtered.isEmpty
? const Center(
child: Text('Chưa có giao dịch'),
)
: ListView.builder(
itemCount: filtered.length,
itemBuilder: (context, index) {final item = filtered[index];

return TransactionTile(
  transaction: item,
  onChanged: loadTransactions,
  onTap: () => editTransaction(item),
);
},
),
),
],
),
);
}
}

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onChanged;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category =
    (transaction['category'] ?? 'Khác').toString();

    final income = isIncome(transaction);
    final amount = getAmount(transaction);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
          categoryColor(category).withOpacity(0.12),
          child: Icon(
            categoryIcon(category),
            color: categoryColor(category),
          ),
        ),
        title: Text(
          transaction['title']?.toString().isNotEmpty == true
              ? transaction['title'].toString()
              : category,
        ),
        subtitle: Text(
          displayDate(transaction['date']?.toString()),
        ),
        trailing: Text(
          '${income ? '+' : '-'}${money(amount)}',
          style: TextStyle(
            color: income ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xóa giao dịch?'),
              content: const Text(
                'Bà có chắc muốn xóa giao dịch này không?',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text('Xóa'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await DatabaseHelper.instance.deleteTransaction(
              transaction['id'] as int,
            );

            onChanged();
          }
        },
      ),
    );
  }
}

class TransactionFormScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const TransactionFormScreen({
    super.key,
    this.transaction,
  });

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends State<TransactionFormScreen> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  String type = 'Chi tiêu';
  String category = 'Ăn uống';

  DateTime selectedDate = DateTime.now();
  bool saving = false;

  final expenseCategories = [
    'Ăn uống',
    'Mua sắm',
    'Đi lại',
    'Học tập',
    'Giải trí',
    'Khác',
  ];

  final incomeCategories = [
    'Lương',
    'Thưởng',
    'Khác',
  ];

  List<String> get availableCategories {
    return type == 'Thu nhập'
        ? incomeCategories
        : expenseCategories;
  }

  @override
  void initState() {
    super.initState();

    final item = widget.transaction;

    if (item != null) {
      titleController.text =
          (item['title'] ?? '').toString();

      amountController.text =
          getAmount(item).toStringAsFixed(0);

      noteController.text =
          (item['note'] ?? '').toString();

      type = (item['type'] ?? 'Chi tiêu').toString();

      final oldCategory =
      (item['category'] ?? '').toString();

      category = availableCategories.contains(oldCategory)
          ? oldCategory
          : availableCategories.first;

      try {
        selectedDate =
            DateTime.parse(item['date'].toString());
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveTransaction() async {
    if (!formKey.currentState!.validate() || saving) {
      return;
    }

    setState(() {
      saving = true;
    });

    final data = <String, dynamic>{
      'title': titleController.text.trim(),
      'amount': double.parse(amountController.text.trim()),
      'type': type,
      'category': category,
      'date': selectedDate
          .toIso8601String()
          .split('T')
          .first,
      'note': noteController.text.trim(),
    };

    try {
      if (widget.transaction == null) {
        await DatabaseHelper.instance.insertTransaction(data);
      } else {
        await DatabaseHelper.instance.updateTransaction(
          widget.transaction!['id'] as int,
          data,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu giao dịch thất bại: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Thêm giao dịch'
              : 'Sửa giao dịch',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Chi tiêu',
                  label: Text('Chi tiêu'),
                ),
                ButtonSegment(
                  value: 'Thu nhập',
                  label: Text('Thu nhập'),
                ),
              ],
              selected: {type},
              onSelectionChanged: (values) {
                setState(() {
                  type = values.first;

                  if (!availableCategories.contains(category)) {
                    category = availableCategories.first;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Tên giao dịch'),
            const SizedBox(height: 8),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Ăn trưa',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Vui lòng nhập tên giao dịch';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Danh mục'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: availableCategories.map((item) {
                return DropdownMenuItem(value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Số tiền (đ)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                hintText: 'Nhập số tiền',
                border: OutlineInputBorder(),
                suffixText: 'đ',
              ),
              validator: (value) {
                final amount =
                double.tryParse(value?.trim() ?? '');

                if (amount == null || amount <= 0) {
                  return 'Nhập số tiền lớn hơn 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text('Ngày giao dịch'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                displayDate(selectedDate.toIso8601String()),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Ghi chú'),
            const SizedBox(height: 8),
            TextFormField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú (tùy chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: saving ? null : saveTransaction,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  saving ? 'Đang lưu...' : 'Lưu',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
List<Map<String, dynamic>> transactions = [];
String selectedPeriod = 'Tháng này';
bool loading = true;

@override
void initState() {
super.initState();
loadTransactions();
}

Future<void> loadTransactions() async {
final data = await DatabaseHelper.instance.getTransactions();

if (!mounted) return;

setState(() {
transactions = data;
loading = false;
});
}

bool isInSelectedPeriod(Map<String, dynamic> item) {
final date = DateTime.tryParse(item['date']?.toString() ?? '');
if (date == null) return false;

final now = DateTime.now();

if (selectedPeriod == 'Tháng này') {
return date.year == now.year && date.month == now.month;
}

if (selectedPeriod == 'Tháng trước') {
final previousMonth = DateTime(now.year, now.month - 1);
return date.year == previousMonth.year &&
date.month == previousMonth.month;
}

return date.year == now.year;
}

double get totalIncome {
return transactions
.where((item) =>
isInSelectedPeriod(item) && item['type'] == 'Thu nhập')
.fold(0.0, (sum, item) => sum + getAmount(item));
}

double get totalExpense {
return transactions
.where((item) =>
isInSelectedPeriod(item) && item['type'] == 'Chi tiêu')
.fold(0.0, (sum, item) => sum + getAmount(item));
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Thống kê'),
actions: [
IconButton(
onPressed: loadTransactions,
icon: const Icon(Icons.refresh),
),
],
),
body: loading
? const Center(child: CircularProgressIndicator())
: ListView(
padding: const EdgeInsets.all(16),
children: [
DropdownButtonFormField<String>(
value: selectedPeriod,
decoration: const InputDecoration(
labelText: 'Khoảng thời gian',
border: OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value: 'Tháng này',
child: Text('Tháng này'),
),
DropdownMenuItem(
value: 'Tháng trước',
child: Text('Tháng trước'),
),
DropdownMenuItem(
value: 'Năm nay',
child: Text('Năm nay'),
),
],
onChanged: (value) {
if (value != null) {setState(() {
  selectedPeriod = value;
});
}
},
),
  const SizedBox(height: 20),
  SummaryCard(
    title: 'Tổng thu nhập',
    amount: totalIncome,
    icon: Icons.arrow_downward,
    color: Colors.green,
  ),
  const SizedBox(height: 12),
  SummaryCard(
    title: 'Tổng chi tiêu',
    amount: totalExpense,
    icon: Icons.arrow_upward,
    color: Colors.red,
  ),
  const SizedBox(height: 12),
  SummaryCard(
    title: 'Chênh lệch thu chi',
    amount: totalIncome - totalExpense,
    icon: Icons.account_balance_wallet,
    color: primaryBlue,
  ),
  const SizedBox(height: 24),
  const Text(
    'Chi tiêu theo danh mục',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),
  buildCategoryStatistics(),
],
),
);
}

Widget buildCategoryStatistics() {
  final expenses = transactions.where((item) =>
  isInSelectedPeriod(item) && item['type'] == 'Chi tiêu');

  final Map<String, double> categoryTotals = {};

  for (final item in expenses) {
    final category = item['category']?.toString() ?? 'Khác';
    categoryTotals[category] =
        (categoryTotals[category] ?? 0) + getAmount(item);
  }

  if (categoryTotals.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Text('Chưa có dữ liệu chi tiêu trong thời gian này.'),
      ),
    );
  }

  final sortedCategories = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Column(
    children: sortedCategories.map((entry) {
      final percentage =
      totalExpense == 0 ? 0.0 : entry.value / totalExpense;

      return Card(
        child: ListTile(
          leading: Icon(categoryIcon(entry.key)),
          title: Text(entry.key),
          subtitle: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            color: categoryColor(entry.key),
            minHeight: 6,
          ),
          trailing: Text(
            money(entry.value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList(),
  );
}
}

class CategoryChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;

  CategoryChartPainter(this.categoryTotals);

  @override
  void paint(Canvas canvas, Size size) {
    if (categoryTotals.isEmpty) return;

    final total = categoryTotals.values.fold<double>(
      0,
          (sum, value) => sum + value,
    );

    if (total <= 0) return;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.8,
    );

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    final paint = Paint()
      ..style = PaintingStyle.fill;

    double startAngle = -1.5708;
    int index = 0;

    for (final value in categoryTotals.values) {
      final sweepAngle = value / total * 6.28318;

      paint.color = colors[index % colors.length];

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant CategoryChartPainter oldDelegate) {
    return oldDelegate.categoryTotals != categoryTotals;
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: primaryBlue,
            child: Icon(
              Icons.person,
              size: 55,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Người dùng Expense Manager',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Quản lý thu nhập và chi tiêu cá nhân',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Thông tin cá nhân'),
            subtitle: const Text('Xem thông tin tài khoản'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang được phát triển'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Thông báo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang được phát triển'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Quyền riêng tư'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang được phát triển'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Giới thiệu ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Expense Manager',
                applicationVersion: '1.0.0',
                applicationLegalese:
                'Ứng dụng quản lý thu nhập và chi tiêu cá nhân.',
              );
            },
          ),
        ],
      ),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
String selectedType = 'Tất cả';
String selectedCategory = 'Tất cả';

final List<String> categories = [
'Tất cả',
'Ăn uống',
'Mua sắm',
'Đi lại',
'Học tập',
'Giải trí',
'Lương',
'Thưởng',
'Khác',
];

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Lọc giao dịch'),
),
body: ListView(
padding: const EdgeInsets.all(20),
children: [
const Text(
'Loại giao dịch',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
value: selectedType,
decoration: const InputDecoration(
border: OutlineInputBorder(),
),
items: const [
DropdownMenuItem(
value: 'Tất cả',
child: Text('Tất cả'),
),
DropdownMenuItem(
value: 'Thu nhập',
child: Text('Thu nhập'),
),
DropdownMenuItem(
value: 'Chi tiêu',
child: Text('Chi tiêu'),
),
],
onChanged: (value) {
if (value != null) {
setState(() {
selectedType = value;
});
}
},
),
const SizedBox(height: 24),
const Text(
'Danh mục',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
value: selectedCategory,
decoration: const InputDecoration(
border: OutlineInputBorder(),
),
items: categories.map((category) {
return DropdownMenuItem(
value: category,
child: Text(category),
);
}).toList(),
onChanged: (value) {
if (value != null) {
setState(() {
selectedCategory = value;
});
}
},
),
const SizedBox(height: 30),
SizedBox(
width: double.infinity,
child: FilledButton.icon(
icon: const Icon(Icons.filter_alt),
label: const Text('Áp dụng bộ lọc'),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (_) => FilterResultScreen(
  selectedType: selectedType,
  selectedCategory: selectedCategory,
),
),
);
},
),
),
],
),
);
}
}

class FilterResultScreen extends StatefulWidget {
  final String selectedType;
  final String selectedCategory;

  const FilterResultScreen({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
  });

  @override
  State<FilterResultScreen> createState() => _FilterResultScreenState();
}

class _FilterResultScreenState extends State<FilterResultScreen> {
List<Map<String, dynamic>> transactions = [];
bool loading = true;

@override
void initState() {
super.initState();
loadTransactions();
}

Future<void> loadTransactions() async {
final data = await DatabaseHelper.instance.getTransactions();

if (!mounted) return;

setState(() {
transactions = data.where((item) {
final matchesType = widget.selectedType == 'Tất cả' ||
item['type'] == widget.selectedType;

final matchesCategory =
widget.selectedCategory == 'Tất cả' ||
item['category'] == widget.selectedCategory;

return matchesType && matchesCategory;
}).toList();

loading = false;
});
}

@override
Widget build(BuildContext context) {
final total = transactions.fold<double>(
0,
(sum, item) => sum + getAmount(item),
);

return Scaffold(
appBar: AppBar(
title: const Text('Kết quả lọc'),
actions: [
IconButton(
onPressed: loadTransactions,
icon: const Icon(Icons.refresh),
),
],
),
body: loading
? const Center(child: CircularProgressIndicator())
: Column(
children: [
Container(
width: double.infinity,
margin: const EdgeInsets.all(16),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: primaryBlue.withValues(alpha: 0.1),
borderRadius: BorderRadius.circular(12),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Loại: ${widget.selectedType}'),
const SizedBox(height: 6),
Text('Danh mục: ${widget.selectedCategory}'),
const Divider(),
Text(
'Tổng giá trị: ${money(total)}',
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 18,
),
),
Text('Số giao dịch: ${transactions.length}'),
],
),
),
Expanded(
child: transactions.isEmpty
? const Center(
child: Text('Không tìm thấy giao dịch phù hợp.'),
): ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    return TransactionTile(
      transaction: transactions[index],
      onChanged: loadTransactions,
    );
  },
),
),
],
),
);
}
}