import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// --- Hardcoded Admin Email ---
const String adminEmail = "admin@example.com";

// --- Main App Entry Point ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme data remains the same...
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFF03DAC6),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF03DAC6),
            secondary: Color(0xFF03DAC6),
            background: Color(0xFF121212),
            surface: Color(0xFF1E1E1E),
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onBackground: Colors.white,
            onSurface: Colors.white,
            error: Colors.redAccent,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(
            bodyColor: Colors.white.withOpacity(0.87),
            displayColor: Colors.white.withOpacity(0.87),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF03DAC6)),
            ),
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF03DAC6),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.4),
          )
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Models ---
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

// --- Authentication (No changes) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const HomePage();
          }
          return const AuthScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  void _toggleAuthMode() => setState(() => _isLogin = !_isLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isLogin
              ? LoginPage(onToggle: _toggleAuthMode)
              : SignUpPage(onToggle: _toggleAuthMode),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginPage({required this.onToggle, super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? "An error occurred."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Welcome Back', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Login to your account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters.' : null,
          ),
          const SizedBox(height: 24),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _login, child: const Text('Login')),
          const SizedBox(height: 16),
          TextButton(onPressed: widget.onToggle, child: const Text('Don\'t have an account? Sign Up')),
        ],
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  final VoidCallback onToggle;
  const SignUpPage({required this.onToggle, super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'createdAt': Timestamp.now(),
      });

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? "An error occurred."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Start your journey with us', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            obscureText: true,
            validator: (value) => (value != _passwordController.text) ? 'Passwords do not match.' : null,
          ),
          const SizedBox(height: 24),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
          const SizedBox(height: 16),
          TextButton(onPressed: widget.onToggle, child: const Text('Already have an account? Login')),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isAdmin() {
    return FirebaseAuth.instance.currentUser?.email == adminEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Products'),
        actions: [
          if (_isAdmin())
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelPage())),
              tooltip: 'Admin Panel',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No products found."));
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong."));
                }

                var products = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .where((product) => product.name.toLowerCase().contains(_searchQuery))
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(product.imageUrl, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 40))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.asset(product.imageUrl, fit: BoxFit.contain, height: 250, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 50))),
            ),
            const SizedBox(height: 24),
            Text(product.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(product.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.5)),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.payment),
          label: const Text("Buy Now with JazzCash"),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(product: product))),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final Product product;
  const PaymentPage({required this.product, super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _jazzCashNumberController = TextEditingController(text: "03001234567");
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'userEmail': user.email,
        'productName': widget.product.name,
        'price': widget.product.price,
        'paymentMethod': 'JazzCash (Dummy)',
        'jazzCashNumber': _jazzCashNumberController.text,
        'orderDate': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Order placed successfully!"),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to place order: ${e.toString()}"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Payment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Order Summary", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.product.name, style: Theme.of(context).textTheme.titleMedium),
                          Text('\$${widget.product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('\$${widget.product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text("Payment Method", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text("Enter your dummy JazzCash account number to confirm."),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jazzCashNumberController,
                decoration: const InputDecoration(labelText: "JazzCash Number"),
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.length < 11) ? "Enter a valid number" : null,
              ),
              const SizedBox(height: 32),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _processPayment,
                  child: const Text("Confirm Payment"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW: Admin Panel now has a Reports tab ---
class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // --- CHANGE: Increased length to 4 for the new tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Panel"),
          bottom: const TabBar(
            isScrollable: true, // Allows tabs to scroll if they don't fit
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: "Reports"), // --- NEW: Reports Tab
              Tab(icon: Icon(Icons.shopping_cart), text: "Orders"),
              Tab(icon: Icon(Icons.category), text: "Products"),
              Tab(icon: Icon(Icons.people), text: "Users"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminReportsTab(), // --- NEW: Reports Tab View
            AdminOrdersTab(),
            AdminProductsTab(),
            AdminUsersTab(),
          ],
        ),
      ),
    );
  }
}

