// class CustomBottomBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTabSelected;

//   const CustomBottomBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTabSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildTabItem(Icons.shopping_bag, "Shop", 0),
//           _buildTabItem(Icons.sim_card, "My eSIM", 1),
//           _buildCenterButton(),
//           _buildTabItem(Icons.help_outline, "Help", 2),
//           _buildTabItem(Icons.person_outline, "Profile", 3),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabItem(IconData icon, String label, int index) {
//     final isSelected = currentIndex == index;
//     final color = isSelected ? Colors.purple : Colors.grey;

//     return GestureDetector(
//       onTap: () => onTabSelected(index),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(color: color, fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildCenterButton() {
//     return GestureDetector(
//       onTap: () {
//         // Open modal or navigate
//       },
//       child: Transform.rotate(
//         angle: 0.785398,
//         child: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Colors.purple,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Transform.rotate(
//             angle: -0.785398,
//             child: const Icon(Icons.add, color: Colors.white, size: 30),
//           ),
//         ),
//       ),
//     );
//   }
// }
