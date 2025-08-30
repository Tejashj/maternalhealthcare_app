import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maternalhealthcare/config/constants.dart';

class AppwriteClient {
  AppwriteClient._();
  static final AppwriteClient instance = AppwriteClient._();

  final String endpoint = AppwriteConstants.endpoint;
  final String projectId =
      dotenv.env['APPWRITE_PROJECT_ID'] ?? 'DEFAULT_PROJECT_ID';

  final Client _client = Client();

  late final Account account;
  late final Databases databases;

  void init() {
    _client
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true);

    account = Account(_client);
    databases = Databases(_client);
  }
}
