import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
const DashboardScreen({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Quản lý thu chi'),
centerTitle: false,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Số dư hiện tại
Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
color: Colors.blue,
borderRadius: BorderRadius.circular(20),
),
child: const Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'SỐ DƯ HIỆN TẠI',
style: TextStyle(
color: Colors.white,
fontSize: 14,
),
),
SizedBox(height: 8),
Text(
'5.000.000 đ',
style: TextStyle(
color: Colors.white,
fontSize: 32,
fontWeight: FontWeight.bold,
),
),
],
),
),

const SizedBox(height: 16),

// Tổng thu nhập và tổng chi tiêu
Row(
children: [
Expanded(
child: _summaryCard(
'TỔNG THU NHẬP',
'8.000.000 đ',
Colors.green,
),
),
const SizedBox(width: 12),
Expanded(
child: _summaryCard(
'TỔNG CHI TIÊU',
'3.000.000 đ',
Colors.red,
),
),
],
),

const SizedBox(height: 24),

// Tiêu đề giao dịch
const Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Text(
'Giao dịch gần đây',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
Text(
'Xem tất cả',
style: TextStyle(color: Colors.blue),
),
],
),

const SizedBox(height: 12),

_transactionItem('Ăn trưa', 'Ăn uống', '-50.000 đ'),
_transactionItem('Xăng xe', 'Di chuyển', '-100.000 đ'),
_transactionItem('Lương tháng 9', 'Thu nhập', '+8.000.000 đ'),
  _transactionItem('Mua sắm', 'Mua sắm', '-300.000 đ'),
  _transactionItem('Học phí', 'Giáo dục', '-500.000 đ'),
],
),
),

  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: const Icon(Icons.add),
  ),

  bottomNavigationBar: BottomNavigationBar(
    currentIndex: 0,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Giao dịch',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Thống kê',
      ),
    ],
  ),
);
}

static Widget _summaryCard(
    String title,
    String amount,
    Color color,
    ) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha:0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

static Widget _transactionItem(
    String title,
    String category,
    String amount,
    ) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.restaurant),
      ),
      title: Text(title),
      subtitle: Text(category),
      trailing: Text(
        amount,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
}