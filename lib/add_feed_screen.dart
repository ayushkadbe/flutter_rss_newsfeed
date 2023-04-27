import 'package:flutter/material.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

@override
State<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
final _formKey = GlobalKey<FormState>();

late String feedUrl;

void saveFeed() {
if (_formKey.currentState!.validate()) {
// Save the feed URL to local storage
// ...
Navigator.pop(context);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Add Custom Feed'),
),
body: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
TextFormField(
decoration: const InputDecoration(
labelText: 'Feed URL',
),
validator: (value) {
if (value == null || value.isEmpty) {
return 'Please enter a valid RSS feed URL';
}
return null;
},
onChanged: (value) {
feedUrl = value;
},
),
const SizedBox(height: 16.0),
ElevatedButton(
onPressed: () {
saveFeed();
},
child: const Text('Save'),
),
],
),
),
);
}
}
