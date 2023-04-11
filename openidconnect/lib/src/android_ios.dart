import 'dart:math';

import 'package:async/async.dart';
import 'package:bdaya_openidconnect_platform_interface/openidconnect_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as flutterWebView;

class OpenIdConnectAndroidiOS extends OpenIdConnectPlatform {
  static void registerWith() {
    OpenIdConnectPlatform.instance = OpenIdConnectAndroidiOS();
  }

  @override
  Future<String> authorizeInteractive({
    required BuildContext context,
    required String title,
    required String authorizationUrl,
    required String redirectUrl,
    required int popupWidth,
    required int popupHeight,
    bool? useWebRedirectLoop,
  }) async {
    //Create the url

    final memo = AsyncMemoizer<flutterWebView.WebViewController>();
    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future<flutterWebView.WebViewController> _init() async {
          final controller = flutterWebView.WebViewController();

          await controller
              .setJavaScriptMode(flutterWebView.JavaScriptMode.unrestricted);
          await controller.setNavigationDelegate(
            flutterWebView.NavigationDelegate(
              onPageFinished: (url) {
                if (url.startsWith(redirectUrl)) {
                  Navigator.pop(dialogContext, url);
                }
              },
            ),
          );
          await controller.loadRequest(Uri.parse(authorizationUrl));
          return controller;
        }

        return AlertDialog(
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              icon: Icon(Icons.close),
            ),
          ],
          content: FutureBuilder<flutterWebView.WebViewController>(
            future: memo.runOnce(_init),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              final data = snapshot.data;
              if (data == null) {
                return Center(child: CircularProgressIndicator.adaptive());
              }
              return Container(
                width: min(
                  popupWidth.toDouble(),
                  MediaQuery.of(context).size.width,
                ),
                height: min(
                  popupHeight.toDouble(),
                  MediaQuery.of(context).size.height,
                ),
                child: flutterWebView.WebViewWidget(
                  controller: data,
                ),
              );
            },
          ),
          title: Text(title),
        );
      },
    );

    if (result == null) throw AuthenticationException(ERROR_USER_CLOSED);

    return result;
  }

  @override
  Future<String?> processStartup() => Future.value(null);
}
