# otp_field

A customizable one-time-password (OTP) input field for Flutter. Supports paste, SMS autofill, obscured input, error states, and full styling control.

<!-- Add a screenshot or GIF here. It makes a big difference on pub.dev.
<p align="center">
  <img src="https://raw.githubusercontent.com/sanjay-cheemeni/otp_field/main/screenshots/demo.gif" width="300" />
</p>
-->

## Features

- Configurable number of boxes
- Paste support (long-press paste or keyboard suggestion)
- SMS autofill on Android and iOS (`AutofillHints.oneTimeCode`)
- Obscured mode for sensitive codes
- Error state with custom error color
- Highlighted active box
- Custom colors, box size, spacing, and border radius
- External `controller` and `focusNode` for full control
- Screen reader support through semantics
- Works with Material 3 themes (uses your app's `ColorScheme` by default)

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  otp_field: ^0.0.1
```

Or run:

```bash
flutter pub add otp_field
```

Then import it:

```dart
import 'package:otp_field/otp_field.dart';
```

## Usage

### Basic

```dart
OtpField(
  length: 6,
  autofocus: true,
  onCompleted: (code) {
    debugPrint('Entered code: $code');
  },
)
```

### Listen to every change

```dart
OtpField(
  length: 4,
  onChanged: (value) => debugPrint('Current: $value'),
  onCompleted: (value) => verifyCode(value),
)
```

### Obscured input

```dart
const OtpField(
  length: 4,
  obscureText: true,
  obscuringCharacter: '*',
)
```

### Error state

```dart
OtpField(
  length: 6,
  hasError: isCodeWrong,
  errorColor: Colors.red,
)
```

### Custom styling

```dart
OtpField(
  length: 6,
  boxSize: const Size(44, 52),
  spacing: 10,
  borderRadius: 12,
  activeColor: Colors.deepPurple,
  inactiveColor: Colors.grey,
  fillColor: Colors.grey.shade100,
  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
)
```

### Using a controller

Use a `TextEditingController` to read, set, or clear the code from outside the widget:

```dart
final controller = TextEditingController();

OtpField(
  length: 6,
  controller: controller,
)

// Clear the field
controller.clear();
```

### Dismiss the keyboard when complete

```dart
final focusNode = FocusNode();

OtpField(
  length: 6,
  focusNode: focusNode,
  onCompleted: (code) {
    focusNode.unfocus();
    verifyCode(code);
  },
)
```

Remember to dispose your `controller` and `focusNode` in a `StatefulWidget`.

### Alphanumeric codes

By default only digits are accepted. Pass your own formatters and keyboard type for letters:

```dart
OtpField(
  length: 6,
  keyboardType: TextInputType.text,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
  ],
)
```

## Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `length` | `int` | `6` | Number of boxes |
| `controller` | `TextEditingController?` | `null` | Controls the entered text |
| `focusNode` | `FocusNode?` | `null` | Controls focus |
| `onChanged` | `ValueChanged<String>?` | `null` | Called on every change |
| `onCompleted` | `ValueChanged<String>?` | `null` | Called when all boxes are filled |
| `autofocus` | `bool` | `false` | Focus automatically on build |
| `enabled` | `bool` | `true` | Enable or disable input |
| `obscureText` | `bool` | `false` | Hide the entered characters |
| `obscuringCharacter` | `String` | `'•'` | Character shown when obscured |
| `hasError` | `bool` | `false` | Show the error style |
| `boxSize` | `Size` | `Size(48, 56)` | Size of each box |
| `spacing` | `double` | `8` | Space between boxes |
| `borderRadius` | `double` | `10` | Corner radius of each box |
| `textStyle` | `TextStyle?` | `null` | Style of the characters |
| `activeColor` | `Color?` | `null` | Border color of the active box |
| `inactiveColor` | `Color?` | `null` | Border color of other boxes |
| `errorColor` | `Color?` | `null` | Border color in error state |
| `fillColor` | `Color?` | `null` | Background color of boxes |
| `keyboardType` | `TextInputType` | `number` | Keyboard shown |
| `inputFormatters` | `List<TextInputFormatter>?` | digits only | Restrict allowed characters |

## Example

A full example app is in the [`example`](example) folder. Run it with:

```bash
cd example
flutter run
```

## Additional information

- **Bugs and feature requests:** please open an issue on the [issue tracker](https://github.com/sanjay-cheemeni/otp_field/issues).
- **Contributions:** pull requests are welcome. Run `flutter analyze` and `flutter test` before submitting.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.