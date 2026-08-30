import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'naraak_logo.dart';

class NaraakAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NaraakAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions = const [],
  });

  final String title;
  final bool showBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
        toolbarHeight: 64,
        automaticallyImplyLeading: showBack,
        leading: showBack
            ? IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : null,
        titleSpacing: showBack ? 0 : 16,
        title: Row(
          children: [
            const NaraakLogo(size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: actions,
      );
}
