 import 'dart:io';

import 'package:http/http.dart' as http;
 import 'dart:convert';

class HttpService {
  static String _baseUrl = "";
  static Map<String, String> _headers = {
    // "Authorization": "Api-Key 3751f40cb69dbbca4d9950fef6e034db34319be66a8efc8a4e14a5a043538610",
    // "Content-Type": "application/json"
  };
  
  static Future<T> get<T>(String route) async {
     http.Response res = await http.get("$_baseUrl$route", headers: _headers);

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "Can't get $_baseUrl$route";
    }
  }

  static Future<T> post<T>(String route, Map<String, dynamic> body) async {
     http.Response res = await http.post("$_baseUrl$route", 
                  headers: _headers,
                  body: jsonEncode(body));

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "Can't post $_baseUrl$route";
    }
  }

  static Future<T> put<T>(String route, Map<String, dynamic> body) async {
     http.Response res = await http.put("$_baseUrl$route", 
                  headers: _headers,
                  body: jsonEncode(body));

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "Can't put $_baseUrl$route";
    }
  }

  static Future<T> delete<T>(String route) async {
     http.Response res = await http.delete("$_baseUrl$route", 
                  headers: _headers);

    if (res.statusCode == 200) {
      T body = jsonDecode(res.body);
      return body;
    } else {
      throw "Can't delete $_baseUrl$route";
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