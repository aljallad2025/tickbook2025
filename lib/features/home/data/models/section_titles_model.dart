class SectionTitlesModel {
  final int id;
  final String languageId;
  final String eventSectionTitle;
  final String categorySectionTitle;
  final String featuredInstructorsSectionTitle;
  final String testimonialsSectionTitle;
  final String featuresSectionTitle;
  final String blogSectionTitle;

  SectionTitlesModel({
    required this.id,
    required this.languageId,
    required this.eventSectionTitle,
    required this.categorySectionTitle,
    required this.featuredInstructorsSectionTitle,
    required this.testimonialsSectionTitle,
    required this.featuresSectionTitle,
    required this.blogSectionTitle,
  });

  factory SectionTitlesModel.fromJson(Map<String, dynamic> json) =>
      SectionTitlesModel(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        languageId: json['language_id'].toString(),
        eventSectionTitle: json['features_title'] ?? '',
        categorySectionTitle: json['category_title'] ?? '',
        featuredInstructorsSectionTitle:
            json['featured_instructors_section_title'] ?? '',
        testimonialsSectionTitle: json['testimonials_section_title'] ?? '',
        featuresSectionTitle: json['upcoming_event_title'] ?? '',
        blogSectionTitle: json['blog_section_title'] ?? '',
      );
}
