import 'package:flutter/foundation.dart';
import '../models/inventory_models.dart';

class InventoryManagementProvider extends ChangeNotifier {
  InventorySubPage _currentPage = InventorySubPage.overview;
  bool _isSidebarOpen = false;
  int _totalSkuCount = 68;
  int _inventoryCurrentValue = 68;
  int _lowStockAlertsCount = 3;
  String? _selectedSkuId;
  InventorySkuRecord? _inspectedSku;

  final List<InventorySkuRecord> _skus = [
    const InventorySkuRecord(
      id: 'SKU-1',
      title: 'TMT Bar 12mm FE500D',
      specsSummary: 'Specs : Dia 12, FE500D, L 12m',
      stockLabel: '120 rolls',
      brand: 'Tata Tiscon',
      materialType: 'TMT Bar',
      grade: 'FE500D',
      length: '12m',
      quantity: 120,
      lowStockThreshold: 25,
      supplier: 'Tata Steel Dealer',
      storageLocation: 'Bay A-1',
      buyingPrice: 54000,
    ),
    const InventorySkuRecord(
      id: 'SKU-2',
      title: 'TMT Bar 12mm FE500D',
      specsSummary: 'Specs : Dia 12, FE500D, L 12m',
      stockLabel: '120 rolls',
      brand: 'JSW Steel',
      materialType: 'TMT Bar',
      grade: 'FE500D',
      length: '12m',
      quantity: 120,
      lowStockThreshold: 25,
      supplier: 'JSW Distribution',
      storageLocation: 'Bay A-2',
      buyingPrice: 53500,
    ),
    const InventorySkuRecord(
      id: 'SKU-3',
      title: 'TMT Bar 12mm FE500D',
      specsSummary: 'Specs : Dia 12, FE500D, L 12m',
      stockLabel: '120 rolls',
      brand: 'SAIL',
      materialType: 'TMT Bar',
      grade: 'FE500D',
      length: '12m',
      quantity: 120,
      lowStockThreshold: 25,
      supplier: 'SAIL Yard',
      storageLocation: 'Bay B-1',
      buyingPrice: 52800,
    ),
  ];

  InventorySubPage get currentPage => _currentPage;
  bool get isSidebarOpen => _isSidebarOpen;
  int get totalSkuCount => _totalSkuCount;
  int get inventoryCurrentValue => _inventoryCurrentValue;
  int get lowStockAlertsCount => _lowStockAlertsCount;
  String? get selectedSkuId => _selectedSkuId;
  InventorySkuRecord? get inspectedSku => _inspectedSku;
  List<InventorySkuRecord> get skus => List.unmodifiable(_skus);

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setSidebarOpen(bool open) {
    _isSidebarOpen = open;
    notifyListeners();
  }

  void openPage(InventorySubPage page) {
    _currentPage = page;
    notifyListeners();
  }

  void inspectSku(InventorySkuRecord sku) {
    _inspectedSku = sku;
    _selectedSkuId = sku.id;
    notifyListeners();
  }

  void clearInspectedSku() {
    _inspectedSku = null;
    notifyListeners();
  }

  void selectSku(String? skuId) {
    _selectedSkuId = skuId;
    notifyListeners();
  }

