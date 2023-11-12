import 'package:flutter/material.dart';
import 'package:hyper_ui/core.dart';
import '../controller/time_off_form_controller.dart';

class TimeOffFormView extends StatefulWidget {
  TimeOffFormView({Key? key}) : super(key: key);

  Widget build(context, TimeOffFormController controller) {
    controller.view = this;

    return Scaffold(
      appBar: AppBar(
        title: Text("TimeOffForm"),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                if (controller.leaveTypes.isNotEmpty)
                  QDropdownField(
                    label: "Type",
                    validator: Validator.required,
                    items: controller.leaveTypes
                        .map((e) => {
                              "label": e["name"],
                              "value": e["id"],
                            })
                        .toList(),
                    value: "Admin",
                    onChanged: (value, label) {
                      controller.leaveTypeId = value;
                    },
                  ),
                QDatePicker(
                  label: "Date From",
                  validator: Validator.required,
                  value: null,
                  onChanged: (value) {
                    controller.dateFrom = value;
                  },
                ),
                QDatePicker(
                  label: "Date To",
                  validator: Validator.required,
                  value: null,
                  onChanged: (value) {
                    controller.dateTo = value;
                  },
                ),
                QMemoField(
                  label: "Description",
                  validator: Validator.required,
                  value: null,
                  onChanged: (value) {
                    controller.name = value;
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

  @override
  State<TimeOffFormView> createState() => TimeOffFormController();
}
