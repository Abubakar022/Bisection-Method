import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const BisectionApp());
}

class BisectionApp extends StatelessWidget {
  const BisectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bisection Solver',
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
  const SplashScreen({super.key});

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
            colors: [Colors.deepPurple, Colors.blueAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Bisection Method Solver',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'Numerical Analysis Tool',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Developed by Abu Bakar',
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
  const BisectionHomePage({super.key});

  @override
  State<BisectionHomePage> createState() => _BisectionHomePageState();
}

class _BisectionHomePageState extends State<BisectionHomePage> {
  final _aController = TextEditingController(text: '0');
  final _bController = TextEditingController(text: '1');
  final _epsilonController = TextEditingController(text: '0.001');
  final _equationController = TextEditingController(text: 'sqrt(x) - cos(x)');
  String _result = '';
  String _selectedCriterion = 'ABSOLUTE_ERROR';
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isCalculating = false;
  bool _showHelp = false;

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _epsilonController.dispose();
    _equationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _preprocessEquation(String equation) {
    return equation
        .replaceAll('ln(', 'log(')
        .replaceAll('log(', 'max(1e-10,(')
        .replaceAllMapped(
      RegExp(r'e\^x|e\*\*x'),
          (match) => 'exp(x)',
    )
        .replaceAll('^', '**')
        .replaceAll('π', 'pi');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bisection Solver'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple, Colors.blueAccent],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () => setState(() => _showHelp = !_showHelp),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              ),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_showHelp) _buildHelpCard(),
                        _buildInputCard(),
                        const SizedBox(height: 20),
                        _buildButtons(),
                        const SizedBox(height: 25),
                        _buildResultCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _equationController,
              decoration: _inputDecoration('Equation f(x) = 0', Icons.functions),
              validator: (value) =>
              value == null || value.isEmpty ? 'Enter equation' : null,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _aController,
                    decoration: _inputDecoration('Start (a)', null),
                    keyboardType: TextInputType.number,
                    validator: _numberValidator,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _bController,
                    decoration: _inputDecoration('End (b)', null),
                    keyboardType: TextInputType.number,
                    validator: _numberValidator,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _epsilonController,
              decoration: _inputDecoration('Tolerance (ε)', null),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter tolerance';
                final num = double.tryParse(value);
                if (num == null) return 'Invalid number';
                if (num <= 0) return 'Must be positive';
                return null;
              },
            ),
            const SizedBox(height: 15),
            // DropdownButtonFormField<String>(
            //   value: _selectedCriterion,
            //   decoration: _inputDecoration('Stopping Criterion', null),
            //   items: const [
            //     DropdownMenuItem(
            //       value: 'ABSOLUTE_ERROR',
            //       child: Text('Absolute Error'),
            //     ),
            //     DropdownMenuItem(
            //       value: 'RELATIVE_ERROR',
            //       child: Text('Relative Error'),
            //     ),
            //     DropdownMenuItem(
            //       value: 'DISTANCE_TO_ROOT',
            //       child: Text('Distance to Root'),
            //     ),
            //   ],
            //   onChanged: (value) => setState(() => _selectedCriterion = value!),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.blueAccent, width: 1),
      ),
      margin: const EdgeInsets.only(top: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SOLUTION RESULTS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            if (_result.isEmpty)
              const Center(
                child: Text(
                  'No results yet. Click SOLVE to calculate.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (_result.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // TextButton(
                  //   onPressed: _scrollToBottom,
                  //   child: const Text('Scroll to Bottom'),
                  // ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Results copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Equation Format Help',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showHelp = false),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Supported Functions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              '• exp(x) - Exponential\n'
                  '• log(x) - Natural log\n'
                  '• sin(x), cos(x), tan(x)\n'
                  '• sqrt(x) - Square root\n'
                  '• x^2 or x**2 - Power\n'
                  '• pi (3.14159...)',
              style: TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 15),
            const Text('Examples:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
              '3*x - exp(x)\n'
                  'log(x+1) - 0.5\n'
                  'x^2 - 4*x + 4 - log(x)\n'
                  'sin(pi*x) + x/2',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isCalculating ? null : _solve,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            child: _isCalculating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('SOLVE', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: _isCalculating ? null : () => setState(() => _result = ''),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('CLEAR', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  String? _numberValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter a number';
    return double.tryParse(value) == null ? 'Invalid number' : null;
  }

  InputDecoration _inputDecoration(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      prefixIcon: icon != null ? Icon(icon) : null,
    );
  }

  void _solve() {
    if (!_formKey.currentState!.validate()) return;

    final a = double.parse(_aController.text);
    final b = double.parse(_bController.text);
    final epsilon = double.parse(_epsilonController.text);
    String equation = _equationController.text;

    if (a >= b) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: a must be less than b'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
      _result = 'Calculating...';
    });

    equation = _preprocessEquation(equation);

    Future.delayed(const Duration(milliseconds: 50), () {
      try {
        final result = _bisectionMethod(a, b, _selectedCriterion, epsilon, equation);
        setState(() => _result = result);
        _scrollToBottom();
      } catch (e) {
        setState(() => _result = 'Error: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
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

    output.writeln('=== BISECTION METHOD ===');
    output.writeln('Equation: ${_equationController.text}');
    output.writeln('Interval: [$a, $b]');
    output.writeln('Tolerance: $epsilon');
    output.writeln('Criterion: $criterion\n');

    final parser = Parser();
    final exp = parser.parse(equationStr);

    double f(double x) {
      final cm = ContextModel()
        ..bindVariable(Variable('x'), Number(x < 1e-10 ? 1e-10 : x))
        ..bindVariable(Variable('e'), Number(2.718281828459045))
        ..bindVariable(Variable('pi'), Number(3.141592653589793));
      return exp.evaluate(EvaluationType.REAL, cm);
    }

    final fa = f(a);
    final fb = f(b);
    output.writeln('f($a) = $fa');
    output.writeln('f($b) = $fb\n');

    if (fa * fb >= 0) {
      throw Exception('Function must have opposite signs at endpoints');
    }

    while (iteration <= 100) {
      root = (a + b) / 2;
      final fx = f(root);

      output.writeln('Iteration ${iteration + 1}:');
      output.writeln('  Interval: [$a, $b]');
      output.writeln('  Midpoint: $root');
      output.writeln('  f(root) = $fx');

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
