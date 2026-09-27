import 'package:flutter/material.dart';

class EditTransactionScreen extends StatelessWidget {
  const EditTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa giao dịch'),
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
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Chi tiêu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Thu nhập'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Danh mục'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Ăn uống',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Text('Số tiền'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: '100.000 VNĐ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Text('Ngày giao dịch'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: '12/04/2025',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Text('Ghi chú'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Ăn trưa',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Cập nhật giao dịch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}