// --- NEW: Admin Reports & Revenue Tab ---
class AdminReportsTab extends StatelessWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching data."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders yet to generate reports."));
        }

        final orders = snapshot.data!.docs;

        // --- Calculate Metrics ---
        double totalRevenue = orders.fold(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return sum + (data['price'] ?? 0.0);
        });

        int totalOrders = orders.length;

        double averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

        // --- Calculate Top Selling Products ---
        Map<String, int> productCounts = {};
        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          final productName = data['productName'] as String? ?? 'Unknown Product';
          productCounts[productName] = (productCounts[productName] ?? 0) + 1;
        }
        var sortedProducts = productCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Revenue Overview", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _MetricCard(
                    title: "Total Revenue",
                    value: "\$${totalRevenue.toStringAsFixed(2)}",
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  _MetricCard(
                    title: "Total Orders",
                    value: totalOrders.toString(),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                  _MetricCard(
                    title: "Avg. Order Value",
                    value: "\$${averageOrderValue.toStringAsFixed(2)}",
                    icon: Icons.pie_chart,
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text("Top Selling Products", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedProducts.length > 5 ? 5 : sortedProducts.length, // Show top 5
                  itemBuilder: (context, index) {
                    final productEntry = sortedProducts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Text("#${index + 1}", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(productEntry.key),
                      trailing: Text("${productEntry.value} sales", style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- NEW: Helper Widget for the Report Metric Cards ---
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// --- Admin Orders Tab ---
class AdminOrdersTab extends StatelessWidget {
  const AdminOrdersTab({super.key});

  Future<void> _deleteOrder(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').orderBy('orderDate', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No orders found."));
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong."));
        }

        final orders = snapshot.data!.docs;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index].data() as Map<String, dynamic>;
            final orderTime = (order['orderDate'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(order['productName'] ?? 'N/A'),
                subtitle: Text("By: ${order['userEmail'] ?? 'N/A'}\nAt: ${orderTime.toLocal().toString().substring(0, 16)}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("\$${order['price']?.toStringAsFixed(2) ?? '0.00'}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _showDeleteConfirmation(context, "Delete Order?", () => _deleteOrder(context, orders[index].id)),
                      tooltip: "Delete Order",
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

// --- Admin Products Tab ---
class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  Future<void> _deleteProduct(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('products').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found. Add one!"));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong."));
          }

          final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.asset(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image)),
                  title: Text(product.name),
                  subtitle: Text("\$${product.price.toStringAsFixed(2)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditProductPage(product: product))),
                        tooltip: "Edit Product",
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _showDeleteConfirmation(context, "Delete Product?", () => _deleteProduct(context, product.id)),
                        tooltip: "Delete Product",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditProductPage())),
        child: const Icon(Icons.add),
        tooltip: "Add Product",
      ),
    );
  }
}

// --- Admin Users Tab ---
class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found."));
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong."));
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final joinTime = (user['createdAt'] as Timestamp).toDate();
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user['email'] ?? 'N/A'),
                subtitle: Text("Joined: ${joinTime.toLocal().toString().substring(0, 10)}"),
              ),
            );
          },
        );
      },
    );
  }
}

// --- Add/Edit Product Page ---
class AddEditProductPage extends StatefulWidget {
  final Product? product;
  const AddEditProductPage({this.product, super.key});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? 'assets/images/placeholder.png');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final productData = {
      'name': _nameController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'imageUrl': _imageUrlController.text,
      'description': _descriptionController.text,
    };

    try {
      if (widget.product == null) {
        await FirebaseFirestore.instance.collection('products').add(productData);
      } else {
        await FirebaseFirestore.instance.collection('products').doc(widget.product!.id).update(productData);
      }
      if(mounted) Navigator.pop(context);
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save product: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (value) => (value == null || value.isEmpty) ? "Please enter a name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || double.tryParse(value) == null) ? "Please enter a valid price" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image Path (e.g., assets/images/phone.png)"),
                validator: (value) => (value == null || value.isEmpty) ? "Please enter an image path" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? "Please enter a description" : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProduct,
                child: const Text("Save Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable confirmation dialog ---
Future<void> _showDeleteConfirmation(BuildContext context, String title, VoidCallback onConfirm) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This action cannot be undone.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onPressed: () {
              onConfirm();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

