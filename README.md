# Calculator

A simple, single-screen Flutter calculator designed for iPhone, with a light theme,
large buttons, and a display that scales to fit longer numbers.

Supports addition, subtraction, multiplication, division, decimal numbers,
positive/negative numbers, clear, and deleting the last entered digit. Operations
are evaluated sequentially, like a basic pocket calculator. Division by zero
shows an error; entering a number starts again. Input and results use up to 12
significant digits.

## Run

With Flutter and Xcode installed, start an iPhone simulator and run:

```sh
flutter run
```

## Verify

```sh
flutter analyze
flutter test
flutter build ios --simulator --no-codesign
```

Running on a physical iPhone requires configuring your signing team in Xcode.
