import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_scope.dart';
import '../../core/app_theme.dart';
import '../../domain/models/app_release.dart';
import 'app_update_view_model.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key, this.model});
  final AppUpdateViewModel? model;
  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  late final AppUpdateViewModel model =
      widget.model ??
      AppUpdateViewModel(
        beforeInstall: () async {
          final app = AppScope.maybeRead(context);
          app?.session?.pause();
          await app?.flush();
        },
      );
  @override
  void initState() {
    super.initState();
    model.initialize();
  }

  @override
  void dispose() {
    if (widget.model == null) model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تحديث لَمّة')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListenableBuilder(
            listenable: model,
            builder: (context, _) => SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.system_update_rounded,
                    size: 70,
                    color: AppColors.lime,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'أحدث لَمّة، ومحفوظاتك معك',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الإصدار المثبّت: ${model.installed?.version ?? '…'}${model.installed == null ? '' : ' (${model.installed!.buildNumber})'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الفحص والتنزيل يحتاجان الإنترنت. اللعب والأسئلة المحفوظة تعمل محليًا. لا تحذف التطبيق عند التحديث حتى تبقى إعداداتك ومباراتك وسجل الأسئلة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.7),
                  ),
                  const SizedBox(height: 24),
                  if (!model.supported) ...[
                    const Text(
                      'التنزيل والتثبيت داخل التطبيق متاحان في نسخة Android. من هذه المعاينة يمكنك تحميل APK لجهاز Android؛ أجهزة iPhone تحتاج إصدارًا عبر TestFlight أو App Store.',
                      style: TextStyle(color: AppColors.gold, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (!await launchUrl(
                              AppRelease.downloadPage,
                              mode: LaunchMode.externalApplication,
                            ) &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تعذّر فتح صفحة التحميل.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('تحميل إصدار Android'),
                    ),
                  ],
                  if (model.release != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإصدار المنشور: ${model.release!.version} (${model.release!.buildNumber})',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'حجم التنزيل: ${(model.release!.size / 1024 / 1024).toStringAsFixed(1)} ميجابايت',
                            ),
                            if (model.release!.notes.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                model.release!.notes,
                                style: const TextStyle(height: 1.6),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (model.status == UpdateStatus.downloading) ...[
                    LinearProgressIndicator(value: model.progress),
                    const SizedBox(height: 10),
                    Text(
                      'جارٍ التنزيل والتحقق… ${(model.progress * 100).floor()}٪',
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: model.cancelDownload,
                      child: const Text('إلغاء التنزيل'),
                    ),
                  ] else if (model.status == UpdateStatus.checking) ...[
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12),
                    const Text('جارٍ الفحص…', textAlign: TextAlign.center),
                  ] else ...[
                    if (model.status == UpdateStatus.current)
                      const Text(
                        'لديك أحدث إصدار متاح.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.lime),
                      ),
                    if (model.status == UpdateStatus.noRelease)
                      const Text(
                        'لم يُنشر إصدار Android مكتمل بعد. أعد الفحص لاحقًا.',
                        textAlign: TextAlign.center,
                      ),
                    if (model.error != null)
                      Text(
                        model.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.peach),
                      ),
                    if (model.status == UpdateStatus.permission) ...[
                      const Text(
                        'Android يحتاج إذن «السماح من هذا المصدر» لتثبيت تحديث لَمّة. فعّله ثم عد واضغط «تثبيت التحديث».',
                        style: TextStyle(color: AppColors.gold, height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: model.openPermission,
                        icon: const Icon(Icons.settings_outlined),
                        label: const Text('السماح بتثبيت التحديث'),
                      ),
                    ],
                    if (model.status == UpdateStatus.installerOpened)
                      const Text(
                        'فُتحت نافذة تثبيت Android. أكّد التثبيت هناك؛ إذا ألغيت يمكنك المحاولة مجددًا.',
                        style: TextStyle(color: AppColors.gold, height: 1.6),
                      ),
                    if (model.downloadedPath != null && model.supported)
                      FilledButton.icon(
                        onPressed: model.install,
                        icon: const Icon(Icons.install_mobile_rounded),
                        label: const Text('تثبيت التحديث'),
                      )
                    else if (model.release != null &&
                        model.installed != null &&
                        model.release!.buildNumber >
                            model.installed!.buildNumber &&
                        model.supported)
                      FilledButton.icon(
                        onPressed: model.download,
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('تنزيل التحديث'),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: model.check,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('فحص التحديثات'),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Text(
                    'الإصدارات من مستودع لَمّة الرسمي على GitHub. يُفحص ملف التحديث قبل فتحه، ويؤكد Android هوية التطبيق وتوقيعه عند التثبيت.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
