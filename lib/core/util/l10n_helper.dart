import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

/// Helper seguro para obtener localizaciones.
/// Nunca devuelve null — cae a inglés si el contexto no tiene scope de i18n.
AppLocalizations l10n(BuildContext context) {
  return AppLocalizations.of(context);
}