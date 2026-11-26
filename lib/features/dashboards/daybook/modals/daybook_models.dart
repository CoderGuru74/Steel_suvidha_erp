enum DaybookSubPage {
  overview('Overview'),
  deletion('Daybook Deletion');

  final String label;
  const DaybookSubPage(this.label);
}

enum DaybookDangerAction {
  deleteDaybook('Delete Daybook'),
  clearDaybookHistory('Clear daybook History');

  final String buttonLabel;
  const DaybookDangerAction(this.buttonLabel);
}

class DaybookLineEntry {
  final String itemLabel;
  final String qtyLabel;

  const DaybookLineEntry({
    required this.itemLabel,
    required this.qtyLabel,
  });
}

class DaybookOrderEntry {
  final String id;
  final String companyName;
  final String orderCode;
  final String statusLabel;
  final List<DaybookLineEntry> lines;
  final String customerName;
  final String phone;
  final String referenceCode;
  final String amountLabel;
  final String timestampLabel;

  const DaybookOrderEntry({
    required this.id,
    required this.companyName,
    required this.orderCode,
    required this.statusLabel,
    required this.lines,
    required this.customerName,
    required this.phone,
    required this.referenceCode,
    required this.amountLabel,
    required this.timestampLabel,
  });
}