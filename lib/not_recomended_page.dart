import 'package:flutter/material.dart';

class NotRecommendedPage extends StatefulWidget {
  const NotRecommendedPage({Key? key}) : super(key: key);

  @override
  State<NotRecommendedPage> createState() => _NotRecommendedPageState();
}

class _NotRecommendedPageState extends State<NotRecommendedPage> {
  late Future<List<int>> _primesFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future that will compute prime numbers.
    // This computation happens on the main thread, which may cause the UI to freeze.
    _primesFuture = _computePrimes();
  }

  Future<List<int>> _computePrimes() async {
    // Simulates heavy computation on the main thread.
    // This can block the UI, making it unresponsive during the calculation.
    final List<int> primes = _generatePrimes();
    return primes;
  }

  List<int> _generatePrimes() {
    // Generates a list of prime numbers up to a certain count.
    final List<int> primes = [];
    int num = 2;
    while (primes.length < 10000) {
      if (_isPrime(num)) {
        primes.add(num);
      }
      num++;
    }
    return primes;
  }

  bool _isPrime(int number) {
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
        title: const Text('Not Recommended'),
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
            // Displays the list of prime numbers in a scrollable column.
            // This approach may cause performance issues for a large number of items because it renders all items at once.
            return SingleChildScrollView(
              child: Column(
                children: primes.map((prime) {
                  return ListTile(
                    title: Text('Prime $prime'),
                  );
                }).toList(),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
