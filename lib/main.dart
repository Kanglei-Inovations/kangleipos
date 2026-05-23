import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/services/preference_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = await PreferenceService().init();
  Get.put(prefService, permanent: true);

  final database = AppDatabase();
  Get.put(database, permanent: true);

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await windowManager.ensureInitialized();

    final width = prefService.windowWidth;
    final height = prefService.windowHeight;

    final windowOptions = WindowOptions(
      size: Size(width, height),
      minimumSize: const Size(1920, 1080),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Kanglei POS',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Add listener to save window size changes
    windowManager.addListener(_WindowSizeListener(prefService));
  }

  ResponsiveSizingConfig.instance.setCustomBreakpoints(
    const ScreenBreakpoints(desktop: 1024, tablet: 768, watch: 200),
  );

  runApp(const KangleiPOS());
}

class _WindowSizeListener extends WindowListener {
  final PreferenceService _prefService;
  _WindowSizeListener(this._prefService);

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    await _prefService.setWindowWidth(size.width);
    await _prefService.setWindowHeight(size.height);
  }

  @override
  void onWindowMoved() async {
    // Optional: save position too if needed
  }
}

class KangleiPOS extends StatelessWidget {
  final Widget? home;

  const KangleiPOS({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppThemeController(),
      child: Consumer<AppThemeController>(
        builder: (context, themeController, _) {
          return GetMaterialApp(
            title: 'Kanglei POS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: home,
            initialRoute: home == null ? AppRoutes.AUTH : null,
            getPages: AppPages.pages,
            defaultTransition: Transition.fadeIn,
            builder: (context, child) {
              return ResponsiveBreakpoints.builder(
                child: child ?? const SizedBox.shrink(),
                breakpoints: const [
                  Breakpoint(start: 0, end: 599, name: MOBILE),
                  Breakpoint(start: 600, end: 1023, name: TABLET),
                  Breakpoint(start: 1024, end: 1919, name: DESKTOP),
                  Breakpoint(start: 1920, end: double.infinity, name: '4K'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
