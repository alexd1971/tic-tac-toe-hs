export 'api/base.dart';

import 'api/base.dart';
import 'api/ffi.dart' if (dart.library.html) 'api/http.dart' as platform;

TicTacToeApi createTicTacToeApi({String? libraryPath, Uri? serverUri}) {
  return platform.createTicTacToeApi(
    libraryPath: libraryPath,
    serverUri: serverUri,
  );
}
