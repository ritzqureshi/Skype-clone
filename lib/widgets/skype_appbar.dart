import 'package:flutter/material.dart';

import '../../widgets/appbar.dart';

class SkypeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> actions;

  const SkypeAppBar({
    Key? key,
    required this.title,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.notifications,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      title: title,
      centerTitle: true,
      actions: actions,
    );
  }

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}
