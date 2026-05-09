class HeroSectionModel {
  final int id;
  final String languageId;
  final String backgroundImage;
  final String firstTitle;
  final String secondTitle;
  final String firstButton;
  final String firstButtonUrl;
  final String secondButton;
  final String secondButtonUrl;

  HeroSectionModel({
    required this.id,
    required this.languageId,
    required this.backgroundImage,
    required this.firstTitle,
    required this.secondTitle,
    required this.firstButton,
    required this.firstButtonUrl,
    required this.secondButton,
    required this.secondButtonUrl,
  });

  factory HeroSectionModel.fromJson(Map<String, dynamic> json) => HeroSectionModel(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        languageId: json['language_id'].toString(),
        backgroundImage: json['background_image'] ?? '',
        firstTitle: json['first_title'] ?? '',
        secondTitle: json['second_title'] ?? '',
        firstButton: json['first_button'] ?? '',
        firstButtonUrl: json['first_button_url'] ?? '',
        secondButton: json['second_button'] ?? '',
        secondButtonUrl: json['second_button_url'] ?? '',
      );
}
