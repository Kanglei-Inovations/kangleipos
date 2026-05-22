import 'package:get/get.dart';
import 'package:drift/drift.dart' as d;
import '../../../database/database.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserController extends GetxController {
  final AppDatabase db = Get.find<AppDatabase>();
  final _uuid = const Uuid();

  final RxList<User> users = <User>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshUsers();
  }

  Future<void> refreshUsers() async {
    isLoading.value = true;
    try {
      final list = await db.select(db.users).get();
      users.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }

  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  Future<void> addUser({
    required String name,
    required String username,
    required String pin,
    required String role,
  }) async {
    final id = _uuid.v4();
    await db.into(db.users).insert(UsersCompanion(
      id: d.Value(id),
      name: d.Value(name),
      username: d.Value(username),
      pin: d.Value(_hashPin(pin)),
      passwordHash: d.Value(_hashPin(pin)),
      role: d.Value(role),
    ));
    await refreshUsers();
  }

  Future<void> deleteUser(String id) async {
    // Prevent deleting self if needed, but let's keep it simple
    await (db.delete(db.users)..where((t) => t.id.equals(id))).go();
    await refreshUsers();
  }
}
