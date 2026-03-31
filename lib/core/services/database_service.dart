import 'package:cpbaivision_app/shared/models/database_models.dart';
import 'package:cpbaivision_app/features/dashboard/services/dashboard_service.dart';
import 'package:cpbaivision_app/features/farms/services/farm_service.dart';
import 'package:cpbaivision_app/features/scan/services/scan_service.dart';
import 'package:cpbaivision_app/features/scan/services/scan_session_service.dart';
import 'package:cpbaivision_app/features/users/services/user_service.dart';
import 'package:cpbaivision_app/features/yields/services/yield_service.dart';
import 'package:cpbaivision_app/features/admin/services/admin_audit_log_service.dart';


class DatabaseService {
  final UserService _userService = UserService();
  final FarmService _farmService = FarmService();
  final ScanService _scanService = ScanService();
  final YieldService _yieldService = YieldService();
  final ScanSessionService _scanSessionService = ScanSessionService();
  final DashboardService _dashboardService = DashboardService();
  final AdminAuditLogService _adminAuditLogService = AdminAuditLogService();

  // User Operations
  Future<AppUser?> getUser(String userId) => _userService.getUser(userId);
  Future<AppUser?> getUserById(String userId) => _userService.getUserById(userId);
  Future<List<AppUser>> getAllUsers() => _userService.getAllUsers();
  Future<bool> createUser(AppUser user) => _userService.createUser(user);
  Future<bool> updateUserStatus(String userId, String newStatus, String adminEmail) =>
      _userService.updateUserStatus(userId, newStatus, adminEmail);
  Future<bool> updateUserRole(String userId, String newRole, String adminEmail) =>
      _userService.updateUserRole(userId, newRole, adminEmail);
  Future<bool> deleteUser(String userId, String adminEmail) => _userService.deleteUser(userId, adminEmail);

  // Farm Operations
  Future<List<Farm>> getUserFarms(String userId) => _farmService.getUserFarms(userId);
  Future<bool> createFarm(Farm farm) => _farmService.createFarm(farm);
  Future<List<Farm>> getAllFarms() => _farmService.getAllFarms();
  Future<Farm?> getFarmById(String farmId) => _farmService.getFarmById(farmId);
  Future<bool> updateFarm(Farm farm, String adminEmail) => _farmService.updateFarm(farm, adminEmail);
  Future<bool> updateFarmStatus(String farmId, bool isActive, String adminEmail) =>
      _farmService.updateFarmStatus(farmId, isActive, adminEmail);
  Future<bool> deleteFarm(String farmId, String adminEmail) => _farmService.deleteFarm(farmId, adminEmail);

  // Scan Operations
  Future<bool> createScan(Map<String, dynamic> scanData) =>
      _scanService.createScan(scanData);
  Future<List<Scan>> getFarmScans(String farmId) => _scanService.getFarmScans(farmId);
  Future<List<Scan>> getAllScans() => _scanService.getAllScans();

  // Yield Operations
  Future<List<YieldRecord>> getAllYieldRecords() =>
      _yieldService.getAllYieldRecords();
  Future<bool> deleteYieldRecord(String recordId, String adminEmail) =>
      _yieldService.deleteYieldRecord(recordId, adminEmail);

  // Scan Session Operations
  Future<List<ScanSession>> getAllScanSessions() =>
      _scanSessionService.getAllScanSessions();

  // Dashboard Operations
  Future<Map<String, dynamic>> getDashboardStats() =>
      _dashboardService.getDashboardStats();
  Future<List<Map<String, dynamic>>> getRecentActivity() =>
      _dashboardService.getRecentActivity();
  Future<bool> checkConnection() => _dashboardService.checkConnection();

  // Admin Audit Log Operations
  Future<List<AdminAuditLog>> getAllAuditLogs() =>
      _adminAuditLogService.getAllAuditLogs();
  Future<bool> createAuditLog(AdminAuditLog log) =>
      _adminAuditLogService.createAuditLog(log);
}

