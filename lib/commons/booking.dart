class Booking {
  final String guestName;
  final int roomNumber;
  final DateTime checkIn;
  final DateTime checkOut;
  final String status;

  Booking({
    required this.guestName,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      guestName: json['guest_name'],
      roomNumber: json['room_number'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: DateTime.parse(json['check_out']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'guest_name': guestName,
    'room_number': roomNumber,
    'check_in': checkIn.toIso8601String(),
    'check_out': checkOut.toIso8601String(),
    'status': status,
  };
}