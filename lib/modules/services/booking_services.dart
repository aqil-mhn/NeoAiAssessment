import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:neoai_assessment/commons/booking.dart';

class BookingService {
  Future<List<Booking>> getBookings() async {
    try {
      final String response = await rootBundle.loadString('assets/source/bookings.json');
      final List<dynamic> jsonData = json.decode(response);
      return jsonData.map((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  Future<void> saveBooking(Booking booking) async {
    try {
      // Load existing bookings
      final String response = await rootBundle.loadString('assets/source/bookings.json');
      final List<dynamic> jsonData = json.decode(response);
      final List<Booking> bookings = jsonData.map((data) => Booking.fromJson(data)).toList();
      
      // Add new booking
      bookings.add(booking);
      
      // Save back to file (Note: This is just for demonstration, in real app use proper storage)
      final String updatedJson = json.encode(bookings.map((b) => b.toJson()).toList());
      // In real app, implement proper file writing here
    } catch (e) {
      throw Exception('Failed to save booking: $e');
    }
  }
}