import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:node_me/resources/hangout_service.dart';
import '../models/hangout_model.dart';
import '../resources/create_hangout_dialog.dart';

class HangoutsScreen extends StatefulWidget {
  const HangoutsScreen({super.key});

  @override
  State<HangoutsScreen> createState() => _HangoutsScreenState();
}

class _HangoutsScreenState extends State<HangoutsScreen> {
  late Future<List<HangoutModel>> hangouts;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    hangouts = HangoutService().getUserHangouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Hangouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CreateHangoutDialog(
                  onHangoutCreated: (id) {
                    setState(() {
                      hangouts = HangoutService().getUserHangouts();
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HangoutModel>>(
        future: hangouts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final list = snapshot.data!;
          if (list.isEmpty) {
            return const Center(child: Text("No hangouts yet."));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final hangout = list[index];

              return Card(
                margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
                child: ListTile(
                  title: Text(hangout.name),
                  subtitle: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(hangout.createdBy)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading...");
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text("Unknown creator");
                      }

                      final name = snapshot.data!.get('name') ?? "Unnamed";
                      return Text("Created by: $name");
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.group),
                    onPressed: () {
                      showMembersDialog(context, hangout, () {
                        setState(() {
                          hangouts = HangoutService().getUserHangouts();
                        });
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showMembersDialog(
    BuildContext context,
    HangoutModel hangout,
    VoidCallback refresh,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hangout Members"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: hangout.members.length,
            itemBuilder: (context, index) {
              final uid = hangout.members[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(title: Text("Unknown User ($uid)"));
                  }

                  final name = snapshot.data!.get('name') ?? 'Unnamed';

                  return ListTile(
                    title: Text(name),

                    trailing: uid != hangout.createdBy
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () async {
                              await HangoutService().removeMember(
                                hangoutId: hangout.id,
                                memberUid: uid,
                              );
                              Navigator.pop(context);
                              refresh();
                            },
                          )
                        : const Text("Owner"),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
