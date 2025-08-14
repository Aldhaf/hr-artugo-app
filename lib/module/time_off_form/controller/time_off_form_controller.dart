import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get;
import 'package:hyper_ui/service/leave_type_service/leave_type_service.dart';

class TimeOffFormController extends GetxController {
  // --- State Variables ---
  // Variabel form dibuat reaktif, Rxn<> digunakan agar bisa null di awal.
  var leaveTypeId = Rxn<int>();
  var dateFrom = Rxn<DateTime>();
  var dateTo = Rxn<DateTime>();
  var name = Rxn<String>();

  // Variabel untuk menampung pilihan jenis cuti dari Odoo
  var leaveTypes = <Map>[].obs;

  // GlobalKey untuk validasi form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    getLeaveTypes();
  }

  // --- Logic ---
  getLeaveTypes() async {
    var response = await LeaveTypeService().get();
    leaveTypes.value = List<Map>.from(response);
  }

  doSave() async {
    bool isValid = formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (leaveTypeId.value == null ||
        name.value == null ||
        dateFrom.value == null ||
        dateTo.value == null) {
      Get.snackbar("Error", "All fields must be filled");
      return;
    }

    // --- GANTI showLoading() DENGAN Get.dialog() ---
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false, // Mencegah dialog ditutup oleh user
    );

    try {
      bool isSuccess = await TimeOffService().create(
        leaveTypeId: leaveTypeId.value!,
        name: name.value!,
        dateFrom: dateFrom.value!,
        dateTo: dateTo.value!,
      );

      // Tutup dialog loading SEBELUM menampilkan snackbar atau kembali
      Get.back();

      if (!isSuccess) {
        Get.snackbar("Error",
            "Failed to create time off, leave balance might be insufficient!");
        return;
      }

      Get.back(result: true);
    } catch (e) {
      // Jika terjadi error, pastikan dialog loading juga ditutup
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}");
    }
  }
}
