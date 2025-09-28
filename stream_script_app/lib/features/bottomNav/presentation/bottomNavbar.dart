import 'package:flutter/material.dart';
import './bottomNav_pages.dart';

class BottomNavbar extends StatefulWidget {
	const BottomNavbar({super.key});

	@override
	State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
	int _selectedIndex = 0;

		final List<Widget> _pages = [
			PatientsScreen(),
			RecordScreen(),
			SettingsScreen(),
		];

	void _onItemTapped(int index) {
		setState(() {
			_selectedIndex = index;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: _pages[_selectedIndex],
			bottomNavigationBar: Container(
				decoration: BoxDecoration(
					color: const Color(0xFF4A7C7E),
					boxShadow: [
						BoxShadow(
							color: Colors.black.withOpacity(0.08),
							blurRadius: 8,
						),
					],
				),
				child: BottomNavigationBar(
					currentIndex: _selectedIndex,
					onTap: _onItemTapped,
					backgroundColor: const Color(0xFF4A7C7E),
					selectedItemColor: Colors.white,
					unselectedItemColor: Colors.white70,
					showSelectedLabels: true,
					showUnselectedLabels: true,
					type: BottomNavigationBarType.fixed,
					items: const [
						BottomNavigationBarItem(
							icon: Icon(Icons.people_alt_outlined),
							label: 'Patients',
						),
						BottomNavigationBarItem(
							icon: Icon(Icons.mic_none_outlined),
							label: 'Record',
						),
						BottomNavigationBarItem(
							icon: Icon(Icons.settings_outlined),
							label: 'Settings',
						),
					],
				),
			),
		);
	}
}
