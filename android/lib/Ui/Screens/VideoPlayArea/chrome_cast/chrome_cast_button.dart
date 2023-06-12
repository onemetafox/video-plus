import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:videoPlus/Ui/Screens/VideoPlayArea/chrome_cast/chrome_cast_controller.dart';

/// Callback method for when the button is ready to be used.
///
/// Pass to [ChromeCastButton.onButtonCreated] to receive a [ChromeCastController]
/// when the button is created.
typedef void OnButtonCreated(ChromeCastController controller);

/// Callback method for when a request has failed.
typedef void OnRequestFailed(String? error);

/// Widget that displays the ChromeCast button.
class ChromeCastButton extends StatelessWidget {
  /// Creates a widget displaying a ChromeCast button.
  ChromeCastButton(
      {Key? key,
      this.size = 30.0,
      this.color = Colors.black,
      this.onButtonCreated,
      this.onSessionStarted,
      this.onSessionEnded,
      this.onRequestCompleted,
      this.onRequestFailed})
      : assert(
            defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.android || kIsWeb,
            '$defaultTargetPlatform is not supported by this plugin'),
        super(key: key);

  /// The size of the button.
  final double size;

  /// The color of the button.
  /// This is only supported on iOS at the moment.
  final Color color;

  /// Callback method for when the button is ready to be used.
  ///
  /// Used to receive a [ChromeCastController] for this [ChromeCastButton].
  final OnButtonCreated? onButtonCreated;

  /// Called when a cast session has started.
  final VoidCallback? onSessionStarted;

  /// Called when a cast session has ended.
  final VoidCallback? onSessionEnded;

  /// Called when a cast request has successfully completed.
  final VoidCallback? onRequestCompleted;

  /// Called when a cast request has failed.
  final OnRequestFailed? onRequestFailed;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = {
      'red': color.red,
      'green': color.green,
      'blue': color.blue,
      'alpha': color.alpha
    };
    return SizedBox(
      width: size,
      height: size,
      child: chromeCastPlatform.buildView(args, _onPlatformViewCreated),
    );
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final ChromeCastController controller = await ChromeCastController.init(id);
    if (onButtonCreated != null) {
      onButtonCreated!(controller);
    }
    if (onSessionStarted != null) {
      chromeCastPlatform
          .onSessionStarted(id: id)
          .listen((_) => onSessionStarted!());
    }
    if (onSessionEnded != null) {
      chromeCastPlatform
          .onSessionEnded(id: id)
          .listen((_) => onSessionEnded!());
    }
    if (onRequestCompleted != null) {
      chromeCastPlatform
          .onRequestCompleted(id: id)
          .listen((_) => onRequestCompleted!());
    }
    if (onRequestFailed != null) {
      chromeCastPlatform
          .onRequestFailed(id: id)
          .listen((event) => onRequestFailed!(event.error));
    }
  }
}
