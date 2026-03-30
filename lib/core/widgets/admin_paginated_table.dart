import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdminTableColumn<T> {
  final String label;
  final double width;
  final double flexGrow;
  final Alignment alignment;
  final Widget Function(BuildContext context, T item) cellBuilder;

  const AdminTableColumn({
    required this.label,
    required this.width,
    required this.cellBuilder,
    this.flexGrow = 1,
    this.alignment = Alignment.centerLeft,
  });
}

class AdminPaginatedTable<T> extends StatefulWidget {
  final bool isLoading;
  final List<T> items;
  final List<AdminTableColumn<T>> columns;
  final int rowsPerPage;
  final String emptyMessage;
  final double rowMinHeight;
  final Color? headerColor;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry cellPadding;
  final BorderRadius? borderRadius;

  const AdminPaginatedTable({
    super.key,
    required this.isLoading,
    required this.items,
    required this.columns,
    this.rowsPerPage = 10,
    this.emptyMessage = 'No data found',
    this.rowMinHeight = 72,
    this.headerColor,
    this.headerPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.cellPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    this.borderRadius,
  });

  @override
  State<AdminPaginatedTable<T>> createState() => _AdminPaginatedTableState<T>();
}

class _AdminPaginatedTableState<T> extends State<AdminPaginatedTable<T>> {
  int _currentPage = 0;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AdminPaginatedTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pageCount = _pageCount;

    if (widget.items.isEmpty) {
      _currentPage = 0;
      return;
    }

