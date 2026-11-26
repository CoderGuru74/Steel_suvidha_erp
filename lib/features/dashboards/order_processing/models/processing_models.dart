enum ProcessingOrderStatus {
  all('All'),
  pending('Pending'),
  inProgress('In Progress');

  final String label;
  const ProcessingOrderStatus(this.label);
}

class ProcessingWeightLine {
  final String id;
  final String productNameAndCategory;
  final String estimatedLabel;
  final String exactWeightKg;
  final String notes;

  const ProcessingWeightLine({
    required this.id,
    required this.productNameAndCategory,
    required this.estimatedLabel,
    this.exactWeightKg = '',
    this.notes = '',
  });

  ProcessingWeightLine copyWith({
    String? exactWeightKg,
    String? notes,
  }) {
    return ProcessingWeightLine(
      id: id,
      productNameAndCategory: productNameAndCategory,
      estimatedLabel: estimatedLabel,
      exactWeightKg: exactWeightKg ?? this.exactWeightKg,
      notes: notes ?? this.notes,
    );
  }
}

class ProcessingOrderItem {
  final String id;
  final String orderCode;
  final String status;
  final String timeAgo;
  final String customerName;
  final String companyName;
  final String itemsSummary;
  final List<ProcessingWeightLine> weightLines;

  const ProcessingOrderItem({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.timeAgo,
    required this.customerName,
    required this.companyName,
    required this.itemsSummary,
    required this.weightLines,
  });

  ProcessingOrderItem copyWith({
    String? status,
    String? timeAgo,
    List<ProcessingWeightLine>? weightLines,
  }) {
    return ProcessingOrderItem(
      id: id,
      orderCode: orderCode,
      status: status ?? this.status,
      timeAgo: timeAgo ?? this.timeAgo,
      customerName: customerName,
      companyName: companyName,
      itemsSummary: itemsSummary,
      weightLines: weightLines ?? this.weightLines,
    );
  }
}