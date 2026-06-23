import 'package:get/get.dart';

import '../modules/catalog/bindings/catalog_binding.dart';
import '../modules/catalog/views/catalog_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edukasi/bindings/edukasi_binding.dart';
import '../modules/edukasi/views/edukasi_view.dart';
import '../modules/anggota/bindings/anggota_binding.dart';
import '../modules/anggota/views/anggota_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/lensa_natrium/bindings/lensa_natrium_binding.dart';
import '../modules/lensa_natrium/views/lensa_natrium_view.dart';
import '../modules/lensa_natrium_detail/bindings/lensa_natrium_detail_binding.dart';
import '../modules/lensa_natrium_detail/views/lensa_natrium_detail_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_navigation/bindings/main_navigation_binding.dart';
import '../modules/main_navigation/views/main_navigation_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/riwayat/bindings/riwayat_binding.dart';
import '../modules/riwayat/views/riwayat_view.dart';
import '../modules/riwayat_login/bindings/riwayat_login_binding.dart';
import '../modules/riwayat_login/views/riwayat_login_view.dart';
import '../modules/scanner/bindings/scanner_binding.dart';
import '../modules/scanner/views/scanner_view.dart';
import '../modules/semua_menu/bindings/semua_menu_binding.dart';
import '../modules/semua_menu/views/semua_menu_view.dart';
import '../modules/informasi_kesehatan/bindings/informasi_kesehatan_binding.dart';
import '../modules/informasi_kesehatan/views/informasi_kesehatan_view.dart';
import '../modules/informasi_kesehatan_detail/bindings/informasi_kesehatan_detail_binding.dart';
import '../modules/informasi_kesehatan_detail/views/informasi_kesehatan_detail_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/verifikasi_email/bindings/verifikasi_email_binding.dart';
import '../modules/verifikasi_email/views/verifikasi_email_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.MAIN_NAVIGATION,
      page: () => const MainNavigationView(),
      binding: MainNavigationBinding(),
    ),
    GetPage(
      name: _Paths.SCANNER,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: _Paths.ANGGOTA,
      page: () => const AnggotaView(),
      binding: AnggotaBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT,
      page: () => const RiwayatView(),
      binding: RiwayatBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: _Paths.CATALOG,
      page: () => const CatalogView(),
      binding: CatalogBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.LENSA_NATRIUM,
      page: () => const LensaNatriumView(),
      binding: LensaNatriumBinding(),
    ),
    GetPage(
      name: _Paths.LENSA_NATRIUM_DETAIL,
      page: () => const LensaNatriumDetailView(),
      binding: LensaNatriumDetailBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.EDUKASI,
      page: () => const EdukasiView(),
      binding: EdukasiBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYAT_LOGIN,
      page: () => const RiwayatLoginView(),
      binding: RiwayatLoginBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.VERIFIKASI_EMAIL,
      page: () => const VerifikasiEmailView(),
      binding: VerifikasiEmailBinding(),
    ),
    GetPage(
      name: _Paths.SEMUA_MENU,
      page: () => const SemuaMenuView(),
      binding: SemuaMenuBinding(),
    ),
    GetPage(
      name: _Paths.INFORMASI_KESEHATAN,
      page: () => const InformasiKesehatanView(),
      binding: InformasiKesehatanBinding(),
    ),
    GetPage(
      name: _Paths.INFORMASI_KESEHATAN_DETAIL,
      page: () => const InformasiKesehatanDetailView(),
      binding: InformasiKesehatanDetailBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
  ];
}
