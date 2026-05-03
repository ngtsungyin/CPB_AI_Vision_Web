import 'package:flutter/material.dart';

class AdminTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool isLoading;

  const AdminTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (rows.isEmpty) {
      return const Expanded(
        child: Center(child: Text("No data available")),
      );
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }
}