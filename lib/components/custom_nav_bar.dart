
import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.computer),
            onPressed: () => widget.onItemTapped(0),
            color: widget.selectedIndex == 0 ? Theme.of(context).primaryColor : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => widget.onItemTapped(1),
            color: widget.selectedIndex == 1 ? Theme.of(context).primaryColor : Colors.grey,
          ),
          const SizedBox(width: 48), // The space for the FAB
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () => widget.onItemTapped(3),
            color: widget.selectedIndex == 3 ? Theme.of(context).primaryColor : Colors.grey,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => widget.onItemTapped(4),
            color: widget.selectedIndex == 4 ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }
}
