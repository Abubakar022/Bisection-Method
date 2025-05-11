import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const BisectionApp());
}

class BisectionApp extends StatelessWidget {
  const BisectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bisection Method Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BisectionHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bisection Method Solver',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'A Numerical Analysis Project',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 5),
              const Text(
                'Designed By Abu Bakar',
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BisectionHomePage extends StatefulWidget {
  const BisectionHomePage({Key? key}) : super(key: key);

  @override
  State<BisectionHomePage> createState() => _BisectionHomePageState();
}

class _BisectionHomePageState extends State<BisectionHomePage> {
  final _aController = TextEditingController(text: '1');
  final _bController = TextEditingController(text: '3');
  final _epsilonController = TextEditingController(text: '0.0001');
  final _equationController = TextEditingController(text: 'x^2 - 4*x + 4 - log(x)');
  String _result = '';
  String _selectedCriterion = 'ABSOLUTE_ERROR';
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isCalculating = false;

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _epsilonController.dispose();
    _equationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bisection Method Solver'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blueAccent, Colors.purpleAccent],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Function Input',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _equationController,
                          decoration: InputDecoration(
                            labelText: 'Equation f(x) = 0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.functions),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter an equation' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Parameters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _aController,
                                decoration: InputDecoration(
                                  labelText: 'Start (a)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter start value';
                                  return double.tryParse(value) == null ? 'Invalid number' : null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _bController,
                                decoration: InputDecoration(
                                  labelText: 'End (b)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter end value';
                                  return double.tryParse(value) == null ? 'Invalid number' : null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _epsilonController,
                          decoration: InputDecoration(
                            labelText: 'Tolerance (ε)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter tolerance';
                            final num = double.tryParse(value);
                            if (num == null) return 'Invalid number';
                            if (num <= 0) return 'Must be positive';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedCriterion,
                          decoration: InputDecoration(
                            labelText: 'Stopping Criterion',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'ABSOLUTE_ERROR',
                                child: Text('Absolute Error')),
                            DropdownMenuItem(
                                value: 'RELATIVE_ERROR',
                                child: Text('Relative Error')),
                            DropdownMenuItem(
                                value: 'DISTANCE_TO_ROOT',
                                child: Text('Distance to Root')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedCriterion = value!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCalculating ? null : _solveBisection,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: _isCalculating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'SOLVE',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCalculating
                            ? null
                            : () => setState(() {
                          _result = '';
                        }),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text(
                          'CLEAR',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Results:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 100,
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        _result,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _solveBisection() {
    if (!_formKey.currentState!.validate()) return;

    final a = double.parse(_aController.text);
    final b = double.parse(_bController.text);
    final epsilon = double.parse(_epsilonController.text);
    String equation = _equationController.text;

    if (a >= b) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: a must be less than b'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _result = 'Calculating...';
    });

    // Preprocess equation
    equation = equation
        .replaceAll('^', '**')
        .replaceAll('ln(', 'log(')
        .replaceAll('e**x', 'exp(x)');

    Future.delayed(const Duration(milliseconds: 50), () {
      try {
        final result = _bisectionMethod(a, b, _selectedCriterion, epsilon, equation);
        setState(() => _result = result);
        _scrollToBottom();
      } catch (e) {
        setState(() => _result = 'Error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isCalculating = false);
      }
    });
  }

  String _bisectionMethod(double a, double b, String criterion, double epsilon, String equationStr) {
    final output = StringBuffer();
    int iteration = 0;
    double root = 0;

    output.writeln('=== BISECTION METHOD SOLUTION ===');
    output.writeln('Equation: $equationStr');
    output.writeln('Interval: [$a, $b]');
    output.writeln('Tolerance: $epsilon');
    output.writeln('Stopping Criterion: $criterion\n');

    // Parse the equation
    final parser = Parser();
    final exp = parser.parse(equationStr);

    double f(double x) {
      final cm = ContextModel()
        ..bindVariable(Variable('x'), Number(x))
        ..bindVariable(Variable('e'), Number(2.718281828459045))
        ..bindVariable(Variable('pi'), Number(3.141592653589793));

      try {
        return exp.evaluate(EvaluationType.REAL, cm);
      } catch (e) {
        // Second attempt with protected evaluation
        final safeX = x < 1e-10 ? 1e-10 : x;
        cm.bindVariable(Variable('x'), Number(safeX));
        return exp.evaluate(EvaluationType.REAL, cm);
      }
    }


    // Initial checks
    final fa = f(a);
    final fb = f(b);
    output.writeln('Initial evaluations:');
    output.writeln('f($a) = $fa');
    output.writeln('f($b) = $fb\n');

    if (fa * fb >= 0) {
      throw Exception('Function must have opposite signs at endpoints');
    }

    while (iteration <= 100) {
      root = (a + b) / 2;
      final fx = f(root);

      output.writeln('Iteration ${iteration + 1}:');
      output.writeln('  Current interval: [$a, $b]');
      output.writeln('  Root approximation: $root');
      output.writeln('  f(root) = $fx');

      // Check stopping criteria
      final error = (b - a) / 2;
      if (fx == 0 || error < epsilon) {
        output.writeln('\nConvergence achieved!');
        break;
      }

      if (fx * fa < 0) {
        b = root;
      } else {
        a = root;
      }

      iteration++;
    }

    output.writeln('\n=== FINAL RESULT ===');
    output.writeln('Approximate root: $root');
    output.writeln('Iterations: ${iteration + 1}');
    output.writeln('Estimated error: ${(b - a) / 2}');
    output.writeln('f(root) = ${f(root)}');

    return output.toString();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}