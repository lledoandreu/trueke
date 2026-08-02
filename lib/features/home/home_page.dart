import 'package:flutter/material.dart';

import '../../data/sample_products.dart';
import 'widgets/category_chip.dart';
import 'widgets/home_header.dart';
import 'widgets/product_card.dart';
import 'widgets/search_bar_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const HomeHeader(),
            const SearchBarWidget(),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(
              height: 110,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CategoryChip(
                      icon: Icons.phone_iphone,
                      label: 'Electrónica',
                    ),
                    CategoryChip(icon: Icons.checkroom, label: 'Moda'),
                    CategoryChip(icon: Icons.chair, label: 'Hogar'),
                    CategoryChip(icon: Icons.sports_esports, label: 'Gaming'),
                    CategoryChip(icon: Icons.directions_bike, label: 'Deporte'),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Recomendados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            ProductCard(product: sampleProducts[0]),
            ProductCard(product: sampleProducts[1]),
            ProductCard(product: sampleProducts[2]),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Publicar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
