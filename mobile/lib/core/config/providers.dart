import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../router/app_router.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter(ref: ref);
});
