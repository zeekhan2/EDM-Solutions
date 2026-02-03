import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edm_solutions/consts/consts.dart';
import 'package:edm_solutions/Common_Widgets/safe_snackbar_helper.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class FacilityInformationPage extends StatefulWidget {
  const FacilityInformationPage({super.key});

  @override
  State<FacilityInformationPage> createState() =>
      _FacilityInformationPageState();
}

class _FacilityInformationPageState extends State<FacilityInformationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _typeCtrl = TextEditingController();
  final TextEditingController _licenseCtrl = TextEditingController();
  final TextEditingController _taxCtrl = TextEditingController();
  final TextEditingController _bedsCtrl = TextEditingController();
  final TextEditingController _deptsCtrl = TextEditingController();
  final TextEditingController _accredCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  bool _loading = false;

  /// 🔴 Backend validation errors
  Map<String, String> _apiErrors = {};

  @override
  void initState() {
    super.initState();
    _fetchFacilityDetail(); // PREFILL
  }

  // ================= FETCH =================
  Future<void> _fetchFacilityDetail() async {
  try {
    setState(() => _loading = true);

    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) return;

    final res = await ApiService.get(
      endpoint: '/api/facility/detail',
      token: token,
    );

    if (res.success == true && res.data != null) {
      final d = res.data['data'];

      _typeCtrl.text    = d['type'] ?? '';
      _licenseCtrl.text = d['license_number'] ?? '';
      _taxCtrl.text     = d['tax_id'] ?? '';
      _bedsCtrl.text    = d['total_beds']?.toString() ?? '';
      _deptsCtrl.text   = d['total_dept']?.toString() ?? '';
      _accredCtrl.text  = d['accreditation'] ?? '';
      _descCtrl.text    = d['description'] ?? '';

      // 🔑 THIS WAS MISSING
      setState(() {});
    }
  } catch (_) {
    SafeSnackbarHelper.showSafeSnackbar(
      title: 'Error',
      message: 'Failed to load facility details',
    );
  } finally {
    setState(() => _loading = false);
  }
}



  // ================= SAVE =================
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _loading = true;
        _apiErrors.clear();
      });

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) return;

      final res = await ApiService.post(
        endpoint: '/api/facility/detail/update',
        token: token,
        body: {
         
          'type': _typeCtrl.text.trim(),
          'license_number': _licenseCtrl.text.trim(),
          'tax_id': _taxCtrl.text.trim(),
          'total_dept': _deptsCtrl.text.trim(),
          'total_beds': _bedsCtrl.text.trim(),
          'accreditation': _accredCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
        },
      );

      if (res.success == true) {
        SafeSnackbarHelper.showSafeSnackbar(
          title: 'Updated',
          message: 'Facility information updated successfully',
        );

        // 🔁 REFRESH FORM SO IT IS NEVER EMPTY
        await _fetchFacilityDetail();
      } else {
        // 🔴 SHOW BACKEND FIELD ERRORS
        if (res.data != null && res.data['errors'] is Map) {
          final errors = Map<String, dynamic>.from(res.data['errors']);
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              _apiErrors[key] = value.first.toString();
            }
          });
        }
        setState(() {});
      }
    } catch (_) {
      SafeSnackbarHelper.showSafeSnackbar(
        title: 'Error',
        message: 'Something went wrong',
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
      );

  @override
  void dispose() {
    _typeCtrl.dispose();
    _licenseCtrl.dispose();
    _taxCtrl.dispose();
    _bedsCtrl.dispose();
    _deptsCtrl.dispose();
    _accredCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Facility Information',
          style: TextStyle(color: AppColors.textPrimary, fontFamily: semibold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 6),

              /// FACILITY TYPE
              Text('Facility Type',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontFamily: semibold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _typeCtrl.text.isEmpty ? null : _typeCtrl.text,
                decoration: _dec('Facility Type'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select facility type' : null,
                items: ['Hospital', 'Clinic', 'Long-term care', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => _typeCtrl.text = v ?? '',
              ),
              if (_apiErrors['type'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_apiErrors['type']!,
                      style:
                          const TextStyle(color: Colors.red, fontSize: 12)),
                ),

              const SizedBox(height: 12),

              /// LICENSE
              Text('License Number',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontFamily: semibold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _licenseCtrl,
                decoration: _dec('License Number'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter license' : null,
              ),

              const SizedBox(height: 12),

              /// TAX ID
              Text('Tax ID / EIN',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontFamily: semibold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _taxCtrl,
                decoration: _dec('Tax ID / EIN'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter tax id' : null,
              ),

              const SizedBox(height: 12),

              /// BEDS + DEPTS
              Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Beds',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: semibold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _bedsCtrl,
                          decoration: _dec('Total Beds'),
                          keyboardType: TextInputType.number,
                        ),
                        if (_apiErrors['total_beds'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_apiErrors['total_beds']!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
                          ),
                      ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Departments',
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontFamily: semibold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _deptsCtrl,
                          decoration: _dec('Departments'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter departments'
                              : null,
                        ),
                        if (_apiErrors['total_dept'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(_apiErrors['total_dept']!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
                          ),
                      ]),
                ),
              ]),

              const SizedBox(height: 12),

              /// ACCREDITATION
              Text('Accreditation',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontFamily: semibold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _accredCtrl,
                decoration: _dec('Accreditation'),
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION
              Text('Facility Description',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontFamily: semibold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                decoration: _dec('Facility Description'),
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
