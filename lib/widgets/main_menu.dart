import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/data/todo.dart';
import 'package:flutter_timemanagement/screen/add_screen.dart';
import 'package:flutter_timemanagement/screen/calendar_screen.dart';
import 'package:flutter_timemanagement/screen/dialog_supported_screen.dart';
import 'package:flutter_timemanagement/screen/home_screen.dart';
import 'package:flutter_timemanagement/screen/pomodoro_screen.dart';
import 'package:flutter_timemanagement/screen/todo_screen.dart';
import 'package:flutter_timemanagement/util/navigation_helper.dart';
import 'package:flutter_timemanagement/util/navigation_notifier.dart';
import 'package:flutter_timemanagement/util/pomodoro_notifier.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 3);
  final NavigationNotifier notifier = NavigationNotifier();
  final PomodoroNotifier pomodoroNotifier = PomodoroNotifier();

  @override
  void initState() {
    NavigationHelper.jumpToPomodoroScreenFunction = (Todo t)
    {
        _controller.jumpToTab(4);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
        body: MultiProvider(
            providers: [ ChangeNotifierProvider<NavigationNotifier>(create: (_) => notifier),
            ChangeNotifierProvider<PomodoroNotifier>(create: (_) => pomodoroNotifier)],
          child: PersistentTabView(
                context,
                controller: _controller,
                screens: _buildScreens(),
                items: _navBarsItems(),
                confineInSafeArea: true,
                backgroundColor: Colors.transparent,
                // Default is Colors.white.
                handleAndroidBackButtonPress: true,
                // Default is true.
                resizeToAvoidBottomInset: false,
                navBarHeight: 50,
                // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
                stateManagement: true,
                // Default is true.
                hideNavigationBarWhenKeyboardShows: true,
                // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
                decoration: NavBarDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(200),
                  ),
                  border: Border.all(
                    width: 0.1,
                    color: Colors.indigo,
                  ),
                  colorBehindNavBar: Colors.transparent,
                ),
                popAllScreensOnTapOfSelectedTab: true,
                popActionScreens: PopActionScreensType.all,
                itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
                  duration: Duration(milliseconds: 450),
                  curve: Curves.fastLinearToSlowEaseIn,
                ),
                screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
                  animateTabTransition: true,
                  curve: Curves.fastLinearToSlowEaseIn,
                  duration: Duration(milliseconds: 450),
                ),
                navBarStyle: NavBarStyle
                    .style14, // Choose the nav bar style with this property.
              ),
        ),
        );
  }

  List<Widget> _buildScreens() {
    return [
      DialogSupportedScreen(screen: HomeScreen()),
      DialogSupportedScreen(screen: CalendarScreen()),
      DialogSupportedScreen(screen: AddScreen()),
      DialogSupportedScreen(screen: TodoScreen()),
      PomodoroScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [

      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home, size: 20),
        title: ("Home"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.calendar, size: 20),
        title: ("Calendar"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.add, size: 20),
          title: ("Add"),
          activeColorSecondary: Colors.blue,
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: CupertinoColors.systemGrey,
          inactiveColorSecondary: Colors.red
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.check_mark, size: 20),
        title: ("Todo"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.circle_grid_hex_fill, size: 20),
        title: ("Pomodoro"),
        activeColorPrimary: Colors.blueAccent,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
}