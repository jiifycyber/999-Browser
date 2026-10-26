import "package:webview_windows/webview_windows.dart" as win;
import "package:flutter/foundation.dart";
import "package:url_launcher/url_launcher.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart" as desktop;
import 'widgets/divine_legends_trivia.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'core/genesis_theme.dart';
import 'widgets/ic391_master_panel.dart';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;
import 'services/genesis_news_sources.dart';
import 'package:flutter/material.dart';
import 'widgets/premium_share_panel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'screens/forex_trading_shell.dart';

void main() => runApp(const Browser999());

const bg = Color(0xFF030B1C);
const panel = Color(0xFF091B35);
const blue = Color(0xFF168BFF);
const cyan = Color(0xFF21D8FF);
const gold = Color(0xFFFFCA64);

class Browser999 extends StatelessWidget {
  const Browser999({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '999 Browser',
    debugShowCheckedModeBanner: false,
    theme: GenesisTheme.dark,
    home: const BrowserHome(),
  );
}

class BrowserHome extends StatefulWidget {
  const BrowserHome({super.key});
  @override
  State<BrowserHome> createState() => _BrowserHomeState();
}

class _BrowserHomeState extends State<BrowserHome> {
  static const externalLinks = MethodChannel('com.999browser/external_links');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) refreshTmzNews();
    });
    externalLinks.setMethodCallHandler((call) async {
      if (call.method == 'openUrl' && call.arguments is String) {
        final uri = Uri.tryParse(call.arguments as String);
        if (uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty &&
            mounted) {
          await go(uri.toString());
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) externalLinks.invokeMethod<void>('ready');
    });
  }

  List<Map<String, String>> tmzHeadlines = [];
  String newsCategory = "All";
  static const List<String> newsCategories = [
    "All",
    "Government",
    "World",
    "Finance",
    "Technology",
    "Entertainment",
  ];
  List<Map<String, String>> get filteredNews => newsCategory == "All"
      ? tmzHeadlines
      : tmzHeadlines
            .where((article) => article["category"] == newsCategory)
            .toList();
  bool tmzLoading = false;
  String? tmzError;
  Future<void> refreshTmzNews() async {
    if (tmzLoading) return;
    setState(() {
      tmzLoading = true;
      tmzError = null;
    });
    final headlines = <Map<String, String>>[];
    final failures = <String>[];
    final seen = <String>{};
    final batches = await Future.wait(
      genesisNewsSources.map((source) async {
        final articles = <Map<String, String>>[];
        try {
          final response = await http
              .get(
                Uri.parse(source["url"]!),
                headers: {"User-Agent": "Mozilla/5.0"},
              )
              .timeout(const Duration(seconds: 12));
          if (response.statusCode != 200) {
            throw Exception("HTTP ${response.statusCode}");
          }
          final document = xml.XmlDocument.parse(response.body);
          final items = document.findAllElements("item").toList();
          final entries = document.findAllElements("entry").toList();
          for (final item in [...items, ...entries]) {
            final title = item.getElement("title")?.innerText.trim() ?? "";
            var link = item.getElement("link")?.innerText.trim() ?? "";
            if (link.isEmpty) {
              link = item.getElement("link")?.getAttribute("href") ?? "";
            }
            final uri = Uri.tryParse(link);
            if (title.isEmpty ||
                uri == null ||
                uri.scheme != "https" ||
                uri.host.isEmpty) {
              continue;
            }
            articles.add({
              "title": title,
              "link": uri.toString(),
              "source": source["name"]!,
              "category": source["category"]!,
            });
          }
        } catch (e) {
          failures.add(source["name"]!);
        }
        return articles;
      }),
    );
    for (final batch in batches) {
      for (final article in batch) {
        if (seen.add(article["link"]!)) {
          headlines.add(article);
        }
      }
    }
    headlines.shuffle();
    if (!mounted) return;
    setState(() {
      tmzHeadlines = headlines;
      tmzError = headlines.isEmpty
          ? "News unavailable: ${failures.join(", ")}"
          : null;
      tmzLoading = false;
    });
    if (failures.isNotEmpty) {
      debugPrint("999 NEWS SOURCES UNAVAILABLE: ${failures.join(", ")}");
    }
  }

  final search = TextEditingController();
  final address = TextEditingController();
  String section = 'Home';
  String category = 'Web';
  String? error;
  bool loading = false;
  bool searched = false;
  List<Map<String, dynamic>> results = [];
  final List<String> recent = [];
  final List<String> bookmarks = [
    'https://www.google.com',
    'https://www.youtube.com',
    'https://www.tradingview.com',
  ];
  final List<String> tabs = ['New Tab'];
  WebViewController createTabController(int id, String url) {
    late final WebViewController controller;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (value) {
            if (mounted && tabControllers.containsValue(controller)) {
              setState(() {
                tabUrls[tabControllers.keys.firstWhere(
                      (key) => identical(tabControllers[key], controller),
                    )] =
                    value;
                tabLoading[tabControllers.keys.firstWhere(
                      (key) => identical(tabControllers[key], controller),
                    )] =
                    true;
              });
            }
          },
          onPageFinished: (value) {
            if (tabControllers[activeTab] == controller) address.text = value;
            if (mounted && tabControllers.containsValue(controller)) {
              setState(() {
                tabUrls[tabControllers.keys.firstWhere(
                      (key) => identical(tabControllers[key], controller),
                    )] =
                    value;
                tabLoading[tabControllers.keys.firstWhere(
                      (key) => identical(tabControllers[key], controller),
                    )] =
                    false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    tabControllers[id] = controller;
    tabUrls[id] = url;
    return controller;
  }

  int activeTab = 0;
  final Map<int, WebViewController> tabControllers = {};
  final Map<int, desktop.InAppWebViewController> desktopTabControllers = {};
  final Map<int, win.WebviewController> windowsTabControllers = {};
  final Map<int, String> tabUrls = {};
  final Map<int, bool> tabLoading = {};

  @override
  void dispose() {
    for (final controller in windowsTabControllers.values) {
      controller.dispose();
    }
    search.dispose();
    address.dispose();
    super.dispose();
  }

  Future<void> go([String? input, bool forceSearch = false]) async {
    final q = (input ?? search.text).trim();
    if (q.isEmpty) return;
    search.text = q;
    final looksUrl =
        !q.contains(' ') &&
        (q.startsWith('https://') ||
            q.startsWith('http://') ||
            RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}([/:?#].*)?$').hasMatch(q));
    if (looksUrl && !forceSearch) {
      final uri = Uri.tryParse(q.startsWith('http') ? q : 'https://$q');
      if (uri != null &&
          (uri.scheme == 'https' || uri.scheme == 'http') &&
          uri.host.isNotEmpty) {
        final url = uri.toString();
        address.text = url;
        address.text = url;
        if (kIsWeb) {
          await launchUrl(uri, webOnlyWindowName: "_blank");
          return;
        }
        if (defaultTargetPlatform == TargetPlatform.windows) {
          await openWindowsWebsite(uri.toString());
          return;
        } else if (defaultTargetPlatform == TargetPlatform.macOS) {
          final existing = desktopTabControllers[activeTab];
          if (existing != null) {
            await existing.loadUrl(
              urlRequest: desktop.URLRequest(url: desktop.WebUri(url)),
            );
          }
        } else {
          final existing = tabControllers[activeTab];
          if (existing == null) {
            createTabController(activeTab, url);
          } else {
            await existing.loadRequest(uri);
          }
        }
        if (!mounted) return;
        setState(() {
          tabs[activeTab] = uri.host;
          tabUrls[activeTab] = url;
          section = "Web";
        });
        if (!mounted) return;
        setState(() {
          if (!recent.contains(q)) recent.insert(0, q);
        });
        return;
      }
    }
    setState(() {
      loading = true;
      searched = true;
      section = 'Search';
      error = null;
      results = [];
    });
    try {
      final uri = Uri.parse(
        'https://ic391-defense-command.tail49e2f2.ts.net:10000/api/search',
      ).replace(queryParameters: {'q': q});
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Search HTTP ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rows = data['results'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        results = rows
            .whereType<Map>()
            .map((r) => Map<String, dynamic>.from(r))
            .toList();
        if (!recent.contains(q)) recent.insert(0, q);
      });
    } catch (e) {
      if (mounted) setState(() => error = 'Search unavailable: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String privacyReturnSection = "Home";

  Future<void> openWindowsWebsite(String url) async {
    var controller = windowsTabControllers[activeTab];
    if (controller == null) {
      controller = win.WebviewController();
      await controller.initialize();
      windowsTabControllers[activeTab] = controller;
    }
    await controller.loadUrl(url);
    if (!mounted) return;
    setState(() {
      tabUrls[activeTab] = url;
      tabs[activeTab] = Uri.parse(url).host;
      section = "Web";
    });
  }

  Future<void> openWebsite(String target) async {
    final uri = Uri.tryParse(target);
    if (uri == null ||
        (uri.scheme != "https" && uri.scheme != "http") ||
        uri.host.isEmpty) {
      return;
    }
    final url = uri.toString();
    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: "_blank");
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await openWindowsWebsite(uri.toString());
      return;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final existing = desktopTabControllers[activeTab];
      if (existing != null) {
        await existing.loadUrl(
          urlRequest: desktop.URLRequest(url: desktop.WebUri(url)),
        );
      }
    } else {
      final existing = tabControllers[activeTab];
      if (existing == null) {
        createTabController(activeTab, url);
      } else {
        await existing.loadRequest(uri);
      }
    }
    if (!mounted) return;
    setState(() {
      tabs[activeTab] = uri.host;
      tabUrls[activeTab] = url;
      section = "Web";
    });
  }

  void navigate(String target) {
    if (target.startsWith("https://") || target.startsWith("http://")) {
      openWebsite(target);
      return;
    }
    if (target == 'Forex Trading' || target == 'Trading') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ForexTradingShell()));
    } else {
      setState(() {
        if (target == "VPN / Privacy" && section != target) {
          privacyReturnSection = section;
        }
        section = target;
        if (target == 'Search') searched = true;
      });
    }
  }

  Widget surface({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) => IC391MasterPanel(padding: padding, child: child);

  Widget navItem(String name, IconData icon, {bool compact = false}) {
    final active = section == name;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? GenesisColors.gold : GenesisColors.border,
        ),
        gradient: LinearGradient(
          colors: active
              ? [GenesisColors.panelRaised, GenesisColors.glassPurple]
              : [GenesisColors.panel, GenesisColors.midnight],
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: GenesisColors.gold.withValues(alpha: .22),
                  blurRadius: 16,
                ),
              ]
            : [],
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          icon,
          color: active ? GenesisColors.gold : GenesisColors.cyan,
          size: 20,
        ),
        title: compact
            ? null
            : Text(
                name,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? GenesisColors.gold : GenesisColors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
        onTap: () => navigate(name),
      ),
    );
  }

  Widget sidebar() => IC391MasterPanel(
    padding: EdgeInsets.zero,
    child: Container(
      width: 190,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF103A7A), Color(0xFF071B40), Color(0xFF24104D)],
        ),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Image.asset(
              "assets/images/999_genesis_logo.png",
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
          ),
          const Center(
            child: Text(
              'B R O W S E R',
              style: TextStyle(letterSpacing: 2, fontSize: 12),
            ),
          ),
          const SizedBox(height: 18),
          navItem('Home', Icons.home),
          navItem('Search', Icons.search),
          navItem('AI Assistant', Icons.psychology),
          navItem('Forex Trading', Icons.candlestick_chart),
          navItem('Tabs', Icons.tab),
          navItem('Bookmarks', Icons.star),
          navItem('History', Icons.history),
          navItem('Downloads', Icons.download),
          navItem('VPN / Privacy', Icons.shield),
          navItem('Extensions', Icons.extension),
          navItem('Settings', Icons.settings),
          const Divider(height: 30),
          const Text(
            'WORKSPACES',
            style: TextStyle(
              color: cyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (final name in [
            '999 ALC',
            '999 Tax Pro',
            '999 Tax Pro Biz',
            '999 AutoData',
            '999 Signal Lab',
            '999 Financial',
          ])
            navItem(name, Icons.grid_view),
        ],
      ),
    ),
  );

  Widget searchBox() => Container(
    height: 58,
    decoration: BoxDecoration(
      color: const Color(0xFF061329),
      borderRadius: BorderRadius.circular(36),
      border: Border.all(color: const Color(0xFFFFD66B), width: 1.5),
      boxShadow: [
        BoxShadow(color: cyan.withValues(alpha: .18), blurRadius: 14),
      ],
    ),
    child: Row(
      children: [
        const SizedBox(width: 16),
        const Icon(Icons.search, color: Color(0xFF00CFFF), size: 27),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: search,
            onSubmitted: (_) => go(),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              hintText: "Search 999 or enter website address",
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Material(
            color: const Color(0xFFFFD66B),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: "Search",
              onPressed: () => go(),
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
          ),
        ),
      ],
    ),
  );
  Widget addressBox() => Container(
    height: 58,
    decoration: BoxDecoration(
      color: const Color(0xFF061329),
      borderRadius: BorderRadius.circular(36),
      border: Border.all(color: const Color(0xFFFFD66B), width: 1.5),
      boxShadow: [
        BoxShadow(color: cyan.withValues(alpha: .18), blurRadius: 14),
      ],
    ),
    child: Row(
      children: [
        const SizedBox(width: 16),
        const Icon(Icons.link, color: Color(0xFF00CFFF), size: 25),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: address,
            onSubmitted: (value) => go(value),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: const InputDecoration(
              hintText: "Enter website address",
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Material(
            color: const Color(0xFFFFD66B),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: "Go to website",
              onPressed: () => go(address.text),
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
          ),
        ),
      ],
    ),
  );
  Widget topbar() => Column(
    children: [
      Container(
        color: const Color(0xFF06172F),
        height: 43,
        child: Row(
          children: [
            IconButton(
              onPressed: () => navigate('Home'),
              icon: const Icon(Icons.home, color: cyan),
            ),
            for (var i = 0; i < tabs.length && i < 5; i++)
              Flexible(
                child: InkWell(
                  onTap: () => setState(() {
                    activeTab = i;
                    section =
                        (tabControllers.containsKey(i) ||
                            tabUrls.containsKey(i))
                        ? "Web"
                        : "Home";
                  }),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: activeTab == i
                          ? blue.withValues(alpha: .35)
                          : panel,
                    ),
                    child: Text(
                      tabs[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            IconButton(
              tooltip: 'New tab',
              onPressed: () => setState(() {
                tabs.add('New Tab');
                activeTab = tabs.length - 1;
                section = 'Home';
                search.clear();
                searched = false;
              }),
              icon: const Icon(Icons.add),
            ),
            const Spacer(),
            const Text(
              '999 BROWSER',
              style: TextStyle(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: const Color(0xFF041024),
        child: Row(
          children: [
            IconButton(
              onPressed: () => navigate('Home'),
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: () => navigate('Home'),
              icon: const Icon(Icons.refresh),
            ),
            Expanded(child: searchBox()),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                tooltip: "Save Website Shortcut",
                icon: const Icon(Icons.download_outlined, color: gold),
                onPressed: () async {
                  final url = tabUrls[activeTab];
                  if (url == null) return;
                  await Clipboard.setData(ClipboardData(text: url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Website URL copied. Create a desktop shortcut from this link.",
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                tooltip: "Share Website",
                icon: const Icon(Icons.ios_share, color: cyan),
                onPressed: () async {
                  final url = tabUrls[activeTab];
                  if (url != null) {
                    final overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;
                    final button = context.findRenderObject() as RenderBox;
                    final point = button.localToGlobal(
                      Offset.zero,
                      ancestor: overlay,
                    );
                    await showDialog<void>(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (dialogContext) => Stack(
                        children: [
                          Positioned(
                            right: 24,
                            top: point.dy + 48,
                            child: Material(
                              color: Colors.transparent,
                              child: PremiumSharePanel(
                                url: url,
                                onShare: () async {
                                  Navigator.pop(dialogContext);
                                  await SharePlus.instance.share(
                                    ShareParams(text: url),
                                  );
                                },
                                onDock: () async {
                                  Navigator.pop(dialogContext);
                                  try {
                                    const channel = MethodChannel(
                                      "com.999browser/dock",
                                    );
                                    await channel.invokeMethod<void>(
                                      "installWebsite",
                                      {"url": url},
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Website added to Dock"),
                                      ),
                                    );
                                  } catch (error) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Dock installation failed: $error",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                tooltip: "New Tab",
                icon: const Icon(Icons.add, color: gold),
                onPressed: () => setState(() {
                  tabs.add("New Tab");
                  activeTab = tabs.length - 1;
                  section = "Home";
                  search.clear();
                  searched = false;
                }),
              ),
            ),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                tooltip: "Tab Overview",
                icon: const Icon(Icons.tab_outlined, color: cyan),
                onPressed: () => navigate("Tabs"),
              ),
            ),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: () {
                  if (search.text.isNotEmpty) {
                    setState(() => bookmarks.add(search.text));
                  }
                },
                icon: const Icon(Icons.star_border, color: GenesisColors.gold),
              ),
            ),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: () => navigate('VPN / Privacy'),
                icon: const Icon(
                  Icons.shield_outlined,
                  color: GenesisColors.cyan,
                ),
              ),
            ),
            IC391MasterPanel(
              padding: EdgeInsets.zero,
              child: IconButton(
                onPressed: () => navigate('AI Assistant'),
                icon: const Icon(Icons.auto_awesome, color: GenesisColors.gold),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget pill(String label, IconData icon, VoidCallback onTap) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF061329),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF168BFF), width: 1.2),
      boxShadow: [
        BoxShadow(color: cyan.withValues(alpha: .18), blurRadius: 10),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: GenesisColors.cyan),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: label == "Forex Trading"
                      ? GenesisColors.gold
                      : GenesisColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget shortcuts() => LayoutBuilder(
    builder: (context, constraints) {
      final mobile = MediaQuery.sizeOf(context).width < 900;
      final cardWidth = mobile
          ? (constraints.maxWidth - 18) / 3
          : ((constraints.maxWidth - 81) / 10).clamp(60.0, 118.0);
      final items = <(String, String, IconData)>[
        (
          "Apple Music for Artists",
          "https://artists.apple.com/",
          Icons.music_note,
        ),
        ("Zoom", "https://zoom.us", Icons.videocam),
        ("LinkedIn", "https://www.linkedin.com", Icons.work),
        ("Business", "https://www.sba.gov/", Icons.business),
        ("RockAuto", "https://www.rockauto.com", Icons.build),
        ("Pocket Option", "https://pocketoption.com", Icons.candlestick_chart),
        ("Health", "https://www.zocdoc.com/", Icons.medical_services),
        ("Education", "https://www.khanacademy.org/", Icons.school),
        (
          "Money",
          "https://www.dnb.com/en-us/smb/business-credit.html",
          Icons.account_balance_wallet,
        ),
        (
          "Spotify for Artists",
          "https://artists.spotify.com/",
          Icons.graphic_eq,
        ),
      ];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: mobile ? items.length * (cardWidth + 9) : constraints.maxWidth,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final item in items)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (item.$2.isNotEmpty) {
                      go(item.$2);
                    } else {
                      search.text = item.$1;
                      go();
                    }
                  },
                  child: Container(
                    width: cardWidth,
                    height: 106,
                    decoration: BoxDecoration(
                      color: const Color(0xFF061329),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF168BFF),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cyan.withValues(alpha: .12),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$3,
                          size: 30,
                          color: item.$1.startsWith("999")
                              ? GenesisColors.gold
                              : GenesisColors.cyan,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            item.$1,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
  Widget feature(String title, IconData icon, Widget child) => surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: gold, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Expanded(child: child),
      ],
    ),
  );

  Widget home() => SingleChildScrollView(
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        if (MediaQuery.sizeOf(context).width < 900) ...[
          addressBox(),
          const SizedBox(height: 18),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in <(String, IconData, String)>[
                ('Upwork', Icons.work, 'https://www.upwork.com'),
                ('Fiverr', Icons.design_services, 'https://www.fiverr.com'),
                ('Etsy', Icons.store, 'https://www.etsy.com'),
                ('Amazon Seller', Icons.inventory, 'https://sell.amazon.com'),
                ('eBay', Icons.shopping_bag, 'https://www.ebay.com'),
                ('Shopify', Icons.shopping_cart, 'https://www.shopify.com'),
                ('YouTube', Icons.play_circle, 'https://www.youtube.com'),
                ('TikTok', Icons.music_note, 'https://www.tiktok.com'),
                ('Patreon', Icons.favorite, 'https://www.patreon.com'),
                ('Gumroad', Icons.file_download, 'https://gumroad.com'),
                ('Amazon KDP', Icons.menu_book, 'https://kdp.amazon.com'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: pill(c.$1, c.$2, () => navigate(c.$3)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: MediaQuery.sizeOf(context).width < 900 ? 245 : 250,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/images/earth_background.png",
                fit: BoxFit.cover,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99030B1C),
                      Color(0x44030B1C),
                      Color(0xBB030B1C),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x5533BFFF),
                            blurRadius: 32,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Color(0x33FFD36B),
                            blurRadius: 22,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/999_genesis_logo.png",
                        width: MediaQuery.sizeOf(context).width < 900
                            ? 155
                            : 190,
                        height: MediaQuery.sizeOf(context).width < 900
                            ? 155
                            : 190,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      "B R O W S E R",
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 12)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: searchBox(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => navigate("Forex Trading"),
                  icon: const Icon(Icons.show_chart, size: 18),
                  label: const Text("Open Trading Terminal"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00CFFF),
                    side: const BorderSide(
                      color: Color(0xFF00CFFF),
                      width: 1.5,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => go("https://www.forexfactory.com"),
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text("Forex Factory"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GenesisColors.gold,
                    side: const BorderSide(
                      color: GenesisColors.gold,
                      width: 1.5,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        shortcuts(),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;
            final cards = [
              feature(
                'TRENDING NEWS',
                Icons.newspaper,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '9³ BROWSER • LIVE HEADLINES',
                            style: TextStyle(color: cyan, fontSize: 14),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh News',
                          onPressed: tmzLoading ? null : refreshTmzNews,
                          icon: const Icon(Icons.refresh, color: gold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 38,
                      child: DropdownButton<String>(
                        value: newsCategory,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: const Color(0xFF101C2B),
                        items: newsCategories
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => newsCategory = value);
                          }
                        },
                      ),
                    ),
                    if (tmzLoading) const LinearProgressIndicator(),
                    if (tmzError != null)
                      Text(
                        tmzError!,
                        style: const TextStyle(color: gold, fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Expanded(
                      child: filteredNews.isEmpty
                          ? Center(
                              child: OutlinedButton.icon(
                                onPressed: tmzLoading ? null : refreshTmzNews,
                                icon: const Icon(Icons.download),
                                label: const Text('9³ News'),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredNews.length,
                              itemBuilder: (context, index) {
                                final article = filteredNews[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    article['title'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  subtitle: Text(
                                    article['source'] ?? 'News',
                                    style: TextStyle(color: gold, fontSize: 10),
                                  ),
                                  onTap: () => go(article['link']),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              feature(
                'AI ASSISTANT',
                Icons.psychology,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Research smarter with 999 AI.'),
                    const SizedBox(height: 16),
                    for (final action in [
                      'Summarize this page',
                      'Explain this topic',
                      'Find related sources',
                      'Research deeper',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => navigate('AI Assistant'),
                            child: Text(action),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              feature(
                'DIVINE LEGENDS TRIVIA',
                Icons.auto_stories,
                const Expanded(child: DivineLegendsTrivia()),
              ),
            ];
            if (width < 820) {
              return Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(height: 260, child: card),
                    ),
                ],
              );
            }
            return SizedBox(
              height: 290,
              child: Row(
                children: [
                  for (final card in cards)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: card,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DISCOVER TOPICS',
                style: TextStyle(color: gold, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in <(String, String)>[
                    (
                      'Amazon Associates',
                      'https://affiliate-program.amazon.com',
                    ),
                    ('Printful', 'https://www.printful.com'),
                    ('Taskrabbit', 'https://www.taskrabbit.com'),
                    ('Rover', 'https://www.rover.com'),
                    ('DoorDash', 'https://www.doordash.com/dasher/signup/'),
                    ('Uber', 'https://www.uber.com/us/en/drive/'),
                    ('Twitch', 'https://www.twitch.tv'),
                    ('Udemy', 'https://www.udemy.com/teaching/'),
                    ('Substack', 'https://www.substack.com'),
                    ('Freelancer', 'https://www.freelancer.com'),
                    ('Ko-fi', 'https://ko-fi.com'),
                    ('Redbubble', 'https://www.redbubble.com'),
                    ('Poshmark', 'https://poshmark.com'),
                    ('Mercari', 'https://www.mercari.com'),
                    ('Depop', 'https://www.depop.com'),
                    ('Creative Market', 'https://creativemarket.com'),
                    ('Adobe Stock', 'https://contributor.stock.adobe.com'),
                    ('Shutterstock', 'https://submit.shutterstock.com'),
                    ('Teachable', 'https://teachable.com'),
                    ('Buy Me a Coffee', 'https://www.buymeacoffee.com'),
                    ('Instacart Shopper', 'https://shoppers.instacart.com'),
                    ('Lyft', 'https://www.lyft.com/driver'),
                  ])
                    ActionChip(
                      label: Text(c.$1),
                      onPressed: () => navigate(c.$2),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget privacyCenter() {
    final items = <(String, String, IconData)>[
      ("Tracking Protection", "Not connected", Icons.shield_outlined),
      ("Ad Blocking", "Not connected", Icons.block),
      ("Cookies", "Awaiting integration", Icons.cookie_outlined),
      ("Browsing History", "Session history available", Icons.history),
      ("HTTPS Security", "Awaiting integration", Icons.lock_outline),
      ("Site Permissions", "Awaiting integration", Icons.tune),
      ("Private Browsing", "Not implemented", Icons.visibility_off_outlined),
      ("VPN Connection", "No VPN connected", Icons.vpn_lock_outlined),
      ("Clear Browsing Data", "Awaiting integration", Icons.delete_outline),
    ];
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [GenesisColors.cyan, Color(0xFFB94DFF)],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF07172D),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shield,
                      color: GenesisColors.cyan,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "999 PRIVACY CENTER",
                        style: TextStyle(
                          color: GenesisColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: "Close Privacy Center",
                      onPressed: () => setState(() {
                        section = privacyReturnSection;
                      }),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Security, privacy and user control",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 18),
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF102B4A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: GenesisColors.cyan.withValues(alpha: .25),
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(item.$3, color: GenesisColors.cyan),
                        title: Text(
                          item.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          item.$2,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.info_outline,
                          color: GenesisColors.cyan,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  "Protection settings are informational until connected to browser security services.",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget webNavigationBar() {
    final windowsController =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
        ? windowsTabControllers[activeTab]
        : null;
    final controller = tabControllers[activeTab];
    return Container(
      color: panel,
      child: Row(
        children: [
          IconButton(
            tooltip: "Back",
            icon: const Icon(Icons.arrow_back, color: gold),
            onPressed: () async {
              if (windowsController != null &&
                  windowsController.value.isInitialized) {
                await windowsController.goBack();
              } else if (windowsController != null &&
                  windowsController.value.isInitialized) {
                await windowsController.goForward();
              } else if (defaultTargetPlatform == TargetPlatform.macOS &&
                  desktopTabControllers[activeTab] != null) {
                final web = desktopTabControllers[activeTab]!;
                if (await web.canGoBack()) await web.goBack();
              } else if (controller != null && await controller.canGoBack()) {
                await controller.goBack();
              }
            },
          ),
          IconButton(
            tooltip: "Forward",
            icon: const Icon(Icons.arrow_forward, color: gold),
            onPressed: () async {
              if (defaultTargetPlatform == TargetPlatform.macOS &&
                  desktopTabControllers[activeTab] != null) {
                final web = desktopTabControllers[activeTab]!;
                if (await web.canGoForward()) await web.goForward();
              } else if (controller != null &&
                  await controller.canGoForward()) {
                await controller.goForward();
              }
            },
          ),
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh, color: gold),
            onPressed: () {
              if (windowsController != null &&
                  windowsController.value.isInitialized) {
                windowsController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.macOS) {
                desktopTabControllers[activeTab]?.reload();
              } else {
                controller?.reload();
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: address,
              onSubmitted: openWebsite,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                hintText: "Enter website address",
                prefixIcon: Icon(Icons.link, color: gold, size: 18),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          IconButton(
            tooltip: "Home",
            icon: const Icon(Icons.home, color: gold),
            onPressed: () => navigate("Home"),
          ),
        ],
      ),
    );
  }

  void closeBrowserTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    setState(() {
      tabs.removeAt(index);
      tabControllers.remove(index);
      desktopTabControllers.remove(index);
      windowsTabControllers.remove(index)?.dispose();
      tabUrls.remove(index);
      tabLoading.remove(index);
      for (var i = index + 1; i <= tabs.length; i++) {
        if (tabControllers.containsKey(i)) {
          tabControllers[i - 1] = tabControllers.remove(i)!;
        }
        if (windowsTabControllers.containsKey(i)) {
          windowsTabControllers[i - 1] = windowsTabControllers.remove(i)!;
        }
        if (desktopTabControllers.containsKey(i)) {
          desktopTabControllers[i - 1] = desktopTabControllers.remove(i)!;
        }
        if (tabUrls.containsKey(i)) tabUrls[i - 1] = tabUrls.remove(i)!;
        if (tabLoading.containsKey(i)) {
          tabLoading[i - 1] = tabLoading.remove(i)!;
        }
      }
      if (tabs.isEmpty) tabs.add("New Tab");
      if (activeTab > index) activeTab--;
      if (activeTab >= tabs.length) activeTab = tabs.length - 1;
      section =
          (tabControllers.containsKey(activeTab) ||
              tabUrls.containsKey(activeTab))
          ? "Web"
          : "Home";
    });
  }

  Widget persistentWebViews() {
    final ids = tabControllers.keys.toList()..sort();
    if (ids.isEmpty) return const SizedBox.shrink();
    final selected = ids.indexOf(activeTab);
    return IndexedStack(
      index: selected < 0 ? 0 : selected,
      children: [
        for (final id in ids)
          WebViewWidget(
            key: ValueKey("persistent_web_$id"),
            controller: tabControllers[id]!,
          ),
      ],
    );
  }

  Widget sectionBody() {
    if (section == "Web" &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows) {
      final controller = windowsTabControllers[activeTab];
      if (controller == null || !controller.value.isInitialized) return home();
      return Column(
        children: [
          webNavigationBar(),
          Expanded(child: win.Webview(controller)),
        ],
      );
    }
    if (section == "Web") {
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        final tabId = activeTab;
        final url = tabUrls[tabId];
        if (url == null) return home();
        return Column(
          children: [
            webNavigationBar(),
            if (tabLoading[tabId] == true) const LinearProgressIndicator(),
            Expanded(
              child: desktop.InAppWebView(
                initialSettings: desktop.InAppWebViewSettings(
                  isInspectable: kDebugMode,
                  incognito: false,
                  cacheEnabled: true,
                  clearCache: false,
                ),
                key: ValueKey("desktop_web_$tabId"),
                initialUrlRequest: desktop.URLRequest(url: desktop.WebUri(url)),
                onWebViewCreated: (controller) {
                  desktopTabControllers[tabId] = controller;
                },
                onLoadStart: (controller, uri) {
                  if (mounted) setState(() => tabLoading[tabId] = true);
                },
                onReceivedError: (controller, request, error) {
                  debugPrint("999 WEBVIEW ERROR: ${error.description}");
                },
                onLoadStop: (controller, uri) {
                  if (mounted) {
                    setState(() {
                      tabLoading[tabId] = false;
                      if (uri != null) tabUrls[tabId] = uri.toString();
                    });
                  }
                },
              ),
            ),
          ],
        );
      }
      final controller = tabControllers[activeTab];
      if (controller == null) return home();
      return Column(
        children: [
          webNavigationBar(),
          if (tabLoading[activeTab] == true) const LinearProgressIndicator(),
          Expanded(
            child: WebViewWidget(
              key: ValueKey(activeTab),
              controller: controller,
            ),
          ),
        ],
      );
    }
    if (section == 'Home' || section == 'General') return home();
    if (section == 'Bookmarks') {
      return listPage('BOOKMARKS', bookmarks, (v) => go(v));
    }
    if (section == 'History') {
      return listPage('RECENT ACTIVITY (THIS SESSION)', recent, (v) => go(v));
    }
    if (section == 'Tabs') {
      return ListView.builder(
        itemCount: tabs.length,
        itemBuilder: (context, index) => ListTile(
          leading: Icon(
            (tabControllers.containsKey(index) || tabUrls.containsKey(index))
                ? Icons.language
                : Icons.add_box_outlined,
            color: gold,
          ),
          title: Text(tabs[index]),
          subtitle: Text(tabUrls[index] ?? 'New Tab'),
          selected: index == activeTab,
          trailing: IconButton(
            tooltip: 'Close Tab',
            icon: const Icon(Icons.close, color: gold),
            onPressed: () => closeBrowserTab(index),
          ),
          onTap: () => setState(() {
            activeTab = index;
            section =
                (tabControllers.containsKey(index) ||
                    tabUrls.containsKey(index))
                ? 'Web'
                : 'Home';
          }),
        ),
      );
    }
    if (section == 'AI Assistant') {
      return centerPage(
        '999 AI ASSISTANT',
        'AI interface shell. Connect an AI endpoint before enabling generated answers.',
        Icons.psychology,
      );
    }
    if (section == 'VPN / Privacy') return privacyCenter();
    if (section == 'Downloads' ||
        section == 'Extensions' ||
        section == 'Settings') {
      return centerPage(
        section.toUpperCase(),
        'Module awaiting integration.',
        Icons.settings,
      );
    }
    if (section == 'Search' || searched) return searchResults();
    return centerPage(
      section.toUpperCase(),
      'Workspace ready for future integration.',
      Icons.dashboard,
    );
  }

  Widget listPage(
    String title,
    List<String> values,
    void Function(String) onTap,
  ) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(title, style: const TextStyle(color: gold, fontSize: 22)),
      const SizedBox(height: 12),
      if (values.isEmpty) const Text('Nothing here yet.'),
      for (final value in values)
        ListTile(
          title: Text(value),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => onTap(value),
        ),
    ],
  );
  Widget centerPage(String title, String description, IconData icon) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 550),
      child: surface(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: cyan),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: gold,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            searchBox(),
          ],
        ),
      ),
    ),
  );

  Widget searchResults() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        '$category SEARCH',
        style: const TextStyle(
          color: gold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 14),
      searchBox(),
      const SizedBox(height: 15),
      if (loading) const Center(child: CircularProgressIndicator()),
      if (error != null)
        Text(error!, style: const TextStyle(color: Colors.orangeAccent)),
      if (!loading && error == null && results.isEmpty)
        const Text('No results yet. Enter a search query.'),
      for (final item in results)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => go('${item['url'] ?? ''}'),
                  child: Text(
                    '${item['title'] ?? item['url'] ?? 'Result'}',
                    style: const TextStyle(
                      color: cyan,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item['url'] ?? ''}',
                  style: const TextStyle(color: gold, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text('${item['snippet'] ?? item['description'] ?? ''}'),
              ],
            ),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      bottomNavigationBar: wide
          ? null
          : SafeArea(
              top: false,
              child: Container(
                height: 92,
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF061329),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: GenesisColors.gold.withValues(alpha: .55),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    for (final item in <(String, IconData, String)>[
                      ("Home", Icons.home, "Home"),
                      ("Search", Icons.search, "Search"),
                    ])
                      Expanded(
                        child: InkWell(
                          onTap: () => navigate(item.$3),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.$2,
                                size: 27,
                                color: item.$1 == "Home"
                                    ? GenesisColors.gold
                                    : Colors.white70,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.$1,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: item.$1 == "Home"
                                      ? GenesisColors.gold
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: InkWell(
                          onTap: () => setState(() {
                            tabs.add("New Tab");
                            activeTab = tabs.length - 1;
                            section = "Home";
                            search.clear();
                            searched = false;
                          }),
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF061329),
                              border: Border.all(
                                color: GenesisColors.gold,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: GenesisColors.gold.withValues(
                                    alpha: .55,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 38,
                              color: GenesisColors.gold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => navigate("Tabs"),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.content_copy,
                              size: 26,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Tabs",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (c) => InkWell(
                          onTap: () => Scaffold.of(c).openDrawer(),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.apps, size: 28, color: Colors.white70),
                              SizedBox(height: 4),
                              Text(
                                "Menu",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      drawer: wide ? null : Drawer(child: sidebar()),
      body: SafeArea(
        child: Row(
          children: [
            if (wide) sidebar(),
            Expanded(
              child: Column(
                children: [
                  if (!wide)
                    Container(
                      color: panel,
                      child: Row(
                        children: [
                          Builder(
                            builder: (c) => IconButton(
                              onPressed: () => Scaffold.of(c).openDrawer(),
                              icon: const Icon(Icons.menu),
                            ),
                          ),
                          const Text(
                            '999 BROWSER',
                            style: TextStyle(color: gold),
                          ),
                        ],
                      ),
                    ),
                  if (wide || section != "Home") topbar(),
                  Expanded(
                    child: Stack(
                      children: [
                        Offstage(
                          offstage:
                              section == "Web" &&
                              defaultTargetPlatform != TargetPlatform.macOS,
                          child:
                              section == "Web" &&
                                  defaultTargetPlatform != TargetPlatform.macOS
                              ? const SizedBox.shrink()
                              : sectionBody(),
                        ),
                        if (tabControllers.isNotEmpty)
                          Offstage(
                            offstage: section != "Web",
                            child: Column(
                              children: [
                                webNavigationBar(),
                                if (tabLoading[activeTab] == true)
                                  const LinearProgressIndicator(),
                                Expanded(child: persistentWebViews()),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
