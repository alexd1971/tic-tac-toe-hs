Pod::Spec.new do |s|
  s.name             = 'tic_tac_toe_bridge'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin that bridges Dart and the Haskell tic-tac-toe core.'
  s.description      = 'Flutter plugin that bridges Dart and the Haskell tic-tac-toe core.'
  s.homepage         = 'https://github.com/alexd1971/tic-tac-toe-hs'
  s.license          = { :type => 'BSD-3-Clause' }
  s.author           = { 'tic-tac-toe-hs' => 'noreply@example.com' }
  s.source           = { :path => '.' }
  s.vendored_libraries = 'lib/*.dylib'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
