import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  // Fetch notifications from Firestore
  Stream<List<Map<String, dynamic>>> fetchNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Stream.value([]); // Return empty stream if no user is logged in
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['id'] = doc.id; // Add document ID to the data
              return data;
            }).toList());
  }

  // Mark notification as read in Firestore
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Open notification details screen when a notification is tapped
  void openNotification(BuildContext context, String userId, Map<String, dynamic> notification) async {
    if (notification['read'] == false) {
      await markNotificationAsRead(userId, notification['id']); // Mark as read
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(notification: notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No notifications available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification['read'] ?? false;

              // Extract relevant fields from the notification
              final amount = notification['amount'] ?? 'Unknown amount';
              final txRef = notification['tx_ref'] ?? 'No reference';
              final status = notification['status'] ?? 'Unknown status';
              final timestamp = (notification['timestamp'] as Timestamp).toDate();

              return Column(
                children: [
                  ListTile(
                    title: Text(
                      'Amount: $amount',
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reference: $txRef'),
                        Text('Status: $status'),
                        Text('Date: ${timestamp.toLocal()}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Icon(
                      isRead ? Icons.check_circle : Icons.notifications_active,
                      color: isRead ? Colors.green : Colors.red,
                    ),
                    onTap: () => openNotification(context, userId!, notification),
                  ),
                  Divider(), // <--- Added divider between notifications
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Extract notification details
    final amount = notification['amount'] ?? 'Unknown amount';
    final txRef = notification['tx_ref'] ?? 'No reference';
    final status = notification['status'] ?? 'Unknown status';
    final timestamp = (notification['timestamp'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Amount: $amount', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Reference: $txRef', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Status: $status', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              'Date: ${timestamp.toLocal()}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
