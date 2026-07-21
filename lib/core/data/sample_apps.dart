import '../models/app_models.dart';

const List<String> defaultAllowedPackageHints = [
  'phone',
  'dialer',
  'whatsapp',
  'messages',
  'sms',
  'gmail',
  'email',
  'maps',
  'camera',
];

const List<String> defaultBlockedPackageHints = [
  'instagram',
  'youtube',
  'tiktok',
  'snapchat',
  'facebook',
  'x',
  'twitter',
  'reddit',
  'game',
  'games',
  'browser',
  'adult',
];

List<InstalledApp> seededSampleApps() => const [
  InstalledApp(name: 'Phone', packageName: 'com.android.dialer', isEssential: true),
  InstalledApp(name: 'Messages', packageName: 'com.google.android.apps.messaging', isEssential: true),
  InstalledApp(name: 'WhatsApp', packageName: 'com.whatsapp', isEssential: true),
  InstalledApp(name: 'Gmail', packageName: 'com.google.android.gm', isEssential: true),
  InstalledApp(name: 'Google Maps', packageName: 'com.google.android.apps.maps', isEssential: true),
  InstalledApp(name: 'Camera', packageName: 'com.android.camera', isEssential: true),
  InstalledApp(name: 'Instagram', packageName: 'com.instagram.android'),
  InstalledApp(name: 'YouTube', packageName: 'com.google.android.youtube'),
  InstalledApp(name: 'TikTok', packageName: 'com.zhiliaoapp.musically'),
  InstalledApp(name: 'Snapchat', packageName: 'com.snapchat.android'),
  InstalledApp(name: 'X', packageName: 'com.twitter.android'),
  InstalledApp(name: 'Facebook', packageName: 'com.facebook.katana'),
  InstalledApp(name: 'Reddit', packageName: 'com.reddit.frontpage'),
  InstalledApp(name: 'Chrome', packageName: 'com.android.chrome'),
  InstalledApp(name: 'Simple Game', packageName: 'com.example.game'),
];
