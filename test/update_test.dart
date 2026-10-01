import 'package:flutter_test/flutter_test.dart';
import 'package:tas/update/app_update.dart';

void main() {
  test('version compare ignores a v prefix and build metadata', () {
    expect(compareVersions('1.2.0', '1.2.0'), 0);
    expect(compareVersions('1.2.0+3', 'v1.3.0'), lessThan(0));
    expect(compareVersions('1.10.0', '1.9.0'), greaterThan(0));
    expect(compareVersions('1.2', '1.2.1'), lessThan(0));
  });

  test('latest release is offered only when it is newer and keeps the apk', () {
    const body = '''
{"tag_name":"v1.3.0","html_url":"https://github.com/nktAkeyear/task_app/releases/tag/v1.3.0","assets":[{"name":"notes.txt","browser_download_url":"https://example.test/notes"},{"name":"tas-release.apk","browser_download_url":"https://example.test/tas.apk"}]}
''';
    final newer = parseLatestRelease(body, '1.2.0');
    expect(newer?.version, '1.3.0');
    expect(newer?.apkUrl, 'https://example.test/tas.apk');
    expect(parseLatestRelease(body, '1.3.0'), isNull);
    expect(parseLatestRelease(body, '2.0.0'), isNull);
  });
}
