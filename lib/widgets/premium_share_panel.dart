import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class PremiumSharePanel extends StatelessWidget {
  const PremiumSharePanel({
    super.key,
    required this.url,
    required this.onShare,
    required this.onDock,
  });
  final String url;
  final VoidCallback onShare;
  final VoidCallback onDock;
  @override
  Widget build(BuildContext context) => Container(
    width: 340,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF091B35),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFFFCA64), width: 1.2),
      boxShadow: const [BoxShadow(color: Color(0x6621D8FF), blurRadius: 24)],
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '999 SHARE',
              style: TextStyle(
                color: Color(0xFFFFCA64),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              url,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            const Text(
              "SOCIAL SHARE",
              style: TextStyle(
                color: Color(0xFFFFCA64),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                for (final item in <(String, String, Color)>[
                  ("Facebook", "f", Color(0xFF1877F2)),
                  ("X", "X", Color(0xFF242424)),
                  ("WhatsApp", "W", Color(0xFF25D366)),
                  ("Telegram", "T", Color(0xFF229ED9)),
                  ("LinkedIn", "in", Color(0xFF0A66C2)),
                  ("Pinterest", "P", Color(0xFFBD081C)),
                  ("Reddit", "r", Color(0xFFFF4500)),
                  ("TikTok", "♪", Color(0xFF191919)),
                  ("Instagram", "IG", Color(0xFFC13584)),
                  ("Snapchat", "S", Color(0xFFFFFC00)),
                  ("Threads", "@", Color(0xFF333333)),
                ])
                  SizedBox(
                    width: 65,
                    child: InkWell(
                      onTap: () async {
                        final links = <String, String>{
                          "Facebook":
                              "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}",
                          "X":
                              "https://twitter.com/intent/tweet?url=${Uri.encodeComponent(url)}",
                          "WhatsApp":
                              "https://api.whatsapp.com/send?text=${Uri.encodeComponent(url)}",
                          "Telegram":
                              "https://t.me/share/url?url=${Uri.encodeComponent(url)}",
                          "LinkedIn":
                              "https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}",
                          "Pinterest":
                              "https://pinterest.com/pin/create/button/?url=${Uri.encodeComponent(url)}",
                          "Reddit":
                              "https://www.reddit.com/submit?url=${Uri.encodeComponent(url)}",
                        };
                        final target = links[item.$1];
                        if (target != null) {
                          await Process.run("open", ["-a", "Safari", target]);
                        } else {
                          await Clipboard.setData(ClipboardData(text: url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${item.$1}: link copied for sharing",
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: item.$3,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              item.$2,
                              style: TextStyle(
                                color: item.$1 == "Snapchat"
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF21D8FF), height: 26),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(Icons.airplay, color: Color(0xFF21D8FF)),
              ),
              title: const Text(
                'AirDrop',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                await Process.run("open", [
                  "/System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app",
                ]);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF21D8FF),
                ),
              ),
              title: const Text(
                'Email This Page',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                await Process.run('open', [
                  '-a',
                  '/Users/jontariuscooper/Applications/Titan.app',
                ]);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.alternate_email,
                  color: Color(0xFF21D8FF),
                ),
              ),
              title: const Text(
                'Email Link to This Page',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                await Process.run('open', [
                  '-a',
                  '/Users/jontariuscooper/Applications/Titan.app',
                ]);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF21D8FF),
                ),
              ),
              title: const Text(
                'Messages',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                await Process.run("open", [
                  "-a",
                  "Messages",
                  "sms:?body=${Uri.encodeComponent(url)}",
                ]);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.sticky_note_2_outlined,
                  color: Color(0xFF21D8FF),
                ),
              ),
              title: const Text('Notes', style: TextStyle(color: Colors.white)),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                await Process.run("open", ["-a", "Notes"]);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(Icons.checklist, color: Color(0xFF21D8FF)),
              ),
              title: const Text(
                'Reminders',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.draw_outlined,
                  color: Color(0xFF21D8FF),
                ),
              ),
              title: const Text(
                'Freeform',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF21D8FF),
                ),
              ),
              title: const Text(
                'Journal',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(Icons.ios_share, color: Color(0xFF21D8FF)),
              ),
              title: const Text(
                'Share Website',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'Add to Reading List',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.bookmark_add_outlined,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'Add to Bookmarks',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.bookmarks_outlined,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'Add Bookmark To...',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.edit_note_outlined,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'New Quick Note',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.content_copy_outlined,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'Copy Link',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.extension_outlined,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'Edit Extensions...',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onShare,
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF142F50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55FFCA64)),
                ),
                child: const Icon(
                  Icons.add_to_home_screen,
                  color: Color(0xFFFFCA64),
                ),
              ),
              title: const Text(
                'Add to Dock',
                style: TextStyle(color: Colors.white),
              ),
              onTap: onDock,
            ),
          ],
        ),
      ),
    ),
  );
}
