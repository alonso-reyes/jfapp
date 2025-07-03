import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:mime/mime.dart';
import 'dart:developer' as dev;

// import '../helpers/nav_context.dart';
// import '../helpers/preference_provider.dart';
// import '../router/routes_names.dart';
/*
class ApiCallBuilder {
  late String _action;
  late Map<String, dynamic> _params;
  dynamic _dataModel;
  BuildContext _buildContext;

  ApiCallBuilder(this._buildContext);

  String get action => _action;
  set action(String newAction) {
    _action = newAction;
  }

  BuildContext get buildContext => _buildContext;
  set buildContext(BuildContext newbuildContext) {
    _buildContext = newbuildContext;
  }

  dynamic get dataModel => _dataModel;
  set dataModel(dynamic newdataModel) {
    _dataModel = newdataModel;
  }

  Map<String, dynamic> get params => _params;
  set params(Map<String, dynamic> newParams) {
    _params = newParams;
  }

  ApiCall build() {
    return ApiCall(this);
  }
}



class ApiCall {
  dynamic _action;
  dynamic _dataModel;
  late BuildContext _buildContext;
  late Map<String, dynamic> _params;

  ApiCall(ApiCallBuilder builder) {
    _action = builder.action;
    _dataModel = builder.dataModel;
    _params = builder.params;
    _buildContext = builder._buildContext;
  }

  dynamic get dataModel => _dataModel;
  Map<String, dynamic> get params => _params;
  dynamic get action => setData(_action, _params);

  Future _apiCall(Map<String, dynamic> params, String action) async {
    Map<String, dynamic> apiParams = {...params};
    apiParams['key'] = dotenv.env['KEY'] ?? "";
    apiParams['action'] = action;
    try {
      var url = Uri();
      var response = await http.post(url, body: params);

      if (kReleaseMode) {
        url = Uri.https(dotenv.env['URL_API'] ?? "");
      } else {
        if (dotenv.env['URL_API'] == "http://192.168.0.187/apispalive/") {
          url = Uri.parse(dotenv.env['URL_API'] ?? "");
        } else {
          url = Uri.https(dotenv.env['URL_API'] ?? "");
        }
      }

      //var url = Uri.https(dotenv.env['URL_API'] ?? "");
      bool isValidationSession =
          (apiParams.containsKey('alive') && apiParams['alive']) ? true : false;
      apiParams.remove('context');
      apiParams.remove('alive');

      var response = await http.post(url, body: apiParams);
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (isValidationSession) {
          return res;
        } else {
          if (res['session'] == false) {
            PreferenceProvider.user = '';
            if (buildContext.mounted) {
              NavContext.navigatorKey.currentContext!.goNamed(RouteName.login);
              // showSnackBar(
              //     buildContext, 'Session closed. Sign out and log in again.');
              return null;
            }
          }
          return res;
        }
      } else {
        return 'Server error.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map?> _apiCallWithFiles(Map<String, dynamic> params, String action,
      List<Map<String, dynamic>> files) async {
    var url = Uri();

    if (kReleaseMode) {
      url = Uri.https(dotenv.env['URL_API'] ?? "");
    } else {
      if (dotenv.env['URL_API'] == "http://192.168.0.187/apispalive/") {
        url = Uri.parse(dotenv.env['URL_API'] ?? "");
      } else {
        url = Uri.https(dotenv.env['URL_API'] ?? "");
      }
    }

    var response;
    for (Map<String, dynamic> fileMap in files) {
      var request = http.MultipartRequest("POST", url);
      params['key'] = dotenv.env['KEY'] ?? "";
      params['action'] = action;
      params.forEach((key, value) {
        request.fields[key] = value;
      });

      XFile? crossFile = fileMap['file'];
      if (crossFile == null) {
        continue;
      }
      http.MultipartFile file;
      String? mimeType =
          lookupMimeType(crossFile.path, headerBytes: [0xFF, 0xD8]);
      String fileExt = 'stub';
      if (mimeType == null) {
        fileExt = 'stub';
      } else {
        fileExt = extensionFromMime(fileExt);
      }
      dev.log('File mimetype/extension: $mimeType -> $fileExt');
      /*file = await http.MultipartFile.fromPath(
            "${fileMap['key']}", crossFile.path,
            filename: /*crossFile.name*/ '${DateTime.now().millisecondsSinceEpoch}.stub',
            contentType: MediaType.parse(mime ?? ''));*/
      Uint8List fileBytes = await crossFile.readAsBytes();
      file = http.MultipartFile.fromBytes("${fileMap['key']}", fileBytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}.$fileExt',
          contentType: mimeType == null
              ? null
              : MediaType(mimeType.split('/').first, mimeType.split('/').last));

      request.files.add(file);

      try {
        response = await request.send();
      } catch (e) {
        throw 'Server error.';
      }
    }
    if (response.statusCode == 200) {
      dev.log(response.toString());
      var responseData = await response.stream.toBytes();
      dev.log(String.fromCharCodes(responseData));
      return jsonDecode(String.fromCharCodes(responseData));
    } else {
      throw 'Server error.';
    }
  }

  Future<Map?> _apiCallWithFile(
      Map<String, dynamic> params, String action, XFile file) async {
    var url = Uri();

    if (kReleaseMode) {
      url = Uri.https(dotenv.env['URL_API'] ?? "");
    } else {
      if (dotenv.env['URL_API'] == "http://192.168.0.187/apispalive/") {
        url = Uri.parse(dotenv.env['URL_API'] ?? "");
      } else {
        url = Uri.https(dotenv.env['URL_API'] ?? "");
      }
    }

    var request = http.MultipartRequest("POST", url);
    params['key'] = dotenv.env['KEY'] ?? "";
    params['action'] = action;
    params.forEach((key, value) {
      request.fields[key] = value;
    });
    XFile fileCopy = file;
    String fileExt = 'stub';

    http.MultipartFile multiFile;
    String? mimeType = lookupMimeType(fileCopy.path, headerBytes: [0xFF, 0xD8]);
    if (mimeType == null) {
      fileExt = 'stub';
    } else {
      fileExt = extensionFromMime(fileExt);
    }
    dev.log('File mimetype/extension: $mimeType -> $fileExt');
    /*file = await http.MultipartFile.fromPath(
          "${fileMap['key']}", crossFile.path,
          filename: /*crossFile.name*/ '${DateTime.now().millisecondsSinceEpoch}.stub',
          contentType: MediaType.parse(mime ?? ''));*/
    Uint8List fileBytes = await fileCopy.readAsBytes();
    multiFile = http.MultipartFile.fromBytes('file', fileBytes,
        filename: '${DateTime.now().millisecondsSinceEpoch}.$fileExt',
        contentType: mimeType == null
            ? null
            : MediaType(mimeType.split('/').first, mimeType.split('/').last));

    request.files.add(multiFile);

    var response;
    try {
      response = await request.send();
    } catch (e) {
      throw 'Server error.';
    }

    if (response.statusCode == 200) {
      dev.log(response.toString());
      var responseData = await response.stream.toBytes();
      dev.log(String.fromCharCodes(responseData));
      return jsonDecode(String.fromCharCodes(responseData));
    } else {
      throw 'Server error.';
    }
  }

  dynamic setData(String action, Map<String, dynamic> params) async {
    final res = await _apiCall(params, action);
    if (res != null) {
      try {
        if (!res['success']) {
          return res['messages'] != null
              ? res['messages']?.first == 'Invalid token.'
                  ? 'Error: Session closed. Sign out and log in again.'
                  : res['messages']?.first
              : 'Server error.';
        } else {
          return res;
        }
      } catch (e) {
        if (e is Map && e.containsKey('messages')) {
          return e['messages'];
        } else {
          return e.toString();
        }
      }
    }
  }

  dynamic setDataFile(
      String action, Map<String, dynamic> params, XFile file) async {
    final res = await _apiCallWithFile(params, action, file);
    if (res != null) {
      try {
        if (!res['success']) {
          return res['messages'] != null
              ? res['messages']?.first == 'Invalid token.'
                  ? 'Error: Session closed. Sign out and log in again.'
                  : res['messages']?.first
              : 'Server error.';
        } else {
          return res;
        }
      } catch (e) {
        if (e is Map && e.containsKey('messages')) {
          return e['messages'];
        } else {
          return e.toString();
        }
      }
    }
  }

  dynamic setDataFiles(String action, Map<String, dynamic> params,
      List<Map<String, dynamic>> files) async {
    final res = await _apiCallWithFiles(params, action, files);
    try {
      if (!res!['success']) {
        return res['messages'] != null
            ? res['messages']?.first == 'Invalid token.'
                ? 'Error: Session closed. Sign out and log in again.'
                : res['messages']?.first
            : 'Server error.';
      } else {
        return res;
      }
    } catch (e) {
      if (e is Map && e.containsKey('messages')) {
        return e['messages'];
      } else {
        return e.toString();
      }
    }
  }
}
*/
