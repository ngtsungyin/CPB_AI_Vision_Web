enum AccountStatus {
  pending_verification,
  pending_approved,
  approved,
}

extension AccountStatusExtension on AccountStatus {
  String get displayName {
    switch (this) {
      case AccountStatus.pending_verification:
        return 'Pending Verification';
      case AccountStatus.pending_approved:
        return 'Pending Approval';
      case AccountStatus.approved:
        return 'Approved';
    }
  }
}