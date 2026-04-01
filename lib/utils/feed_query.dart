import '../models/experience.dart';

List<Experience> filterExperiencesBySearch(
  List<Experience> experiences,
  String query,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return List<Experience>.from(experiences);
  }
  return experiences
      .where(
        (e) =>
            e.title.toLowerCase().contains(q) ||
            e.body.toLowerCase().contains(q),
      )
      .toList();
}

List<Experience> sortExperiencesByDate(
  List<Experience> experiences, {
  required bool newestFirst,
}) {
  final out = List<Experience>.from(experiences);
  out.sort((Experience a, Experience b) {
    final c = a.createdAt.compareTo(b.createdAt);
    return newestFirst ? -c : c;
  });
  return out;
}
