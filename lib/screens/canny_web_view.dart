import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CannyWebView extends StatefulWidget {
  final String userEmail;
  final String userName;
  final String userId;
  final String userAvatarURL;
  final String userCreated;

  const CannyWebView({
    required this.controller,
    super.key,
    required this.userEmail,
    required this.userName,
    required this.userId,
    required this.userAvatarURL,
    required this.userCreated,
  });

  final WebViewController controller;

  @override
  State<CannyWebView> createState() => _CannyWebViewState();
}

class _CannyWebViewState extends State<CannyWebView> {
  final WebViewController _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    _controller.loadHtmlString('''
        <!DOCTYPE html>
        <html>
        <head>
        <script>!function(w,d,i,s){function l(){if(!d.getElementById(i)){var f=d.getElementsByTagName(s)[0],e=d.createElement(s);e.type="text/javascript",e.async=!0,e.src="https://canny.io/sdk.js",f.parentNode.insertBefore(e,f)}}if("function"!=typeof w.Canny){var c=function(){c.q.push(arguments)};c.q=[],w.Canny=c,"complete"===d.readyState?l():w.attachEvent?w.attachEvent("onload",l):w.addEventListener("load",l,!1)}}(window,document,"canny-jssdk","script");</script>
        </head>
        <body>
        <script>
        Canny('identify', {
          appID: '65ea2597b9f94bf7b9c31f78',
          user: {
            email: '${widget.userEmail}',
            name: '${widget.userName}',
            id: '${widget.userId}',
            avatarURL: '${widget.userAvatarURL}',
            created: new Date('${widget.userCreated}').toISOString(),
          },
        });
        </script>
        <a data-canny-link href="https://miittiapp.canny.io">Give feedback</a>
        </body>
        </html>
        ''');
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _controller,
    );
  }
}


// Alternative approach: https://www.rudderstack.com/integration/canny/integrate-your-flutter-app-with-canny/