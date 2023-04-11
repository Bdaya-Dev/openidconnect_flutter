import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bdaya_openidconnect/openidconnect.dart';

class IdentityView extends StatelessWidget {
  final AuthorizationResponse identity;
  IdentityView(this.identity);

  @override
  Widget build(BuildContext context) {
    final parsed =
        identity is OpenIdIdentity ? identity as OpenIdIdentity : null;
    return Padding(
      padding: EdgeInsets.all(15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IdentityRow(
              title: "Access Token:",
              content: identity.accessToken,
            ),
            IdentityRow(
              title: "Identity Token:",
              content: identity.idToken,
            ),
            IdentityRow(
              title: "Token Type:",
              content: identity.tokenType,
            ),
            IdentityRow(
              title: "Expires At:",
              content: identity.expiresAt.toIso8601String(),
            ),
            IdentityRow(
              title: "Refresh Token:",
              content: identity.refreshToken,
            ),
            IdentityRow(
              title: "State:",
              content: identity.state,
            ),
            if (parsed is OpenIdIdentity) ...[
              IdentityRow(
                title: "Subject (or user id):",
                content: parsed.sub,
              ),
              IdentityRow(
                title: "userName:",
                content: parsed.userName,
              ),
              IdentityRow(
                title: "email:",
                content: parsed.email,
              ),
              IdentityRow(
                title: "givenName:",
                content: parsed.givenName,
              ),
              IdentityRow(
                title: "familyName:",
                content: parsed.familyName,
              ),
              IdentityRow(
                title: "fullName:",
                content: parsed.fullName,
              ),
              IdentityRow(
                title: "act:",
                content: parsed.act,
              ),
              IdentityRow(
                title: "claims:",
                content: parsed.claims.entries
                    .map((e) => '${e.key}=${e.value}')
                    .join(';'),
              ),
              IdentityRow(
                title: "roles:",
                content: parsed.roles.join(','),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class IdentityRow extends StatelessWidget {
  const IdentityRow({super.key, required this.title, this.content});
  final String title;
  final String? content;
  @override
  Widget build(BuildContext context) {
    final captionTheme = Theme.of(context).textTheme.bodySmall;
    return Row(
      children: [
        Text(
          title,
          softWrap: true,
          style: captionTheme,
        ),
        IconButton(
          onPressed: content == null
              ? null
              : () => Clipboard.setData(ClipboardData(text: content)),
          icon: Icon(Icons.copy),
        ),
        SelectableText(
          content ?? "Not Found",
        )
      ],
    );
  }
}
