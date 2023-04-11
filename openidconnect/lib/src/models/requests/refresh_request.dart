import 'package:bdaya_openidconnect/src/config/openidconfiguration.dart';
import 'token_request.dart';

class RefreshRequest extends TokenRequest {
  RefreshRequest({
    required String clientId,
    String? clientSecret,
    required Iterable<String> scopes,
    required String refreshToken,
    required OpenIdConfiguration configuration,
    Map<String, String>? additionalParameters,
    bool autoRefresh = true,
  }) : super(
            configuration: configuration,
            clientId: clientId,
            clientSecret: clientSecret,
            grantType: "refresh_token",
            scopes: scopes,
            additionalParameters: {
              "refresh_token": refreshToken,
              ...(additionalParameters ?? {})
            });
}
