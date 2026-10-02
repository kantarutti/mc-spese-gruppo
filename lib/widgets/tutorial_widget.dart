import 'package:flutter/material.dart';
import '../services/tutorial_service.dart';
import 'bubble_widget.dart'; // Assicurati che il percorso del BubbleWidget sia corretto

class TutorialWidget extends StatefulWidget {
  final String tutorialKey;
  final String title;
  final String text;
  final Widget child;

  const TutorialWidget({
    super.key,
    required this.tutorialKey,
    required this.title,
    required this.text,
    required this.child,
  });

  @override
  State<TutorialWidget> createState() => TutorialWidgetState();
}

class TutorialWidgetState extends State<TutorialWidget> {
  bool _showTutorial = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final shouldShow = await TutorialService.shouldShow(widget.tutorialKey);
    if (mounted) {
      setState(() {
        _showTutorial = shouldShow;
        _isLoading = false;
      });
    }
  }

  // Metodo pubblico per riattivare/mostrare il tutorial (es. dal tasto info)
  Future<void> resetAndShow() async {
    await TutorialService.reset(widget.tutorialKey);
    await _checkTutorialStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showTutorial)
          BubbleWidget(
            title: widget.title,
            text: widget.text,
            onClose: () => setState(() => _showTutorial = false),
            onDontShowAgain: () async {
              await TutorialService.disable(widget.tutorialKey);
              setState(() => _showTutorial = false);
            },
          ),
      ],
    );
  }
}