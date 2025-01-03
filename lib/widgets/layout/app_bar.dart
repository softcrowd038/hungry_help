import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function()? onPressed;
  const CustomAppBar({super.key, required this.onPressed});

  @override
  State<StatefulWidget> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late GifController _gifController;

  @override
  void initState() {
    super.initState();

    _gifController = GifController(vsync: this);
    _gifController.repeat(min: 0, max: 1, period: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.menu, color: theme.colorScheme.primary),
                  onPressed: widget.onPressed,
                ),
                Gif(
                  controller: _gifController,
                  image: const AssetImage('assets/images/logo6.png'),
                  height: MediaQuery.of(context).size.height * 0.09,
                  width: MediaQuery.of(context).size.width * 0.09,
                ),
                Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.015),
                  child: Text(
                    'Akshay Patra',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
