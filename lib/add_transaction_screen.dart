import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
bool isExpense = true;

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,

appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
leading: IconButton(
icon: const Icon(
Icons.arrow_back,
color: Color(0xFF172B4D),
),
onPressed: () {},
),
title: const Text(
'Thêm giao dịch',
style: TextStyle(
color: Color(0xFF172B4D),
fontWeight: FontWeight.bold,
),
),
centerTitle: true,
),

body: Padding(
padding: const EdgeInsets.all(24),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

// Chi tiêu / Thu nhập
Row(
children: [
Expanded(
child: _typeButton(
'Chi tiêu',
isExpense,
() {
setState(() {
isExpense = true;
});
},
),
),
const SizedBox(width: 12),
Expanded(
child: _typeButton(
'Thu nhập',
!isExpense,
() {
setState(() {
isExpense = false;
});
},
),
),
],
),

const SizedBox(height: 24),

// Danh mục
const Text(
'Danh mục',
style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),

_inputBox(
child: const Row(
children: [
Icon(Icons.restaurant, color: Colors.orange),
SizedBox(width: 12),
Text('Ăn uống'),
Spacer(),
Icon(Icons.keyboard_arrow_down),
],
),
),

const SizedBox(height: 20),

// Số tiền
const Text(
'Số tiền',
style: TextStyle(fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),

_inputBox(
child: const Text(
'100.000 VNĐ',
style: TextStyle(fontSize: 15),
),
),

const SizedBox(height: 20),

// Ngày
const Text( 'Ngày giao dịch',
  style: TextStyle(fontWeight: FontWeight.bold),
),
  const SizedBox(height: 8),

  _inputBox(
    child: const Row(
      children: [
        Icon(Icons.calendar_today_outlined),
        SizedBox(width: 12),
        Text('12/04/2025'),
      ],
    ),
  ),

  const SizedBox(height: 20),

  // Ghi chú
  const Text(
    'Ghi chú',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 8),

  _inputBox(
    height: 80,
    child: const Text('Ăn trưa'),
  ),

  const Spacer(),

  // Lưu
  SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      child: const Text('Lưu giao dịch'),
    ),
  ),
],
),
),
);
}

Widget _typeButton(
    String text,
    bool selected,
    VoidCallback onTap,
    ) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 45,
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF1976D2)
            : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget _inputBox({
  required Widget child,
  double height = 50,
}) {
  return Container(
    width: double.infinity,
    height: height,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFFE1E6ED),
      ),
    ),
    child: child,
  );
}
}