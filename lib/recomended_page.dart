import 'dart:isolate';

import 'package:flutter/material.dart';

class RecommendedPage extends StatefulWidget {
  const RecommendedPage({Key? key}) : super(key: key);

  @override
  State<RecommendedPage> createState() => _RecommendedPageState();
}

class _RecommendedPageState extends State<RecommendedPage> {
  late Future<List<int>> _primesFuture;
  late ReceivePort _receivePort;
  Isolate? _isolate;

  @override
  void initState() {
    super.initState();
    _receivePort = ReceivePort();
    // Initiates the prime number computation in a separate isolate.
    // This approach prevents UI blocking and ensures a smooth user experience.

    _primesFuture = _computePrimes();
  }

  @override
  void dispose() {
    // Properly closes the receive port and terminates the isolate when the widget is disposed of.
    // This avoids memory leaks and ensures the isolate is not running in the background unnecessarily.
    _receivePort.close();
    _isolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  Future<List<int>> _computePrimes() async {
    // Spawns a new isolate to perform the prime number computation.
    _isolate =
        await Isolate.spawn(_computePrimesInIsolate, _receivePort.sendPort);

    // Listens for the results sent from the isolate.
    // Using isolates allows for parallel processing without blocking the main thread.
    final List<int> primes = await _receivePort.first;
    return primes;
  }

  static void _computePrimesInIsolate(SendPort sendPort) {
    // Performs the prime number computation in a separate isolate.
    // The computation does not affect the UI performance.
    final List<int> primes = [];
    int num = 2;
    while (primes.length < 10000) {
      if (_isPrime(num)) {
        primes.add(num);
      }
      num++;
    }
    sendPort.send(
        primes); // Sends the computed list of primes back to the main isolate.
  }

  static bool _isPrime(int number) {
    // Determines if a number is prime.
    if (number <= 1) return false;
    for (int i = 2; i <= number ~/ 2; i++) {
      if (number % i == 0) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended'),
      ),
      body: FutureBuilder<List<int>>(
        future: _primesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final primes = snapshot.data!;
            // Efficiently displays the list of prime numbers using ListView.builder.
            // This approach lazily builds widgets only for the visible items, optimizing memory usage.
            return ListView.builder(
              itemCount: primes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Prime ${primes[index]}'),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
