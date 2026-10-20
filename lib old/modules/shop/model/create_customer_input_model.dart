class CreateCustomerInput {
  final String name;
  final String email;

  CreateCustomerInput({required this.name, required this.email});

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }
}
