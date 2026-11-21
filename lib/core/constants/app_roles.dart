enum UserRole {
  superAdmin,
  admin,
  inventoryManagement,
  salesPanel,
  orderProcessing,
  daybookManagement,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.inventoryManagement:
        return 'Inventory Management';
      case UserRole.salesPanel:
        return 'Sales Panel';
      case UserRole.orderProcessing:
        return 'Order Processing Team';
      case UserRole.daybookManagement:
        return 'Daybook Management';
    }
  }

  String get routePath {
    switch (this) {
      case UserRole.superAdmin:
        return '/super-admin';
      case UserRole.admin:
        return '/admin';
      case UserRole.inventoryManagement:
        return '/inventory';
      case UserRole.salesPanel:
        return '/sales';
      case UserRole.orderProcessing:
        return '/orders';
      case UserRole.daybookManagement:
        return '/daybook';
    }
  }
}