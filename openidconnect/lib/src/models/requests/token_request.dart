import 'package:bdaya_openidconnect/src/config/openidconfiguration.dart';
import 'package:flutter/widgets.dart';

abstract class TokenRequest {
  final String clientId;
  final String? clientSecret;

  final String grantType;
  final Iterable<String> scopes;
  final Map<String, String>? additionalParameters;
  final Iterable<String>? prompts;
  final OpenIdConfiguration configuration;

  const TokenRequest({
    required this.clientId,
    this.clientSecret,
    required this.scopes,
    required this.grantType,
    this.additionalParameters,
    this.prompts,
    required this.configuration,
  });

  @mustCallSuper
  Map<String, String> toMap() {
    var map = {
      "client_id": clientId,
      "grant_type": grantType,
      "scope": scopes.join(" "),
      if (prompts != null && prompts!.isNotEmpty) 'prompt': prompts!.join(' '),
      if (clientSecret != null) "client_secret": clientSecret!,
      if (additionalParameters != null) ...additionalParameters!
    };

    return map;
  }
}
