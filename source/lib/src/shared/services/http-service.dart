 import 'dart:io';

import 'package:http/http.dart' as http;
 import 'dart:convert';

class HttpService {
  static Map<String, String> _headers = {
    "x-api-key": "3e105a18a1f64eadaab010c9d630fb26",
    "Content-Type": "application/json"
  };
  
  static Future<T> get<T>(String route) async {
     http.Response res = await http.get("$route", headers: _headers);

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "No records found";
    }
  }

  static Future<T> post<T>(String route, Map<String, dynamic> body) async {
     http.Response res = await http.post("$route", 
                  headers: _headers,
                  body: jsonEncode(body));

    if (res.statusCode == 200) {
      T resBody = jsonDecode(res.body);
      return resBody;
    } else {
      throw "Unable to process your request";
    }
  }

  static Future<T> put<T>(String route, Map<String, dynamic> body) async {
     http.Response res = await http.put("$route", 
                  headers: _headers,
                  body: jsonEncode(body));

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "Unable to process your request";
    }
  }

  static Future<T> delete<T>(String route) async {
     http.Response res = await http.delete("$route", 
                  headers: _headers);

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "Unable to process your request";
    }
  }
}

class AppHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}