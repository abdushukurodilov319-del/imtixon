class AppFailure {
  final String message;
  AppFailure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  NetworkFailure() : super('Internetga ulanishda xatolik yuz berdi.');
}

class AuthFailure extends AppFailure {
  AuthFailure(super.message);
}

class DatabaseFailure extends AppFailure {
  DatabaseFailure(super.message);
}
