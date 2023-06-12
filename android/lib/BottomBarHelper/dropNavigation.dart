library water_drop_nav_bar;

import 'package:flutter/material.dart';

import 'bar_item.dart';
import 'build_nav_bar.dart';

export 'bar_item.dart';

class DropNavigation extends StatelessWidget {
  final Color backgroundColor;
  final OnButtonPressCallback onItemSelected;
  final int selectedIndex;
  final List<BarItem> barItems;
  final Color waterDropColor;
  final Color inactiveIconColor;

  final double iconSize;
  final double? bottomPadding;

  const DropNavigation({
    required this.barItems,
    required this.selectedIndex,
    required this.onItemSelected,
    this.bottomPadding,
    this.backgroundColor = Colors.white,
    this.waterDropColor = Colors.red,
    this.iconSize = 28,
    Color? inactiveIconColor,
    Key? key,
  })  : inactiveIconColor = inactiveIconColor ?? waterDropColor,
        assert(barItems.length > 1, 'You must provide minimum 2 bar items'),
        assert(barItems.length < 5, 'Maximum bar items count is 4'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BuildNavBar(
      itmes: barItems,
      backgroundColor: backgroundColor,
      selectedIndex: selectedIndex,
      onItemSelected: onItemSelected,
      dropColor: waterDropColor,
      iconSize: iconSize,
      inactiveIconColor: inactiveIconColor,
      bottomPadding: bottomPadding,
    );
  }
}
