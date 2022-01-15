import 'package:flutter/material.dart';
import 'package:rooya_app/src/views/splash_screen_view.dart';
import 'views/conversations_view.dart';
import 'views/dashboard_view.dart';
import 'views/hash_videos_view.dart';
import 'views/my_profile_view.dart';
import 'views/password_login_view.dart';
import 'views/sign_up_view.dart';
import 'views/users_view.dart';
import 'views/verify_otp_screen.dart';
import 'views/verify_profile.dart';
import 'views/video_recorder.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash-screen':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => DashboardView());
      case '/password-login':
        return MaterialPageRoute(builder: (_) => PasswordLoginView());
      case '/sign-up':
        return MaterialPageRoute(builder: (_) => SignUpView());
      case '/verify-otp-screen':
        return MaterialPageRoute(builder: (_) => VerifyOTPView());
      case '/users':
        return MaterialPageRoute(builder: (_) => UsersView());
      case '/my-profile':
        return MaterialPageRoute(builder: (_) => MyProfileView());
      case '/verification-page':
        return MaterialPageRoute(builder: (_) => VerifyProfileView());
      case '/video-recorder':
        return MaterialPageRoute(builder: (_) => VideoRecorder());
      case '/hash-videos':
        return MaterialPageRoute(builder: (_) => HashVideosView());
      case '/conversation':
        return MaterialPageRoute(builder: (_) => ConversationsView());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: SafeArea(
              child: Center(
                child: Text('Route Error'),
              ),
            ),
          ),
        );
    }
  }
}
