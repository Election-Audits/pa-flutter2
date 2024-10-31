import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
// import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/core/utils/path.dart';

class XHttp {
  XHttp._internal();

  ///网络请求配置
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "https://www.wanandroid.com",
    connectTimeout: Duration(milliseconds: 5000),
    receiveTimeout: Duration(milliseconds: 3000),
  ));

  ///初始化dio
  static void init() {
    ///初始化cookie
    PathUtils.getDocumentsDirPath().then((value) {
      var cookieJar =
          PersistCookieJar(storage: FileStorage(value + "/.cookies/"));
      dio.interceptors.add(CookieManager(cookieJar));
    });

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      var client = HttpClient();

      client.findProxy = (uri) {
        // 设置代理服务器地址和端口号
        return "PROXY 192.168.2.8:8888";
      };
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };


    //添加拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
      print("请求之前");
      return handler.next(options);
    }, onResponse: (Response response, handler) {
      print("响应之前");
      return handler.next(response);
    }, onError: (DioException e, handler) {
      print("错误之前");
      handleError(e);
      return handler.next(e);
    }));
  }

  ///error统一处理
  static void handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print("连接超时");
        break;
      case DioExceptionType.sendTimeout:
        print("请求超时");
        break;
      case DioExceptionType.receiveTimeout:
        print("响应超时");
        break;
      case DioExceptionType.badResponse:
        print("出现异常");
        break;
      case DioExceptionType.cancel:
        print("请求取消");
        break;
      default:
        print("未知错误");
        break;
    }
  }

  ///get请求
  static Future get(String url, [Map<String, dynamic>? params]) async {
    Response response;
    if (params != null) {
      response = await dio.get(url, queryParameters: params);
    } else {
      response = await dio.get(url);
    }
    return response.data;
  }

  ///post 表单请求
  static Future post(String url, [Map<String, dynamic>? params]) async {
    Response response = await dio.post(url, queryParameters: params);
    debugPrint(response.data.toString());
    return response.data;
  }

  ///post body请求
  static Future postJson(String url, [Map<String, dynamic>? data]) async {
    Response response = await dio.post(url, data: data);
    return response.data;
  }

  ///下载文件
  static Future downloadFile(urlPath, savePath) async {
    late Response response;
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        print("$count $total");
      });
    } on DioException catch (e) {
      handleError(e);
    }
    return response.data;
  }
}
