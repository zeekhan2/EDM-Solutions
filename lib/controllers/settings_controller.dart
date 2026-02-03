// lib/controllers/settings_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // observable fields
  final RxString facilityName = 'City General Hospital'.obs;
  final RxString contactPerson = 'Dr. John Anderson'.obs;
  final RxString email = 'admin@citygeneralhospital.com'.obs;
  final RxString phone = '+1 (555) 123-4567'.obs;
  final RxString address = '123 Healthcare Drive, New York, NY 10001'.obs;
  final RxString avatarPath = ''.obs;

  static const _kFacility = 'account_facility';
  static const _kContact = 'account_contact';
  static const _kEmail = 'account_email';
  static const _kPhone = 'account_phone';
  static const _kAddress = 'account_address';
  static const _kAvatar = 'account_avatar_path';

  @override
  void onInit() {
    super.onInit();
    loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    final sp = await SharedPreferences.getInstance();
    facilityName.value = sp.getString(_kFacility) ?? facilityName.value;
    contactPerson.value = sp.getString(_kContact) ?? contactPerson.value;
    email.value = sp.getString(_kEmail) ?? email.value;
    phone.value = sp.getString(_kPhone) ?? phone.value;
    address.value = sp.getString(_kAddress) ?? address.value;
    avatarPath.value = sp.getString(_kAvatar) ?? avatarPath.value;
  }

  Future<void> saveToPrefs({
    String? facility,
    String? contact,
    String? mail,
    String? ph,
    String? addr,
    String? avatar,
    required String licenseNumber,
    required String taxId,
    required String totalBeds,
    required String departments,
  }) async {
    final sp = await SharedPreferences.getInstance();
    if (facility != null) {
      facilityName.value = facility;
      await sp.setString(_kFacility, facility);
    }
    if (contact != null) {
      contactPerson.value = contact;
      await sp.setString(_kContact, contact);
    }
    if (mail != null) {
      email.value = mail;
      await sp.setString(_kEmail, mail);
    }
    if (ph != null) {
      phone.value = ph;
      await sp.setString(_kPhone, ph);
    }
    if (addr != null) {
      address.value = addr;
      await sp.setString(_kAddress, addr);
    }
    if (avatar != null) {
      avatarPath.value = avatar;
      await sp.setString(_kAvatar, avatar);
    }
  }

  // helper to clear (optional)
  Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kFacility);
    await sp.remove(_kContact);
    await sp.remove(_kEmail);
    await sp.remove(_kPhone);
    await sp.remove(_kAddress);
    await sp.remove(_kAvatar);

    // reset to defaults
    facilityName.value = 'City General Hospital';
    contactPerson.value = 'Dr. John Anderson';
    email.value = 'admin@citygeneralhospital.com';
    phone.value = '+1 (555) 123-4567';
    address.value = '123 Healthcare Drive, New York, NY 10001';
    avatarPath.value = '';
  }
}