  void createSku({
    required String materialType,
    required String brand,
    required String specification,
    required String grade,
    required String length,
    required String quantityText,
    required String weightPrefix,
    required String lowStockThresholdText,
    required String supplier,
    required String storageLocation,
    required String buyingPriceText,
    required String notes,
  }) {
    final cleanType = materialType.trim().isEmpty ? 'TMT Bar' : materialType.trim();
    final cleanBrand = brand.trim().isEmpty ? 'Tata Tiscon' : brand.trim();
    final cleanSpec = specification.trim().isEmpty ? 'Dia 12' : specification.trim();
    final cleanGrade = grade.trim().isEmpty ? 'FE500D' : grade.trim();
    final cleanLength = length.trim().isEmpty ? '12m' : length.trim();
    final parsedQty = int.tryParse(quantityText.trim()) ?? 120;
    final parsedThreshold = int.tryParse(lowStockThresholdText.trim()) ?? 10;
    final parsedPrice = double.tryParse(buyingPriceText.trim()) ?? 0;

    final newSku = InventorySkuRecord(
      id: 'SKU-${DateTime.now().millisecondsSinceEpoch}',
      title: '$cleanType $cleanSpec $cleanGrade',
      specsSummary: 'Specs : $cleanSpec, $cleanGrade, L $cleanLength',
      stockLabel: '$parsedQty rolls',
      brand: cleanBrand,
      materialType: cleanType,
      grade: cleanGrade,
      length: cleanLength,
      quantity: parsedQty,
      lowStockThreshold: parsedThreshold,
      supplier: supplier.trim(),
      storageLocation: storageLocation.trim(),
      buyingPrice: parsedPrice,
      notes: notes.trim(),
      weightPrefix: weightPrefix.trim(),
    );

    _skus.insert(0, newSku);
    _selectedSkuId = newSku.id;
    _totalSkuCount += 1;
    _inventoryCurrentValue += 1;
    if (newSku.isLowStock) {
      _lowStockAlertsCount += 1;
    }
    _currentPage = InventorySubPage.overview;
    notifyListeners();
  }

  void updateInventoryStock({
    required String? skuId,
    required String adjustmentForm,
    required String unit,
    required String quantityText,
    required String supplier,
    required String storageLocation,
    required String buyingPriceText,
  }) {
    final delta = int.tryParse(quantityText.trim()) ?? 0;
    final parsedPrice = double.tryParse(buyingPriceText.trim());
    final cleanUnit = unit.trim().isEmpty ? 'rolls' : unit.trim().toLowerCase();

    if (skuId != null && _skus.isNotEmpty) {
      final idx = _skus.indexWhere((s) => s.id == skuId);
      if (idx != -1) {
        final current = _skus[idx];
        final isDeduction = adjustmentForm.toLowerCase().contains('deduct') ||
            adjustmentForm.toLowerCase().contains('damage');
        final nextQty = isDeduction
            ? (current.quantity - delta).clamp(0, 999999)
            : (current.quantity + delta).clamp(0, 999999);

        _skus[idx] = current.copyWith(
          quantity: nextQty,
          stockLabel: '$nextQty $cleanUnit',
          supplier: supplier.trim().isEmpty ? current.supplier : supplier.trim(),
          storageLocation: storageLocation.trim().isEmpty
              ? current.storageLocation
              : storageLocation.trim(),
          buyingPrice: parsedPrice ?? current.buyingPrice,
        );
      }
    }

    if (delta > 0) {
      _inventoryCurrentValue += delta;
    }
    _currentPage = InventorySubPage.overview;
    notifyListeners();
  }

  bool confirmDangerAction({
    required DangerActionType actionType,
    required String password,
    String? skuId,
  }) {
    if (password.trim().isEmpty) return false;

    final targetId = skuId ?? _selectedSkuId;
    switch (actionType) {
      case DangerActionType.deleteSku:
        if (targetId != null) {
          _skus.removeWhere((s) => s.id == targetId);
          if (_selectedSkuId == targetId) _selectedSkuId = null;
        } else if (_skus.isNotEmpty) {
          _skus.removeAt(0);
        }
        _totalSkuCount = (_totalSkuCount - 1).clamp(0, 999999);
        _inventoryCurrentValue = (_inventoryCurrentValue - 1).clamp(0, 999999);
        break;
      case DangerActionType.clearSalesHistory:
        break;
      case DangerActionType.deleteEverythingForSku:
        if (targetId != null) {
          _skus.removeWhere((s) => s.id == targetId);
          if (_selectedSkuId == targetId) _selectedSkuId = null;
        }
        _totalSkuCount = (_totalSkuCount - 1).clamp(0, 999999);
        _inventoryCurrentValue = (_inventoryCurrentValue - 1).clamp(0, 999999);
        _lowStockAlertsCount = (_lowStockAlertsCount - 1).clamp(0, 999999);
        break;
    }

    notifyListeners();
    return true;
  }
}