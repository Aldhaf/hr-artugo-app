import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyper_ui/core.dart' hide Get;

class TimeOffFormView extends StatelessWidget {
  const TimeOffFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TimeOffFormController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Time Off Form"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                // Obx digunakan agar Dropdown hanya muncul setelah datanya siap
                Obx(() {
                  if (controller.leaveTypes.isEmpty) {
                    return const Text("Loading leave types...");
                  }
                  return QDropdownField(
                    label: "Type",
                    validator: Validator.required,
                    items: controller.leaveTypes
                        .map((e) => {
                              "label": e["name"],
                              "value": e["id"],
                            })
                        .toList(),
                    // Value sekarang terikat dengan state di controller
                    value: controller.leaveTypeId.value,
                    onChanged: (value, label) {
                      controller.leaveTypeId.value = value;
                    },
                  );
                }),
                QDatePicker(
                  label: "Date From",
                  validator: Validator.required,
                  onChanged: (value) {
                    controller.dateFrom.value = value;
                  },
                ),
                QDatePicker(
                  label: "Date To",
                  validator: Validator.required,
                  onChanged: (value) {
                    controller.dateTo.value = value;
                  },
                ),
                QMemoField(
                  label: "Description",
                  validator: Validator.required,
                  onChanged: (value) {
                    controller.name.value = value;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: QActionButton(
        label: "Save",
        onPressed: () => controller.doSave(),
      ),
    );
  }
}
