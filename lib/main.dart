import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Calculator',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF39766A)),
      scaffoldBackgroundColor: const Color(0xFFF7F8F5),
      fontFamily: '.SF Pro Display',
    ),
    home: const CalculatorPage(),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _left;
  String? _operator;
  bool _replace = false;
  bool _error = false;

  String _format(double value) =>
      double.parse(value.toStringAsPrecision(12))
          .toString()
          .replaceFirst(RegExp(r'\.0$'), '');

  void _clear() {
    _display = '0';
    _expression = '';
    _left = null;
    _operator = null;
    _replace = false;
    _error = false;
  }

  bool _calculate() {
    final right = double.parse(_display);
    final result = switch (_operator) {
      '+' => _left! + right,
      '−' => _left! - right,
      '×' => _left! * right,
      '÷' => _left! / right,
      _ => right,
    };
    if (!result.isFinite) {
      _clear();
      _error = true;
      _display = 'Error';
      _expression = right == 0
          ? 'Cannot divide by zero'
          : 'Number is too large';
      return false;
    }
    _display = _format(result);
    return true;
  }

  void _press(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'AC') {
        _clear();
        return;
      }
      if (_error) _clear();
      if ('0123456789.'.contains(key)) {
        if (_replace) {
          _display = '0';
          _replace = false;
          if (_operator == null) _expression = '';
        }
        if (key == '.') {
          if (!_display.contains('.')) _display += '.';
        } else if (_display.replaceAll(RegExp(r'[^0-9]'), '').length < 12) {
          _display = _display == '0'
              ? key
              : (_display == '-0' ? '-$key' : _display + key);
        }
      } else if (key == '⌫') {
        if (_replace) return;
        _display = _display.length > 1
            ? _display.substring(0, _display.length - 1)
            : '0';
        if (_display == '-') _display = '0';
      } else if (key == '+/−') {
        if (_replace && _operator != null) {
          _display = '-0';
          _replace = false;
        } else {
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display';
        }
      } else if (key == '=') {
        if (_operator == null || _replace) return;
        final expression = '${_format(_left!)} $_operator $_display =';
        if (!_calculate()) return;
        _expression = expression;
        _left = null;
        _operator = null;
        _replace = true;
      } else {
        if (_operator != null && !_replace && !_calculate()) return;
        _left = double.parse(_display);
        _operator = key;
        _expression = '${_format(_left!)} $key';
        _replace = true;
      }
    });
  }

  Widget _button(String label) {
    final operation = const ['÷', '×', '−', '+'].contains(label);
    final selected = operation && _operator == label;
    final equals = label == '=';
    final utility = const ['AC', '+/−', '⌫'].contains(label);
    final color = equals || selected
        ? const Color(0xFF39766A)
        : operation
        ? const Color(0xFFE2EEE8)
        : utility
        ? const Color(0xFFEAEDE7)
        : Colors.white;
    const names = {
      '÷': 'Divide',
      '×': 'Multiply',
      '−': 'Subtract',
      '+': 'Add',
      '=': 'Equals',
      'AC': 'Clear all',
      '⌫': 'Delete last digit',
      '+/−': 'Change sign',
      '.': 'Decimal point',
    };
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Semantics(
          label: names[label] ?? label,
          button: true,
          child: ExcludeSemantics(
            child: FilledButton(
              key: ValueKey('key-$label'),
              onPressed: () => _press(label),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: equals || selected
                    ? Colors.white
                    : const Color(0xFF203A33),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: TextStyle(
                  fontSize: utility ? 25 : 32,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: SizedBox(
                    height: constraints.maxHeight < 600
                        ? 600
                        : constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(19, 20, 19, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'Calculator',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF203A33),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                24,
                                14,
                                24,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _expression,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF6E7C74),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Semantics(
                                    label: 'Result',
                                    liveRegion: true,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _display,
                                          key: const ValueKey('display'),
                                          style: const TextStyle(
                                            fontSize: 76,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xFF203A33),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: constraints.maxHeight < 700 ? 320 : 400,
                            child: Column(
                              children: [
                                for (final row in const [
                                  ['AC', '+/−', '⌫', '÷'],
                                  ['7', '8', '9', '×'],
                                  ['4', '5', '6', '−'],
                                  ['1', '2', '3', '+'],
                                  ['0', '.', '='],
                                ])
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: row.map(_button).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
