class Employee {
  final String id;
  final String name;
  final String companyName;
  final String designation;
  final String phone;
  final String address;
  final String imageBase64;
  final DateTime? createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.companyName,
    required this.designation,
    required this.phone,
    required this.address,
    required this.imageBase64,
    this.createdAt,
  });

  factory Employee.fromMap(Map<String, dynamic> map, String id) {
    return Employee(
      id: id,
      name: map['name'] ?? '',
      companyName: map['companyName'] ?? '',
      designation: map['designation'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      imageBase64: map['imageBase64'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'companyName': companyName,
      'designation': designation,
      'phone': phone,
      'address': address,
      'imageBase64': imageBase64,
      'createdAt': createdAt,
    };
  }
}