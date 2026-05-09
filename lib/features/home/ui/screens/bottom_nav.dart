import 'package:evento_app/app/app_colors.dart';
import 'package:evento_app/app/assets_path.dart';
import 'package:evento_app/features/account/ui/screens/account_screen.dart';
import 'package:evento_app/features/events/ui/screens/events_screen.dart';
import 'package:evento_app/features/home/ui/screens/home_screen.dart';
import 'package:evento_app/features/organizers/ui/screens/organizers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:evento_app/features/events/providers/events_provider.dart';
import 'package:evento_app/features/auth/providers/auth_provider.dart';
import 'package:evento_app/app/app_routes.dart';
import 'package:evento_app/features/home/providers/nav_provider.dart';
import 'package:evento_app/features/home/ui/widgets/keep_alive_wrapper.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late final PageController _pageController;
  late final NavProvider _nav;
  VoidCallback? _navListener;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _nav = context.read<NavProvider>();
    _pageController = PageController(initialPage: widget.initialIndex);

    _navListener = () {
      final idx = _nav.index;
      if (!_pageController.hasClients) return;
      final current =
          _pageController.page?.round() ?? _pageController.initialPage;
      if (current != idx) {
        _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    };
    _nav.addListener(_navListener!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nav.setIndex(widget.initialIndex);
      _lastIndex = widget.initialIndex;
      final args = Get.arguments;
      if (args is Map) {
        int? catId;
        String? catName;
        String? catSlug;
        if (args['categoryId'] is int) catId = args['categoryId'] as int;
        if (args['categoryName'] is String) {
          catName = args['categoryName'] as String;
        }
        if (args['categorySlug'] is String) {
          catSlug = args['categorySlug'] as String;
        }
        final wantFilter =
            (catId != null) || ((catName ?? '').trim().isNotEmpty);
        if (wantFilter) {
          final eventsProv = context.read<EventsProvider>();
          eventsProv.ensureInitialized(perPage: 15).then((_) {
            eventsProv.setCategoryFilter(
              id: catId,
              name: catName,
              slug: catSlug,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (_navListener != null) {
      _nav.removeListener(_navListener!);
      _navListener = null;
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavProvider>().index;
    final authed = context.watch<AuthProvider>().token != null;
    final accountPage = (currentIndex == 3 && authed)
        ? const KeepAliveWrapper(child: AccountScreen())
        : const SizedBox.shrink();
    return Scaffold(
      body: PageView(
        controller: _pageController,
        allowImplicitScrolling: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const KeepAliveWrapper(child: HomeScreen()),
          const KeepAliveWrapper(child: EventsScreen()),
          const KeepAliveWrapper(child: Organizers()),
          accountPage,
        ],
        onPageChanged: (i) {
          FocusManager.instance.primaryFocus?.unfocus();
          if (_lastIndex == 1 && i != 1) {
            try {
              context.read<EventsProvider>().clearAllFilters();
            } catch (_) {}
          }
          _lastIndex = i;
          _nav.setIndex(i);
        },
      ),
      bottomNavigationBar: _buildBottomBar(context, currentIndex),
    );
  }

  Future<void> _onTappedItem(int index) async {
    if (index == 0 || index == 1 || index == 2) {
      _nav.setIndex(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
        );
      }
      return;
    }

    final authed = context.read<AuthProvider>().token != null;
    if (!authed) {
      final result = await Navigator.of(context).pushNamed(
        AppRoutes.login,
        arguments: {'redirectToHome': false, 'popOnSuccess': true},
      );
      if (!mounted) return;
      final nowAuthed = context.read<AuthProvider>().token != null;
      if (result == true && nowAuthed) {
        _nav.setIndex(index);
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    } else {
      _nav.setIndex(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex) {
    return Container(
      height: 84,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          _buildNavItem(0, 'Home', AssetsPath.homeSvg, currentIndex),
          _buildNavItem(1, 'Events', AssetsPath.eventSvg, currentIndex),
          _buildNavItem(2, 'Organizers', AssetsPath.orgSvg, currentIndex),
          _buildNavItem(3, 'Account', AssetsPath.accountSvg, currentIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    String iconPath,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryColor : Colors.grey.shade800;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTappedItem(index),
          borderRadius: BorderRadius.circular(99),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  iconPath,
                  height: 32,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(height: 4),
                Text(
                  label.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
