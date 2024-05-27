import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<CryptoHourlyData>> getCryptoHistory(String id) async {
  try {
    final String url =
        'https://api.coincap.io/v2/assets/$id/history?interval=h1';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body)['data'];
      List<CryptoHourlyData> data = parsed
          .map<CryptoHourlyData>((e) => CryptoHourlyData.fromJson(e))
          .toList();
      // filter out the data that is older than 24 hours
      data = data.where((element) {
        return element.time
            .isAfter(DateTime.now().subtract(const Duration(days: 1)));
      }).toList();
      return data;
    }
    return [];
  } catch (e) {
    print(e);
    return [];
  }
}

class CryptoHourlyData {
  final double priceUsd;
  final DateTime time;
  CryptoHourlyData({
    required this.priceUsd,
    required this.time,
  });
  factory CryptoHourlyData.fromJson(Map<String, dynamic> json) {
    return CryptoHourlyData(
      priceUsd: double.parse(json['priceUsd']),
      time: DateTime.fromMillisecondsSinceEpoch(json['time']),
    );
  }
  toJson() {
    return {
      'priceUsd': priceUsd,
      'time': time.millisecondsSinceEpoch,
    };
  }
}

String convertTimestampToTimeFormat(int timestamp) {
  // Create a DateTime object from the timestamp
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // Extract the hour
  int hour = dateTime.hour;

  // Determine whether it is AM or PM
  String period = hour >= 12 ? 'pm' : 'am';

  // Convert hour to 12-hour format
  if (hour == 0) {
    hour = 12; // Midnight case
  } else if (hour > 12) {
    hour -= 12;
  }

  // Return formatted time
  return '$hour $period';
}
