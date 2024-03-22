import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: NavigationBar(
        indicatorColor: Color(0xfffceee7),
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: Color(0xfff57b51),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Color(0xfffceee7),
              ),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.space_dashboard_outlined,
              color: Color(0xfffceee7),
              ),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Workspaces',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,
              color: Color(0xfffceee7),
            ),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.notifications_outlined,
              color: Color(0xfffceee7),
            ),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Color(0xfffceee7),
            ),
            selectedIcon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
