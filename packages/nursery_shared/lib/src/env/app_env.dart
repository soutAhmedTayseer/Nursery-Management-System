class AppEnv {
  const AppEnv._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nursery-management-api.runasp.net/api',
  );

  static const String name = String.fromEnvironment(
    'ENV_NAME',
    defaultValue: 'dev',
  );

  static bool get isProd => name == 'prod';
}
