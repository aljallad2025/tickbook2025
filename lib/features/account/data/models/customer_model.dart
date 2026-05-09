class CustomerModel {
  final int? id;
  final String? fname;
  final String? lname;
  final String? email;
  final String? username;
  final String? photo;
  final String? phone;
  final String? address;
  final String? country;
  final String? state;
  final String? city;
  final String? zipCode;

  CustomerModel({
    this.id,
    this.fname,
    this.lname,
    this.email,
    this.username,
    this.photo,
    this.phone,
    this.address,
    this.country,
    this.state,
    this.city,
    this.zipCode,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      fname: json['fname']?.toString(),
      lname: json['lname']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      photo: json['photo']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      zipCode: json['zip_code']?.toString() ?? json['zipCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fname': fname ?? '',
      'lname': lname ?? '',
      'email': email ?? '',
      'username': username ?? '',
      'photo': photo ?? '',
      'phone': phone ?? '',
      'address': address ?? '',
      'country': country ?? '',
      'state': state ?? '',
      'city': city ?? '',
      'zip_code': zipCode ?? '',
    };
  }

  /// Returns a map of form fields suitable for multipart form-data submission.
  Map<String, String> toFormFields() {
    final map = <String, String>{};
    map['fname'] = fname ?? '';
    map['lname'] = lname ?? '';
    map['email'] = email ?? '';
    map['username'] = username ?? '';
    map['photo'] = photo ?? '';
    map['phone'] = phone ?? '';
    map['address'] = address ?? '';
    map['country'] = country ?? '';
    map['state'] = state ?? '';
    map['city'] = city ?? '';
    map['zip_code'] = zipCode ?? '';
    return map;
  }

  CustomerModel copyWith({
    int? id,
    String? fname,
    String? lname,
    String? email,
    String? username,
    String? photo,
    String? phone,
    String? address,
    String? country,
    String? state,
    String? city,
    String? zipCode,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      email: email ?? this.email,
      username: username ?? this.username,
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
    );
  }
}