    if (_currentPage >= pageCount && pageCount > 0) {
      _currentPage = pageCount - 1;
    }
  }

  int get _pageCount {
    if (widget.items.isEmpty) return 0;
    return (widget.items.length / widget.rowsPerPage).ceil();
  }

  List<T> get _currentItems {
    final start = _currentPage * widget.rowsPerPage;
    final end = math.min(start + widget.rowsPerPage, widget.items.length);

    if (start >= widget.items.length) return const [];
    return widget.items.sublist(start, end);
  }

  double get _baseTableWidth =>
      widget.columns.fold<double>(0, (sum, col) => sum + col.width);

  void _goToPage(int page) {
    if (page < 0 || page >= _pageCount) return;
    setState(() => _currentPage = page);
  }

  List<double> _resolvedColumnWidths(double availableWidth) {
    final targetWidth = math.max(availableWidth, _baseTableWidth);
    final extraWidth = math.max(0, targetWidth - _baseTableWidth);

    final totalGrow = widget.columns.fold<double>(
      0,
      (sum, col) => sum + (col.flexGrow > 0 ? col.flexGrow : 0),
    );

    return widget.columns.map((column) {
      if (extraWidth == 0 || totalGrow == 0 || column.flexGrow <= 0) {
        return column.width;
      }
      return column.width + (extraWidth * (column.flexGrow / totalGrow));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(10);
    final headerColor = widget.headerColor ?? Colors.grey.shade800;

    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: radius,
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final resolvedWidths =
                    _resolvedColumnWidths(constraints.maxWidth);
                final tableWidth = resolvedWidths.fold<double>(
                  0,
                  (sum, width) => sum + width,
                );
                final needsHorizontalScroll =
                    constraints.maxWidth < _baseTableWidth;

                return Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: needsHorizontalScroll,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: headerColor,
                              borderRadius: BorderRadius.only(
                                topLeft: radius.topLeft,
                                topRight: radius.topRight,
                              ),
                            ),
                            child: Row(
                              children: List.generate(widget.columns.length,
                                  (index) {
                                final column = widget.columns[index];
                                return SizedBox(
                                  width: resolvedWidths[index],
                                  child: Container(
                                    alignment: column.alignment,
                                    padding: widget.headerPadding,
                                    child: Text(
                                      column.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          Expanded(
                            child: widget.items.isEmpty
                                ? Center(
                                    child: Text(
                                      widget.emptyMessage,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _currentItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _currentItems[index];

                                      return Container(
                                        constraints: BoxConstraints(
                                          minHeight: widget.rowMinHeight,
                                        ),
                                        decoration: BoxDecoration(
                                          color: index.isEven
                                              ? Colors.white
                                              : Colors.grey.shade50,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: List.generate(
                                            widget.columns.length,
                                            (columnIndex) {
                                              final column =
                                                  widget.columns[columnIndex];

                                              return SizedBox(
                                                width:
                                                    resolvedWidths[columnIndex],
                                                child: Padding(
                                                  padding: widget.cellPadding,
                                                  child: column.cellBuilder(
                                                    context,
                                                    item,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.items.isNotEmpty)
            _PaginationBar(
              currentPage: _currentPage,
              pageCount: _pageCount,
              rowsPerPage: widget.rowsPerPage,
              totalItems: widget.items.length,
              onPageSelected: _goToPage,
            ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final int rowsPerPage;
  final int totalItems;
  final ValueChanged<int> onPageSelected;

  const _PaginationBar({
    required this.currentPage,
    required this.pageCount,
    required this.rowsPerPage,
    required this.totalItems,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final start = (currentPage * rowsPerPage) + 1;
    final end = math.min((currentPage + 1) * rowsPerPage, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;

          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildSummary(start, end),
              _buildControls(compact),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary(int start, int end) {
    final totalPages = pageCount == 0 ? 1 : pageCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            height: 1.35,
          ),
          children: [
            const TextSpan(text: 'Showing '),
            TextSpan(
              text: '$start-$end',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const TextSpan(text: ' of '),
            TextSpan(
              text: '$totalItems',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const TextSpan(text: ' records  •  Page '),
            TextSpan(
              text: '${currentPage + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const TextSpan(text: ' of '),
            TextSpan(
              text: '$totalPages',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(bool compact) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _navButton(
          icon: Icons.chevron_left_rounded,
          label: compact ? null : 'Previous',
          enabled: currentPage > 0,
          onTap: () => onPageSelected(currentPage - 1),
        ),
        ..._buildPageButtons(compact),
        _navButton(
          icon: Icons.chevron_right_rounded,
          label: compact ? null : 'Next',
          enabled: currentPage < pageCount - 1,
          onTap: () => onPageSelected(currentPage + 1),
        ),
      ],
    );
  }

  List<Widget> _buildPageButtons(bool compact) {
    const maxVisible = 5;

    if (pageCount <= maxVisible) {
      return List.generate(pageCount, _pageButton);
    }

    final start = math.max(0, currentPage - 2);
    final end = math.min(pageCount, start + maxVisible);
    final adjustedStart = math.max(0, end - maxVisible);

    final buttons = <Widget>[];

    if (adjustedStart > 0 && !compact) {
      buttons.add(_pageButton(0));
      if (adjustedStart > 1) {
        buttons.add(_ellipsis());
      }
    }

    for (int page = adjustedStart; page < end; page++) {
      buttons.add(_pageButton(page));
    }

    if (end < pageCount && !compact) {
      if (end < pageCount - 1) {
        buttons.add(_ellipsis());
      }
      buttons.add(_pageButton(pageCount - 1));
    }

    return buttons;
  }

  Widget _ellipsis() {
    return Container(
      alignment: Alignment.center,
      width: 32,
      height: 40,
      child: Text(
        '...',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _pageButton(int page) {
    final selected = page == currentPage;

    return InkWell(
      onTap: () => onPageSelected(page),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.grey.shade900 : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${page + 1}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    String? label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.45,
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: label == null ? 10 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!enabled) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: child,
    );
  }
}

class AdminTableText extends StatelessWidget {
  final String text;
  final int maxLines;
  final FontWeight? fontWeight;
  final Color? color;

  const AdminTableText(
    this.text, {
    super.key,
    this.maxLines = 2,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? Colors.black87,
        fontWeight: fontWeight,
      ),
    );
  }
}

class AdminTableActions extends StatelessWidget {
  final List<Widget> actions;

  const AdminTableActions({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: actions,
      ),
    );
  }
}