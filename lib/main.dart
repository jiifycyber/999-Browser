import "package:url_launcher/url_launcher.dart";
import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

void main() => runApp(const SearchApp());

class SearchApp extends StatelessWidget {
  const SearchApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "999 Search",
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF168BFF),
        secondary: Color(0xFF21D8FF),
        surface: Color(0xFF0B1930),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF168BFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF0B1930),
          side: const BorderSide(color: Color(0xFF21D8FF), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF030B1C),
        indicatorColor: const Color(0xFF123B63),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF21D8FF)
                : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF21D8FF)
                : Colors.white70,
          ),
        ),
      ),
    ),
    home: const SearchHome(),
  );
}

class SearchHome extends StatefulWidget {
  const SearchHome({super.key});
  @override
  State<SearchHome> createState() => _SearchHomeState();
}

class _SearchHomeState extends State<SearchHome> {
  final search = TextEditingController();
  bool searching = false;
  bool hasSearched = false;
  String? searchError;
  List<Map<String, dynamic>> results = [];
  Future<void> runSearch() async {
    final query = search.text.trim();
    if (query.isEmpty) return;
    setState(() {
      searching = true;
      hasSearched = true;
      searchError = null;
      results = [];
    });
    try {
      final uri = Uri.parse(
        "http://127.0.0.1:8101/api/search",
      ).replace(queryParameters: {"q": query});
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception("Commonweb HTTP ${response.statusCode}");
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = data["results"] as List? ?? [];
      if (!mounted) return;
      setState(() {
        results = rows
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        searchError = "Cannot reach Commonweb. Check that its API is running.";
      });
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  String category = "Web";
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;
    final categories = [
      "Web",
      "Images",
      "News",
      "Videos",
      "Maps",
      "Shopping",
      "AI Answer",
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF030B1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: mobile ? null : const Text("999 SEARCH"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      drawer: const Drawer(
        child: SafeArea(child: Center(child: Text("999 Search"))),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF8AFAFF),
                          Color(0xFF21D8FF),
                          Color(0xFF397BFF),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "999",
                        style: TextStyle(
                          fontSize: mobile ? 100 : 160,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Color(0xFF21D8FF), blurRadius: 36),
                            Shadow(color: Color(0xFFB340FF), blurRadius: 52),
                          ],
                        ),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF8AFAFF),
                          Colors.white,
                          Color(0xFFB340FF),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "S E A R C H",
                        style: TextStyle(
                          fontSize: mobile ? 28 : 48,
                          letterSpacing: 7,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "EXPLORE  •  DISCOVER  •  KNOW  •  BE FREE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: mobile ? 52 : 76),
                    TextField(
                      controller: search,
                      onSubmitted: (_) => runSearch(),
                      decoration: InputDecoration(
                        hintText: "Search the world without limits...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: const Icon(Icons.mic_none),
                        filled: true,
                        fillColor: const Color(0xFF0B1930),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      children: [
                        FilledButton(
                          onPressed: runSearch,
                          child: const Text("999 Search"),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("I am Feeling Lucky"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (searching)
                      const CircularProgressIndicator()
                    else if (searchError != null)
                      Text(
                        searchError!,
                        style: const TextStyle(color: Colors.orangeAccent),
                      )
                    else if (hasSearched && results.isEmpty)
                      const Text(
                        "No indexed results found",
                        style: TextStyle(color: Colors.white70),
                      )
                    else if (results.isNotEmpty)
                      ...results.map(
                        (r) => _GenesisPanel(
                          child: ListTile(
                            title: Text(
                              (r["title"] ?? r["domain"] ?? "Indexed page")
                                  .toString(),
                              style: const TextStyle(color: Colors.cyanAccent),
                            ),
                            subtitle: Text(
                              "${r["url"] ?? ""}\n${r["description"] ?? ""}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              final u = Uri.tryParse(
                                (r["url"] ?? "").toString(),
                              );
                              if (u != null) {
                                launchUrl(u, mode: LaunchMode.platformDefault);
                              }
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 25,
                      runSpacing: 25,
                      children: categories
                          .map(
                            (item) => InkWell(
                              onTap: () => setState(() => category = item),
                              child: SizedBox(
                                width: mobile ? 65 : 95,
                                child: Column(
                                  children: [
                                    _IC391IconCircle(
                                      radius: 28,
                                      backgroundColor: category == item
                                          ? Colors.blue
                                          : const Color(0xFF11203A),
                                      child: Icon(
                                        item == "Images"
                                            ? Icons.image_outlined
                                            : item == "News"
                                            ? Icons.article_outlined
                                            : item == "Videos"
                                            ? Icons.play_circle_outline
                                            : item == "Maps"
                                            ? Icons.location_on_outlined
                                            : item == "Shopping"
                                            ? Icons.shopping_bag_outlined
                                            : item == "AI Answer"
                                            ? Icons.auto_awesome
                                            : Icons.public,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 35),
                    if (search.text.isNotEmpty)
                      Text(
                        "Search ready: ${search.text}",
                        style: const TextStyle(color: Colors.cyanAccent),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: mobile
          ? NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: [
                NavigationDestination(
                  icon: const _IC391IconCircle(
                    radius: 14,
                    backgroundColor: Color(0xFF071B40),
                    child: Icon(
                      Icons.search,
                      color: Color(0xFF21D8FF),
                      size: 19,
                    ),
                  ),
                  label: "Search",
                ),
                NavigationDestination(
                  icon: const _IC391IconCircle(
                    radius: 14,
                    backgroundColor: Color(0xFF071B40),
                    child: Icon(
                      Icons.image,
                      color: Color(0xFF21D8FF),
                      size: 19,
                    ),
                  ),
                  label: "Images",
                ),
                NavigationDestination(
                  icon: const _IC391IconCircle(
                    radius: 14,
                    backgroundColor: Color(0xFF071B40),
                    child: Icon(
                      Icons.article,
                      color: Color(0xFF21D8FF),
                      size: 19,
                    ),
                  ),
                  label: "News",
                ),
                NavigationDestination(
                  icon: const _IC391IconCircle(
                    radius: 14,
                    backgroundColor: Color(0xFF071B40),
                    child: Icon(
                      Icons.play_circle,
                      color: Color(0xFF21D8FF),
                      size: 19,
                    ),
                  ),
                  label: "Videos",
                ),
                NavigationDestination(
                  icon: const _IC391IconCircle(
                    radius: 14,
                    backgroundColor: Color(0xFF071B40),
                    child: Icon(Icons.menu, color: Color(0xFF21D8FF), size: 19),
                  ),
                  label: "More",
                ),
              ],
            )
          : null,
    );
  }
}

class _GenesisPanel extends StatelessWidget {
  const _GenesisPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8AFAFF),
            Color(0xFF21D8FF),
            Color(0xFF397BFF),
            Color(0xFFB340FF),
            Color(0xFFFF3FA4),
          ],
          stops: [0, .18, .43, .76, 1],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF21D8FF).withValues(alpha: .22),
            blurRadius: 22,
            spreadRadius: .5,
          ),
          BoxShadow(
            color: const Color(0xFFB340FF).withValues(alpha: .15),
            blurRadius: 32,
          ),
          const BoxShadow(
            color: Color(0x99000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.4),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF103A7A),
              Color(0xFF0A285A),
              Color(0xFF071B40),
              Color(0xFF0B1637),
              Color(0xFF24104D),
            ],
          ),
          borderRadius: BorderRadius.circular(14.6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.6),
          child: Stack(
            children: [
              Positioned(
                left: -35,
                top: -45,
                width: 140,
                height: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF21D8FF).withValues(alpha: .22),
                        const Color(0xFF21D8FF).withValues(alpha: .06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -40,
                bottom: -45,
                width: 150,
                height: 130,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB340FF).withValues(alpha: .20),
                        const Color(0xFFB340FF).withValues(alpha: .05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _IC391IconCircle extends StatelessWidget {
  const _IC391IconCircle({
    required this.radius,
    required this.backgroundColor,
    required this.child,
  });
  final double radius;
  final Color backgroundColor;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF21D8FF);
    const purple = Color(0xFFB340FF);
    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8AFAFF), cyan, Color(0xFF397BFF), purple],
        ),
        boxShadow: [
          BoxShadow(color: cyan.withValues(alpha: 0.30), blurRadius: 18),
          BoxShadow(color: purple.withValues(alpha: 0.18), blurRadius: 24),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              const Color(0xFF071B40),
              const Color(0xFF24104D),
            ],
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
