# OBD-II Mobile App

A clean, modern, and open-source OBD-II diagnostic and dashboard application for Android and iOS. Built with Flutter, targeting the Vgate iCar Pro 2S adapter.

## Features

- **Real-time Dashboard**: Configurable instrument-cluster-style display with live PID data (RPM, Speed, Load, etc.).
- **Adapter Support**: Works with BLE (Bluetooth Low Energy) and Classic Bluetooth (SPP) adapters via a flexible transport adapter pattern.
- **DTC Management**: Read and clear Diagnostic Trouble Codes (stored and pending).
- **Profile Management**: Create and switch between named dashboard profiles for different vehicles or use cases.
- **Mode 06 Support**: View on-board monitoring test results for deeper diagnostics.
- **Mock Mode**: Built-in simulator for development without a physical adapter.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (latest stable)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Communication**: [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) (BLE) and [flutter_bluetooth_serial](https://pub.dev/packages/flutter_bluetooth_serial) (SPP).

## Development

See [BUILD_GUIDE.md](BUILD_GUIDE.md) for instructions on setting up the development environment, generating code, and building for Android/iOS.

## License

Open source.
