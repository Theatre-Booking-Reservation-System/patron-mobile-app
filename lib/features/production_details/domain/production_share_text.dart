String productionShareText({
  required String title,
  required String venue,
  required String synopsis,
  required String callToAction,
  String details = '',
}) {
  final lines = <String>[title.trim(), venue.trim()];
  final extra = details.trim();
  if (extra.isNotEmpty) lines.add(extra);
  final about = synopsis.trim();
  if (about.isNotEmpty) lines.add(about);
  final action = callToAction.trim();
  if (action.isNotEmpty) lines.add(action);
  return lines.where((line) => line.isNotEmpty).join('\n\n');
}
