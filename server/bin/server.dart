import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_static/shelf_static.dart';
import 'package:path/path.dart';
import 'package:shelf_router/shelf_router.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
const _hostname = 'localhost';
var notes = <String>[];

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  // For Google Cloud Run, we respect the PORT environment variable
  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    // 64: command line usage error
    exitCode = 64;
    return;
  }

  var directory = Directory('note').list(recursive: true, followLinks: false);
  await for (var entity in directory) {
    if (await FileSystemEntity.isFile(entity.path) &&
        entity.path.endsWith('.md')) {
      notes.add(entity.path.substring(5, entity.path.length - 3));
    }
  }

  var app = Router();
  app.get('/api/get_notes', _echoRequest);
  app.get('/note/assets/<pic_name>',
      (shelf.Request req, String pic_name) async {
    return shelf.Response.ok(File('note/assets/$pic_name').openRead(),
        headers: {'content-type': 'image/png'});
  });
  app.get('/api/get_<note>', (shelf.Request req, String note) {
    //return shelf.Response.ok('note/$note.md');
    var decodeData = Uri.decodeFull(note);
    
    var content  = File('note/$decodeData.md').readAsStringSync();
    var jsonData = <String,String>{'content':content};
    return shelf.Response.ok(jsonEncode(jsonData),
        headers: {'content-type': 'application/json; charset=utf-8'});
    
  });

  var indexHandler =
      createStaticHandler('../web', defaultDocument: 'index.html');

  var handler = shelf.Cascade().add(indexHandler).add(app.handler).handler;

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
  server.defaultResponseHeaders.add('Access-Control-Allow-Origin', '*');
  server.defaultResponseHeaders.add('Access-Control-Allow-Credentials', true);
}

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  if (request.method == 'GET') {
    var jsonData = <String, List<String>>{'note_list': notes};
    return shelf.Response.ok(jsonEncode(jsonData),
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
  return shelf.Response.notFound('404 not found');
}
