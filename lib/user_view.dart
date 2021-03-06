import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserView extends StatefulWidget {
  const UserView({Key? key}) : super(key: key);

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _users;
  late Stream<QuerySnapshot<Object?>> _userStream;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  Future<void> _addUser({String? name, String? age}) async {
    Map<String, dynamic> _data = {
      "Name": name,
      "Age": age,
    };
    await _users.add(_data).then((value) {
      debugPrint("Value added with ID : ${value.id}");
    }).then((error) {
      debugPrint("$error");
    });
  }

  Future<void> _updateUser({
    String? name,
    String? age,
    String? path,
  }) async {
    await _users.doc(path).update({"Name": name, "Age": age}).then((value) {
      debugPrint("User updated");
    }).then((error) {
      debugPrint("$error");
    });
  }

  Future<void> _deleteUser(String path) async {
    await _users.doc(path).delete().then((value) {
      debugPrint("User deleted");
    }).then((error) {
      debugPrint("$error");
    });
  }

  //One time read
  void _getUsersOneTime() async {
    _users.get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        debugPrint(data.toString());
      }
    });
  }

  @override
  void initState() {
    _users = _firestore.collection("Rasta");
    _getUsersOneTime();
    _userStream = _users.snapshots();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kWidth = SizedBox(width: 10);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Users"),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5)),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: "Name",
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    )),
                Container(
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5)),
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        hintText: "Age",
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.isEmpty ||
                            _ageController.text.isEmpty) {
                          SnackBar snackBar = const SnackBar(
                              content: Text("Name & Age cannot be empty"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          await _addUser(
                                  age: _ageController.text,
                                  name: _nameController.text)
                              .then((value) {
                            _nameController.clear();
                            _ageController.clear();
                          });
                        }
                      },
                      child: const Text("Add User")),
                )
              ],
            ),
            Expanded(
                //Real Time Changes with Stream Builder
                //Both the CollectionReference & DocumentReference provide a snapshots() method which returns a Stream:
                child: StreamBuilder<QuerySnapshot>(
                    stream: _userStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = snapshot.data!.docs
                              .elementAt(index)
                              .data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text("${index + 1}"),
                                    ),
                                    kWidth,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text("Name"),
                                        Text("Age"),
                                      ],
                                    ),
                                    kWidth,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(":"),
                                        Text(":"),
                                      ],
                                    ),
                                    kWidth,
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(data["Name"]),
                                        Text(data["Age"]),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) {
                                              return EditPage(
                                                name: data["Name"],
                                                age: data["Age"],
                                                path: snapshot.data!.docs
                                                    .elementAt(index)
                                                    .id,
                                                updateUser: _updateUser,
                                              );
                                            },
                                          ));
                                        },
                                        icon: Icon(Icons.edit,
                                            color: Colors.grey.shade700)),
                                    IconButton(
                                        onPressed: () {
                                          _deleteUser(snapshot.data!.docs
                                              .elementAt(index)
                                              .id);
                                        },
                                        icon: Icon(Icons.delete,
                                            color: Colors.grey.shade700)),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }))
          ],
        ),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final String? name;
  final String? age;
  final String? path;
  final Future<void> Function({String name, String age, String path})?
      updateUser;
  const EditPage({Key? key, this.name, this.age, this.path, this.updateUser})
      : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.name!;
    _ageController.text = widget.age!;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update User"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    hintText: "Name",
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )),
            Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    hintText: "Age",
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty ||
                        _ageController.text.isEmpty) {
                      SnackBar snackBar = const SnackBar(
                          content: Text("Name & Age cannot be empty"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      widget.updateUser!(
                              name: _nameController.text,
                              age: _ageController.text,
                              path: widget.path!)
                          .then((value) => Navigator.of(context).pop());
                    }
                  },
                  child: const Text("Update User")),
            )
          ],
        ));
  }
}
