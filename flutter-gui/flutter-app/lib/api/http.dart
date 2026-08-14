// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html';

import 'base.dart';

TicTacToeApi createTicTacToeApi({String? libraryPath, Uri? serverUri}) {
  const configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  return HttpTicTacToeApi(
    serverUri:
        serverUri ??
        (configuredApiBaseUrl.isEmpty
            ? Uri.base.resolve('/api/')
            : Uri.parse(configuredApiBaseUrl)),
  );
}

class HttpTicTacToeApi implements TicTacToeApi {
  HttpTicTacToeApi({required this.serverUri});

  final Uri serverUri;

  @override
  Future<Object> newGame(int humanMarkCode) async {
    final response = await _requestJson(
      'POST',
      ['games'],
      body: {'humanMark': humanMarkCode},
    );
    return response['gameId'] as int;
  }

  @override
  Future<void> freeGame(Object handle) async {
    await _requestJson('DELETE', ['games', _gameId(handle).toString()]);
  }

  @override
  Future<int> currentPlayer(Object handle) async {
    final response = await _requestJson('GET', [
      'games',
      _gameId(handle).toString(),
      'current-player',
    ]);
    return response['value'] as int;
  }

  @override
  Future<int> cellAt(Object handle, int index) async {
    final response = await _requestJson('GET', [
      'games',
      _gameId(handle).toString(),
      'cells',
      index.toString(),
    ]);
    return response['value'] as int;
  }

  @override
  Future<int> gameState(Object handle) async {
    final response = await _requestJson('GET', [
      'games',
      _gameId(handle).toString(),
      'state',
    ]);
    return response['value'] as int;
  }

  @override
  Future<int> makeMove(Object handle, int index) async {
    final response = await _requestJson(
      'POST',
      ['games', _gameId(handle).toString(), 'moves'],
      body: {'index': index},
    );
    return response['errorCode'] as int;
  }

  @override
  Future<int> bestMove(Object handle, int difficultyCode) async {
    final response = await _requestJson(
      'POST',
      ['games', _gameId(handle).toString(), 'best-move'],
      body: {'difficulty': difficultyCode},
    );
    return response['index'] as int;
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    List<String> pathSegments, {
    Map<String, Object?>? body,
  }) async {
    final request = await HttpRequest.request(
      _uri(pathSegments).toString(),
      method: method,
      requestHeaders: body == null
          ? null
          : {'Content-Type': 'application/json'},
      sendData: body == null ? null : jsonEncode(body),
    );

    final status = request.status ?? 0;
    if (status < 200 || status >= 300) {
      throw StateError(
        'HTTP $status from tic-tac-toe API: ${request.responseText ?? ''}',
      );
    }

    final responseText = request.responseText;
    if (responseText == null || responseText.isEmpty) {
      return <String, dynamic>{};
    }
    return jsonDecode(responseText) as Map<String, dynamic>;
  }

  Uri _uri(List<String> pathSegments) {
    final baseSegments = serverUri.pathSegments.where((segment) {
      return segment.isNotEmpty;
    });
    return serverUri.replace(pathSegments: [...baseSegments, ...pathSegments]);
  }

  int _gameId(Object handle) {
    return handle as int;
  }
}
