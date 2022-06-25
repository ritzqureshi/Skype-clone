import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/universal_variables.dart';

class ShimmeringLogo extends StatelessWidget {
  const ShimmeringLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: Shimmer.fromColors(
        baseColor: UniversalVariables.blackColor,
        highlightColor: Colors.white,
        child: Image.asset("assets/app_logo.png"),
        period: const Duration(seconds: 1),
      ),
    );
  }
}
