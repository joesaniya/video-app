import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:video_call_app/Business-Logic/auth-provider.dart';
import 'package:video_call_app/Business-Logic/home-provider.dart';
import 'package:video_call_app/Business-Logic/profiile-provider.dart';
import 'package:video_call_app/Business-Logic/splash-provider.dart';

class ProviderHelperClass {
  static ProviderHelperClass? _instance;

  static ProviderHelperClass get instance {
    _instance ??= ProviderHelperClass();
    return _instance!;
  }

  List<SingleChildWidget> providerLists = [
    ChangeNotifierProvider(create: (context) => SplashProvider(context)),

    // ChangeNotifierProvider(create: (context) => SplashProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => HomeProvider()),
    ChangeNotifierProvider(create: (context) => ProfileProvider()),
  ];
}
