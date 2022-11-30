Freeze renders by showing an image instead of the rendered widget to reduce element tree counts

## Features
This freeze widget simply snapshots the child whenever the widget changes to prevent the flutter (web) framerate from getting low even when not redrawing the actual child widget.

## Usage

```dart
class SomeScreen extends StatefulWidget {
  const SomeScreen({Key? key}) : super(key: key);

  @override
  State<SomeScreen> createState() => _SomeScreenState();
}

class _SomeScreenState extends State<SomeScreen> {
  SomeComplexStateInfo stateInfo;

  @override
  Widget build(BuildContext context)=> Scaffold(
    body: Center(
      child: Freeze(
        builder: (context) => AVeryComplexWidget(stateInfo),
      ),
    ),
  );
}
```
