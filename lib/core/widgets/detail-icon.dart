// import 'package:flutter/material.dart';
// import 'package:pos/utils/app-theme.dart';

// class DetailIcon extends StatelessWidget {
//   const DetailIcon({
//     super.key,
//     required this.onDetail,
//     this.top = 7,
//     this.right = 2,
//     this.centerVertical = false,
//   });

//   final VoidCallback? onDetail;

//   final double top;
//   final double right;
//   final bool centerVertical;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: centerVertical ? 0 : top,
//       bottom: centerVertical ? 0 : null,
//       right: right,
//       child: Align(
//         alignment: Alignment.center,
//         child: IconButton(
//           icon: const Icon(Icons.info_outline, color: kBlue, size: 25),
//           tooltip: 'Details',
//           onPressed: onDetail,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';

class DetailIcon extends StatelessWidget {
  const DetailIcon({super.key, required this.onDetail});

  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline, color: kBlue, size: 25),
      tooltip: 'Details',
      onPressed: onDetail,
    );
  }
}
