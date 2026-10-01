import 'dart:io';

import 'package:tas/sync/sync_log.dart';
import 'package:tas/sync/sync_server.dart';

/// Optional sync endpoint for Tas.
///
/// The app works fully offline when this process is not running.
/// There is no authentication. Bind it to localhost unless you trust the network.
Future<void> main(List<String> args) async {
  final host = _arg(args, '--host') ?? '127.0.0.1';
  final port = int.tryParse(_arg(args, '--port') ?? '') ?? 8787;
  final dataPath = _arg(args, '--data') ?? 'tas-sync.json';
  final file = File(dataPath);
  final log = await SyncLog.fromFile(file);
  final server = SyncServer(log, file: file);
  final uri = await server.start(host: host, port: port);
  stdout.writeln('Tas sync listening on $uri');
  stdout.writeln('Health: $uri/health');
  stdout.writeln('Data file: ${file.absolute.path}');
}

String? _arg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
