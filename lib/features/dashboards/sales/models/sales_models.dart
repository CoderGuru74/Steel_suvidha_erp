enum SalesOrderStatus {
  inProcessing('In Processing', 0xFF93A5FD, 0xFF1E3A8A),
  estimateShared('Estimate Shared', 0xFF86EFAC, 0xFF166534),
  readyForBilling('Ready for Billing', 0xFFFDE68A, 0xFF92400E);

  final String label;
  final int bgColorValue;
  final int textColorValue;

  const SalesOrderStatus(
    this.label,
    this.bgColorValue,
    this.textColorValue,
  );
}

class SalesOrderItem {
  final String name;
  final int qty;
  final int rate;

  const SalesOrderItem({
    required this.name,
    required this.qty,
    required this.rate,
  });

  int get amount => qty * rate;
}

class SalesOrderRecord {
  final String id;
  final String orderCode;
  final String customerName;
  final String contactPerson;
  final String phone;
  final String gstin;
  final String itemsSummary;
  final String orderDate;
  final String statusLabel;
  final List<SalesOrderItem> lineItems;
  final int gstAmount;

  const SalesOrderRecord({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.contactPerson,
    required this.phone,
    required this.gstin,
    required this.itemsSummary,
    required this.orderDate,
    required this.statusLabel,
    required this.lineItems,
    required this.gstAmount,
  });

  int get subTotal => lineItems.fold(0, (sum, item) => sum + item.amount);
  int get totalAmount => subTotal + gstAmount;

  SalesOrderRecord copyWith({
    String? statusLabel,
    String? customerName,
    String? itemsSummary,
  }) {
    return SalesOrderRecord(
      id: id,
      orderCode: orderCode,
      customerName: customerName ?? this.customerName,
      contactPerson: contactPerson,
      phone: phone,
      gstin: gstin,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      orderDate: orderDate,
      statusLabel: statusLabel ?? this.statusLabel,
      lineItems: lineItems,
      gstAmount: gstAmount,
    );
  }
}

class SalesCustomerRecord {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String gstin;

  const SalesCustomerRecord({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.gstin,
  });
}

class SalesInventoryDraftItem {
  final String id;
  final String productType;
  final String brand;
  final String specification;
  final String grade;
  final String length;
  final String quantity;
  final String weightPrefix;
  final String actualWeight;
  final String purchasePrice;
  final String sellingPrice;

  const SalesInventoryDraftItem({
    required this.id,
    required this.productType,
    required this.brand,
    required this.specification,
    required this.grade,
    required this.length,
    required this.quantity,
    required this.weightPrefix,
    required this.actualWeight,
    required this.purchasePrice,
    required this.sellingPrice,
  });

  String get displayName {
    final spec = specification.isNotEmpty ? specification : '12mm';
    final gr = grade.isNotEmpty ? grade : 'FE500D';
    final pt = productType.isNotEmpty ? productType : 'TMT Bar';
    return '$spec $gr $pt';
  }

  int get parsedQty {
    final q = int.tryParse(quantity.trim());
    return (q == null || q <= 0) ? 1 : q;
  }

  int get parsedRate {
    final clean = sellingPrice.replaceAll(RegExp(r'[^0-9]'), '');
    final r = int.tryParse(clean);
    return (r == null || r <= 0) ? 55 : r;
  }
}