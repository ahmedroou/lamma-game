import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_controller.dart';
import 'core/app_scope.dart';
import 'core/app_theme.dart';
import 'data/repositories/local_game_repository.dart';
import 'data/storage/open_local_store.dart';
import 'features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
    ),
  );
  runApp(const LammaBootstrap());
}

class LammaBootstrap extends StatefulWidget {
  const LammaBootstrap({super.key});
  @override
  State<LammaBootstrap> createState() => _LammaBootstrapState();
}

class _LammaBootstrapState extends State<LammaBootstrap> {
  AppController? _controller;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    AppController? controller;
    try {
      controller = AppController(await openLocalStore());
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on Object {
      controller?.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _controller != null
      ? LammaApp(controller: _controller)
      : MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: _failed
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.save_outlined,
                              size: 48,
                              color: AppColors.peach,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'تعذّر فتح الحفظ المحلي',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'بياناتك لم تُحذف. أعد المحاولة قبل بدء اللعب.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _load,
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        );
}

class LammaApp extends StatefulWidget {
  const LammaApp({super.key, this.controller});
  final AppController? controller;
  @override
  State<LammaApp> createState() => _LammaAppState();
}

class _LammaAppState extends State<LammaApp> with WidgetsBindingObserver {
  late final AppController _controller =
      widget.controller ?? AppController(MemoryGameRepository());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_controller.ready) unawaited(_controller.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.foreground();
    } else {
      _controller.background();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    controller: _controller,
    child: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => MaterialApp(
        title: 'لَمّة',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                MediaQuery.disableAnimationsOf(context) ||
                !_controller.settings.motion,
          ),
          child: child!,
        ),
        home: _controller.ready
            ? const HomeScreen()
            : const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    ),
  );
}
