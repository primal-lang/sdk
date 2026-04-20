abstract class PlatformPathBase {
  String join(String a, String b);

  String dirname(String path);

  String basename(String path);

  String extension(String path);

  bool isAbsolute(String path);

  String normalize(String path);
}
