// lib/services/firebase_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream trạng thái đăng nhập ─────────────────────────────────────
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  // ── Đăng ký ─────────────────────────────────────────────────────────
  static Future<UserCredential> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user!.updateDisplayName(fullName);

    // Tạo document user trong Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'displayName': fullName,
      'email': email,
      'photoURL': null,
      'currency': 'VND',
      'language': 'vi',
      'notificationsEnabled': true,
      'darkMode': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Tạo categories mặc định
    await _seedDefaultCategories(cred.user!.uid);

    return cred;
  }

  // ── Đăng nhập ────────────────────────────────────────────────────────
  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  // ── Đăng xuất ────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Quên mật khẩu ────────────────────────────────────────────────────
  static Future<void> forgotPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── Đổi mật khẩu ─────────────────────────────────────────────────────
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser!;
    final cred = EmailAuthProvider.credential(
        email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  // ── Cập nhật profile ──────────────────────────────────────────────────
  static Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? currency,
    bool? notificationsEnabled,
    bool? darkMode,
  }) async {
    final uid = currentUserId!;
    final updates = <String, dynamic>{};
    if (displayName != null) {
      updates['displayName'] = displayName;
      await _auth.currentUser!.updateDisplayName(displayName);
    }
    if (photoURL != null) {
      updates['photoURL'] = photoURL;
      await _auth.currentUser!.updatePhotoURL(photoURL);
    }
    if (currency != null) updates['currency'] = currency;
    if (notificationsEnabled != null) {
      updates['notificationsEnabled'] = notificationsEnabled;
    }
    if (darkMode != null) updates['darkMode'] = darkMode;

    if (updates.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updates);
    }
  }

  // ── Lấy thông tin user ────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUserData() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Stream user data ──────────────────────────────────────────────────
  static Stream<Map<String, dynamic>?> userDataStream() {
    final uid = currentUserId;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((s) => s.data());
  }

  // ── Tạo categories mặc định ───────────────────────────────────────────
  static Future<void> _seedDefaultCategories(String uid) async {
    final batch = _db.batch();
    final col = _db.collection('users').doc(uid).collection('categories');

    final defaults = [
      // Chi tiêu
      {'name': 'Ăn uống', 'type': 'EXPENSE', 'icon': 'restaurant', 'color': 'orange'},
      {'name': 'Mua sắm', 'type': 'EXPENSE', 'icon': 'shopping_cart', 'color': 'pink'},
      {'name': 'Di chuyển', 'type': 'EXPENSE', 'icon': 'directions_car', 'color': 'blue'},
      {'name': 'Nhà cửa', 'type': 'EXPENSE', 'icon': 'home', 'color': 'brown'},
      {'name': 'Học tập', 'type': 'EXPENSE', 'icon': 'school', 'color': 'indigo'},
      {'name': 'Giải trí', 'type': 'EXPENSE', 'icon': 'movie', 'color': 'purple'},
      {'name': 'Y tế', 'type': 'EXPENSE', 'icon': 'health_and_safety', 'color': 'red'},
      {'name': 'Khác', 'type': 'EXPENSE', 'icon': 'more_horiz', 'color': 'grey'},
      // Thu nhập
      {'name': 'Lương', 'type': 'INCOME', 'icon': 'attach_money', 'color': 'green'},
      {'name': 'Thưởng', 'type': 'INCOME', 'icon': 'card_giftcard', 'color': 'teal'},
      {'name': 'Tiền lãi', 'type': 'INCOME', 'icon': 'savings', 'color': 'cyan'},
      {'name': 'Được cho/tặng', 'type': 'INCOME', 'icon': 'volunteer_activism', 'color': 'lime'},
      {'name': 'Thu nhập khác', 'type': 'INCOME', 'icon': 'trending_up', 'color': 'green'},
    ];

    for (final cat in defaults) {
      final ref = col.doc();
      batch.set(ref, {
        ...cat,
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
