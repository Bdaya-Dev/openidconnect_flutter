import 'dart:async';
import 'dart:convert';
//import 'dart:io';

import 'package:bdaya_openidconnect_platform_interface/openidconnect_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

Future<Map<String, dynamic>?> httpRetry<T extends http.Response>(
  FutureOr<T> Function() fn, {
  Duration delayFactor = const Duration(milliseconds: 200),
  double randomizationFactor = 0.25,
  Duration maxDelay = const Duration(seconds: 30),
  int maxAttempts = 8,
  FutureOr<bool> Function(Exception)? retryIf,
  FutureOr<void> Function(Exception)? onRetry,
}) async {
  var attempt = 1;
  while (true) {
    final options = RetryOptions(
      delayFactor: delayFactor,
      randomizationFactor: randomizationFactor,
      maxDelay: maxDelay,
      maxAttempts: maxAttempts,
    );

    var result = await options.retry(
      fn,
      retryIf:
          retryIf ?? (e) => e is http.ClientException || e is TimeoutException,
      onRetry: onRetry,
    );

    if (result.statusCode == 503 ||
        result.statusCode == 502 ||
        result.statusCode == 504) {
      if (attempt >= maxAttempts) {
        throw http.ClientException(
          "The server could not be reached. Please try again later.",
        );
      }
      await Future<void>.delayed(options.delay(attempt));
      attempt++;
      continue;
    }

    final body = result.body.isEmpty
        ? "{}"
        : result.body.startsWith("{")
            ? result.body
            : result.body.startsWith("<html")
                ? "{}"
                : "\{\"error\": \"${result.body.replaceAll("\"", "'")}\"\}";

    final jsonResponse = jsonDecode(body) as Map<String, dynamic>?;
    if (result.statusCode < 200 || result.statusCode >= 300) {
      if (jsonResponse!["error"] != null) {
        var error = jsonResponse["error"].toString();
        if (jsonResponse["error_description"] != null)
          error += ": ${jsonResponse["error_description"]}";
        throw HttpResponseException(
            ERROR_MESSAGE_FORMAT.replaceAll("%2", error));
      } else {
        throw HttpResponseException(
            ERROR_MESSAGE_FORMAT.replaceAll("%2", "unknown_error"));
      }
    }

    return result.body.isEmpty ? null : jsonResponse;
  }
}

Future<void> httpRetryNoResponse<T extends http.Response>(
  FutureOr<T> Function() fn, {
  Duration delayFactor = const Duration(milliseconds: 200),
  double randomizationFactor = 0.25,
  Duration maxDelay = const Duration(seconds: 30),
  int maxAttempts = 8,
  FutureOr<bool> Function(Exception)? retryIf,
  FutureOr<void> Function(Exception)? onRetry,
}) async {
  var attempt = 1;
  while (true) {
    final options = RetryOptions(
      delayFactor: delayFactor,
      randomizationFactor: randomizationFactor,
      maxDelay: maxDelay,
      maxAttempts: maxAttempts,
    );

    var result = await options.retry(
      fn,
      retryIf:
          retryIf ?? (e) => e is http.ClientException || e is TimeoutException,
      onRetry: onRetry,
    );

    if (result.statusCode == 503 ||
        result.statusCode == 502 ||
        result.statusCode == 504) {
      if (attempt >= maxAttempts) {
        throw http.ClientException(
          "The server could not be reached. Please try again later.",
        );
      }
      await Future<void>.delayed(options.delay(attempt));
      attempt++;
      continue;
    }

    final body = result.body;
    if (result.statusCode < 200 || result.statusCode >= 300) {
      result.body;
      if (body.isNotEmpty) {
        throw HttpResponseException(
            ERROR_MESSAGE_FORMAT.replaceAll("%2", body));
      } else {
        throw HttpResponseException(
            ERROR_MESSAGE_FORMAT.replaceAll("%2", "unknown_error"));
      }
    }
  }
}
