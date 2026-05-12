import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'FINNHUB_API_KEY', obfuscate: true)
  static final String finnhubApiKey = _Env.finnhubApiKey;
}
