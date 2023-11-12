ElevatedButton(
style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
),
onPressed: () async {
    var res = await OdooApi.get(model: "res.users");
    print(res);
},
child: const Text("Get"),
),
const SizedBox(
height: 12.0,
),
ElevatedButton(
style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
),
onPressed: () async {
    var res = await OdooApi.create(model: "res.partner", data: {
    'name': 'Deny',
    });
    print(res);
},
child: const Text("Create"),
),
const SizedBox(
height: 12.0,
),
ElevatedButton(
style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
),
onPressed: () async {
    var res = await OdooApi.update(
    model: "res.partner",
    id: 10,
    data: {
        'name': 'Danu',
    },
    );
    print(res);
},
child: const Text("Update"),
),
const SizedBox(
height: 12.0,
),
ElevatedButton(
style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
),
onPressed: () async {
    var res = await OdooApi.delete(
    model: "res.partner",
    id: 10,
    );
    print(res);
},
child: const Text("Delete"),
),
const SizedBox(
height: 20.0,
),
ElevatedButton(
style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
),
onPressed: () => controller.doCheckIn(),
child: const Text("Check In"),
),
const SizedBox(
height: 20.0,
),
ElevatedButton(
style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blueGrey,
),
onPressed: () => controller.doCheckOut(),
child: const Text("Check Out"),
),