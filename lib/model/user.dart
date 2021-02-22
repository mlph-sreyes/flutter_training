class User {
  String id;
  String firstName;
  String lastName;
  String password;
  String username;
  String email;

  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.password,
      this.username,
      this.email});

  @override
  String toString() => firstName + " " + lastName;

  @override
  operator ==(o) => o is User && o.id == id;

  @override
  int get hashCode => id.hashCode ^ firstName.hashCode ^ id.hashCode;
}
