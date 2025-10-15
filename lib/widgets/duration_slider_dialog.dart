import 'package:flutter/material.dart';

class DurationSliderDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) formatLabel;

  const DurationSliderDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.divisions,
    required this.formatLabel,
  });

  @override
  State<DurationSliderDialog> createState() => _DurationSliderDialogState();
}

class _DurationSliderDialogState extends State<DurationSliderDialog> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.formatLabel(_currentSliderValue),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          Slider(
            value: _currentSliderValue,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.formatLabel(_currentSliderValue),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            "Aceptar",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            widget.onChanged(_currentSliderValue);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}