enum InventorySubPage {
  overview('Overview'),
  createSku('Create SKU'),
  updatingInventory('Updating Inventory'),
  dangerZone('SKU Danger Zone');

  final String label;
  const InventorySubPage(this.label);
}

enum DangerActionType {
  deleteSku('Delete SKU'),
  clearSalesHistory('Clear Sales History'),
  deleteEverythingForSku('Delete everything related to this SKU');

  final String buttonLabel;
  const DangerActionType(this.buttonLabel);
}

class InventorySkuRecord {
  final String id;
  final String title;
  final String specsSummary;
  final String stockLabel;
  final String brand;
  final String materialType;
  final String grade;
  final String length;
  final int quantity;
  final int lowStockThreshold;
  final String supplier;
  final String storageLocation;
  final double buyingPrice;
  final String notes;
  final String weightPrefix;

  const InventorySkuRecord({
    required this.id,
    required this.title,
    required this.specsSummary,
    required this.stockLabel,
    required this.brand,
    required this.materialType,
    required this.grade,
    required this.length,
    required this.quantity,
    this.lowStockThreshold = 10,
    this.supplier = '',
    this.storageLocation = '',
    this.buyingPrice = 0,
    this.notes = '',
    this.weightPrefix = '',
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  InventorySkuRecord copyWith({
    String? title,
    String? specsSummary,
    String? stockLabel,
    String? brand,
    String? materialType,
    String? grade,
    String? length,
    int? quantity,
    int? lowStockThreshold,
    String? supplier,
    String? storageLocation,
    double? buyingPrice,
    String? notes,
    String? weightPrefix,
  }) {
    return InventorySkuRecord(
      id: id,
      title: title ?? this.title,
      specsSummary: specsSummary ?? this.specsSummary,
      stockLabel: stockLabel ?? this.stockLabel,
      brand: brand ?? this.brand,
      materialType: materialType ?? this.materialType,
      grade: grade ?? this.grade,
      length: length ?? this.length,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      supplier: supplier ?? this.supplier,
      storageLocation: storageLocation ?? this.storageLocation,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      notes: notes ?? this.notes,
      weightPrefix: weightPrefix ?? this.weightPrefix,
    );
  }
}