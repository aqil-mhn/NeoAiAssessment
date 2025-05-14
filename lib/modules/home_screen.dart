import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neoai_assessment/commons/booking.dart';
import 'package:neoai_assessment/commons/string_casing.dart';
import 'package:neoai_assessment/configs/context_extensions.dart';
import 'package:neoai_assessment/modules/logins/login_screen.dart';
import 'package:neoai_assessment/modules/screens/profile_screen.dart';
import 'package:neoai_assessment/modules/services/booking_services.dart';
import 'package:neoai_assessment/modules/services/firebase_auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<String> _statusSelected = ValueNotifier<String>('');
  final ValueNotifier<List<Booking>> _bookings = ValueNotifier<List<Booking>>([]);
  final ValueNotifier<List<Booking>> _filteredBookings = ValueNotifier<List<Booking>>([]);
  FirebaseAuthServices auth = FirebaseAuthServices();
  TextEditingController searchController = TextEditingController();

  final BookingService _bookingService = BookingService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  List<Map<String, dynamic>> recipes = [];
  List<DropdownMenuItem> categories = [];

  String filterSelected = '';
  @override
  void initState() {
    super.initState();
    
    init();
  }

  Future<void> loadBookings() async {
    try {
      final bookings = await _bookingService.getBookings();
      _bookings.value = bookings;
      _filteredBookings.value = bookings;
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  void init() async {
    _isLoading.value = true;
    try {
      await loadBookings();
    } catch (e) {
      log("Load Bookings Error >>> ${e.toString()}");
    } finally {
      _isLoading.value = false;
    }
  }

  void searchBookings(String query) {
    if (query.isEmpty) {
      _filteredBookings.value = List.from(_bookings.value);
    } else {
      _filteredBookings.value = _bookings.value
          .where((booking) => 
              booking.guestName.toLowerCase().contains(query.toLowerCase()) ||
              booking.roomNumber.toString().contains(query))
          .toList();
    }
  }

  void filterByStatus(String status) {
    if (status.isEmpty) {
      _filteredBookings.value = List.from(_bookings.value);
    } else {
      _filteredBookings.value = _bookings.value
          .where((booking) => booking.status.toLowerCase() == status.toLowerCase())
          .toList();
    }
  }

  Future<void> handleSignOut() async {
    auth.signOut();

    var prefs = await SharedPreferences.getInstance();
    prefs.remove("isUserLoggedIn");
    prefs.remove("userUID");

    // Remove all routes and navigate to LoginScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false, // This removes all routes from the stack
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 243, 241),
      drawer: Drawer(
        elevation: 4,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: UserAccountsDrawerHeader(
                    arrowColor: Colors.white,
                    otherAccountsPictures: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        tooltip: 'Close drawer',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 98, 124, 119),
                        ),
                      ),
                    ],
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 98, 124, 119),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: const Color.fromARGB(255, 98, 124, 119),
                      ),
                    ),
                    accountName: ListenableBuilder(
                      listenable: context.firebaseProvider,
                      builder: (context, child) {
                        return Text(
                          context.firebaseProvider.userName ?? 'User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                    accountEmail: Text(
                      context.firebaseProvider.currentUser!.email ?? 'No email',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(right: 8, top: 8),
                //   alignment: Alignment.topRight,
                //   child: IconButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //     icon: Icon(
                //       Icons.arrow_back,
                //       color: Colors.white,
                //     ),
                //     tooltip: 'Close drawer',
                //     style: IconButton.styleFrom(
                //       backgroundColor: const Color.fromARGB(255, 98, 124, 119),
                //     ),
                //   ),
                // )
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  // ListTile(
                  //   leading: Icon(Icons.home),
                  //   title: Text('Home'),
                  //   onTap: () {
                  //     Navigator.pop(context); // Close drawer
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.book),
                    title: Text('Bookings'),
                    onTap: () {
                      context.showOverlaySnackBar(context, "Under Developement");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.room),
                    title: Text('Rooms'),
                    onTap: () {
                      context.showOverlaySnackBar(context, "Under Developement");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.group),
                    title: Text('Guests'),
                    onTap: () {
                      context.showOverlaySnackBar(context, "Under Developement");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.badge),
                    title: Text('Staff'),
                    onTap: () {
                      context.showOverlaySnackBar(context, "Under Developement");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Setting'),
                    onTap: () {
                      context.showOverlaySnackBar(context, "Under Developement");
                    },
                  ),
                  // ListTile(
                  //   leading: Icon(Icons.add),
                  //   title: Text('Add Recipe'),
                  //   onTap: () {
                  //     Navigator.pop(context); // Close drawer
                  //     Navigator.of(context).push(
                  //       MaterialPageRoute(
                  //         builder: (context) => RecipeFormScreen(
                  //           isUpdate: false,
                  //           data: {},
                  //         ),
                  //       ),
                  //     ).then((value) {
                  //       if (value == true) {
                  //         initLDB();
                  //       }
                  //     });
                  //   },
                  // ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onTap: () {
                handleSignOut();
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Bookings',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 98, 124, 119),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          if (value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color.fromARGB(255, 98, 124, 119),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Downloading recipes"
                  )
                ],
              ),
            );
          }
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: searchBookings,
                ),
              ),

              // Status Filter
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          _statusSelected.value = '';
                          filterByStatus('');
                  
                          setState(() {
                            filterSelected = '';
                          });
                        },
                        icon: Icon(
                          Icons.close
                        ),
                      ),
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: filterSelected == '' ? null : filterSelected,
                    items: ['Confirmed', 'Pending', 'Cancelled']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _statusSelected.value = value ?? '';
                      filterByStatus(value ?? '');
                  
                      setState(() {
                        filterSelected = value ?? '';
                      });
                    },
                  ),
                ),
              ),

              // Bookings List
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _filteredBookings,
                  builder: (context, bookings, child) {
                    if (_isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    
                    if (bookings.isEmpty) {
                      return Center(child: Text('No bookings found'));
                    }

                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      booking.guestName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(booking.status),
                                      backgroundColor: _getStatusColor(booking.status),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.hotel, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('Room ${booking.roomNumber}'),
                                  ],
                                ),
                                SizedBox(height: 4),
                                if (booking.checkIn != null && booking.checkOut != null) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              'Check-in: ${DateFormat('dd MMM yyyy').format(booking.checkIn!)}',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text(
                                              'Check-out: ${DateFormat('dd MMM yyyy').format(booking.checkOut!)}',
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      )
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}