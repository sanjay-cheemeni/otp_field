import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A one-time-password input made of [length] boxes.
///
/// Internally uses a single hidden [TextField], so pasting, backspace and
/// SMS autofill (`AutofillHints.oneTimeCode`) work naturally.
///
/// By default only digits are accepted. Provide [inputFormatters] and
/// [keyboardType] to allow letters.
///
/// ```dart
/// OtpField(
///   length: 6,
///   autofocus: true,
///   onCompleted: (code) => verify(code),
/// )
/// ```
class OtpField extends StatefulWidget {
  /// Creates an OTP input field.
  ///
  /// [length] must be greater than zero.
  const OtpField({
    super.key,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.autofocus = false,
    this.enabled = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.hasError = false,
    this.boxSize = const Size(48, 56),
    this.spacing = 8,
    this.borderRadius = 10,
    this.textStyle,
    this.activeColor,
    this.inactiveColor,
    this.errorColor,
    this.fillColor,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
  }) : assert(length > 0);

  /// Number of input boxes. Must be greater than zero.
  final int length;

  /// Controls the entered text.
  ///
  /// If null, the field creates and disposes its own controller. If you pass
  /// one, you are responsible for disposing it.
  final TextEditingController? controller;

  /// Controls keyboard focus of the field.
  ///
  /// If null, the field creates and disposes its own focus node. If you pass
  /// one, you are responsible for disposing it.
  final FocusNode? focusNode;

  /// Called every time the entered text changes.
  final ValueChanged<String>? onChanged;

  /// Called once when all [length] boxes are filled.
  final ValueChanged<String>? onCompleted;

  /// Whether the field requests focus automatically when first built.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether to hide entered characters using [obscuringCharacter].
  final bool obscureText;

  /// Character shown instead of the real one when [obscureText] is true.
  final String obscuringCharacter;

  /// Whether to show the error style using [errorColor].
  final bool hasError;

  /// Width and height of each box.
  final Size boxSize;

  /// Horizontal space between boxes.
  final double spacing;

  /// Corner radius of each box.
  final double borderRadius;

  /// Text style of the characters inside the boxes.
  ///
  /// Defaults to the theme's `headlineSmall` with a semi-bold weight.
  final TextStyle? textStyle;

  /// Border color of the box currently receiving input.
  ///
  /// Defaults to the theme's primary color.
  final Color? activeColor;

  /// Border color of boxes that are not active.
  ///
  /// Defaults to the theme's outline color.
  final Color? inactiveColor;

  /// Border color used when [hasError] is true.
  ///
  /// Defaults to the theme's error color.
  final Color? errorColor;

  /// Background color of each box.
  ///
  /// Defaults to the theme's surface color.
  final Color? fillColor;

  /// Keyboard type shown when the field is focused.
  final TextInputType keyboardType;

  /// Restricts which characters are accepted.
  ///
  /// Defaults to digits only. Pass your own list for alphanumeric codes.
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  String _lastValue = '';

  @override
  void initState() {
    super.initState();
    _setUpControllers();
  }

  void _setUpControllers() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _lastValue = _controller.text;
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _tearDownControllers() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
  }

  @override
  void didUpdateWidget(covariant OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.focusNode != widget.focusNode) {
      _tearDownControllers();
      _setUpControllers();
    }
  }

  @override
  void dispose() {
    _tearDownControllers();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _onTextChanged() {
    final text = _controller.text;
    if (text != _lastValue) {
      _lastValue = text;
      widget.onChanged?.call(text);
      if (text.length == widget.length) widget.onCompleted?.call(text);
    }
    setState(() {});
  }

  void _requestFocus() {
    if (!widget.enabled) return;
    _focusNode.requestFocus();
    // Keep the caret at the end so backspace always removes the last digit.
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _controller.text;
    final activeIndex = text.length.clamp(0, widget.length - 1);

    return Semantics(
      textField: true,
      label: 'One-time password, ${widget.length} digits',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _requestFocus,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hidden input that receives all keyboard / paste / autofill.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  enableSuggestions: false,
                  autocorrect: false,
                  inputFormatters: [
                    ...(widget.inputFormatters ??
                        [FilteringTextInputFormatter.digitsOnly]),
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < widget.length; i++) ...[
                    if (i > 0) SizedBox(width: widget.spacing),
                    _buildBox(theme, i, text, activeIndex),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(ThemeData theme, int index, String text, int activeIndex) {
    final hasChar = index < text.length;
    final isActive = _focusNode.hasFocus && index == activeIndex;

    final Color borderColor;
    if (widget.hasError) {
      borderColor = widget.errorColor ?? theme.colorScheme.error;
    } else if (isActive) {
      borderColor = widget.activeColor ?? theme.colorScheme.primary;
    } else {
      borderColor = widget.inactiveColor ?? theme.colorScheme.outline;
    }

    final char = hasChar
        ? (widget.obscureText ? widget.obscuringCharacter : text[index])
        : '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.boxSize.width,
      height: widget.boxSize.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.fillColor ??
            (widget.enabled
                ? theme.colorScheme.surface
                : theme.disabledColor.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
      ),
      child: Text(
        char,
        style: widget.textStyle ??
            theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
