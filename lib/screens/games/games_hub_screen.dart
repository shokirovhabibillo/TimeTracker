import 'package:flutter/material.dart';

import 'lightbulb_game_screen.dart';
import 'season_tree_game_screen.dart';
import 'spinner_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kunlik o'yinlar")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Har biri kuniga faqat bir marta, 30 soniyaga — asabni bosish yoki diqqatni "
              "biroz chalg'itish uchun qisqa tanaffus.",
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.emoji_objects_outlined)),
              title: const Text('Lampochka'),
              subtitle: const Text("Ipni tortib, lampochkani yoritib boring"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LightbulbGameScreen())),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.park_outlined)),
              title: const Text("To'rt fasl daraxti"),
              subtitle: const Text("Slayderni surib, daraxtni fasldan-faslga o'tkazing"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SeasonTreeGameScreen())),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.casino_outlined)),
              title: const Text('Spiner'),
              subtitle: const Text("Tasodifiy vazifa va bonus multiplikator tanlang (cheklovsiz)"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpinnerScreen())),
            ),
          ),
        ],
      ),
    );
  }
}
