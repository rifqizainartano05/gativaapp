import 'package:get/get.dart';

import '../modules/scan_dokter_akses/bindings/scan_dokter_akses_binding.dart';
import '../modules/scan_dokter_akses/views/scan_dokter_akses_view.dart';

import '../modules/anggota/bindings/anggota_binding.dart';
import '../modules/anggota/views/anggota_view.dart';
import '../modules/catatan_nakes/bindings/catatan_nakes_binding.dart';
import '../modules/catatan_nakes/bindings/catatan_nakes_binding.dart';
import '../modules/catatan_nakes/views/catatan_nakes_view.dart';
import '../modules/catatan_nakes/views/catatan_nakes_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/detail_dokter/bindings/detail_dokter_binding.dart';
import '../modules/detail_dokter/views/detail_dokter_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edukasi/bindings/edukasi_binding.dart';
import '../modules/edukasi/views/edukasi_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/informasi_kesehatan/bindings/informasi_kesehatan_binding.dart';
import '../modules/informasi_kesehatan/views/informasi_kesehatan_view.dart';
import '../modules/informasi_kesehatan_detail/bindings/informasi_kesehatan_detail_binding.dart';
import '../modules/informasi_kesehatan_detail/views/informasi_kesehatan_detail_view.dart';
import '../modules/katalog/bindings/katalog_binding.dart';
import '../modules/katalog/views/katalog_view.dart';
import '../modules/lensa_natrium/bindings/lensa_natrium_binding.dart';
import '../modules/lensa_natrium/views/lensa_natrium_view.dart';
import '../modules/lensa_natrium_detail/bindings/lensa_natrium_detail_binding.dart';
import '../modules/lensa_natrium_detail/views/lensa_natrium_detail_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_navigation/bindings/main_navigation_binding.dart';
import '../modules/main_navigation/views/main_navigation_view.dart';
import '../modules/nakes_bantuan_faq/bindings/nakes_bantuan_faq_binding.dart';
import '../modules/nakes_bantuan_faq/views/nakes_bantuan_faq_view.dart';
import '../modules/nakes_catalog/bindings/nakes_catalog_binding.dart';
import '../modules/nakes_catalog/views/nakes_catalog_view.dart';
import '../modules/nakes_chat/bindings/nakes_chat_binding.dart';
import '../modules/nakes_chat/views/nakes_chat_view.dart';
import '../modules/nakes_dashboard/bindings/nakes_dashboard_binding.dart';
import '../modules/nakes_dashboard/views/nakes_dashboard_view.dart';
import '../modules/nakes_detail_pasien_chat/bindings/nakes_detail_pasien_chat_binding.dart';
import '../modules/nakes_detail_pasien_chat/views/nakes_detail_pasien_chat_view.dart';
import '../modules/nakes_detail_pasien_gativa/bindings/nakes_detail_pasien_gativa_binding.dart';
import '../modules/nakes_detail_pasien_gativa/views/nakes_detail_pasien_gativa_view.dart';
import '../modules/nakes_edit_profile/bindings/nakes_edit_profile_binding.dart';
import '../modules/nakes_edit_profile/views/nakes_edit_profile_view.dart';
import '../modules/nakes_edukasi/bindings/nakes_edukasi_binding.dart';
import '../modules/nakes_edukasi/views/nakes_edukasi_view.dart';
import '../modules/nakes_ganti_kata_sandi/bindings/nakes_ganti_kata_sandi_binding.dart';
import '../modules/nakes_ganti_kata_sandi/views/nakes_ganti_kata_sandi_view.dart';
import '../modules/nakes_informasi_kesehatan/bindings/nakes_informasi_kesehatan_binding.dart';
import '../modules/nakes_informasi_kesehatan/views/nakes_informasi_kesehatan_view.dart';
import '../modules/nakes_pasien_gativa/bindings/nakes_pasien_gativa_binding.dart';
import '../modules/nakes_pasien_gativa/views/nakes_pasien_gativa_view.dart';
import '../modules/nakes_profile/bindings/nakes_profile_binding.dart';
import '../modules/nakes_profile/views/nakes_profile_view.dart';
import '../modules/nakes_tentang_aplikasi/bindings/nakes_tentang_aplikasi_binding.dart';
import '../modules/nakes_tentang_aplikasi/views/nakes_tentang_aplikasi_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
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
import '../modules/room_chat/bindings/room_chat_binding.dart';
import '../modules/room_chat/views/room_chat_view.dart';
import '../modules/room_nakes_chat/bindings/room_nakes_chat_binding.dart';
import '../modules/room_nakes_chat/views/room_nakes_chat_view.dart';
import '../modules/scan_barcode/bindings/scan_barcode_binding.dart';
import '../modules/scan_barcode/views/scan_barcode_view.dart';
import '../modules/scanner/bindings/scanner_binding.dart';
import '../modules/scanner/views/scanner_view.dart';
import '../modules/scanner_result/bindings/scanner_result_binding.dart';
import '../modules/scanner_result/views/scanner_result_view.dart';
import '../modules/semua_menu/bindings/semua_menu_binding.dart';
import '../modules/semua_menu/views/semua_menu_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/tentang_aplikasi/bindings/tentang_aplikasi_binding.dart';
import '../modules/tentang_aplikasi/views/tentang_aplikasi_view.dart';
import '../modules/verifikasi_email/bindings/verifikasi_email_binding.dart';
import '../modules/verifikasi_email/views/verifikasi_email_view.dart';

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
      name: _Paths.SCAN_BARCODE,
      page: () => const ScanBarcodeView(),
      binding: ScanBarcodeBinding(),
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
    GetPage(
      name: _Paths.DETAIL_DOKTER,
      page: () => const DetailDokterView(),
      binding: DetailDokterBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_DETAIL_PASIEN_GATIVA,
      page: () => const NakesDetailPasienGativaView(),
      binding: NakesDetailPasienGativaBinding(),
    ),
    GetPage(
      name: _Paths.CATATAN_NAKES,
      page: () => const CatatanNakesView(),
      binding: CatatanNakesBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_DASHBOARD,
      page: () => const NakesDashboardView(),
      binding: NakesDashboardBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_CATALOG,
      page: () => const NakesCatalogView(),
      binding: NakesCatalogBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_CHAT,
      page: () => const NakesChatView(),
      binding: NakesChatBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_EDUKASI,
      page: () => const NakesEdukasiView(),
      binding: NakesEdukasiBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_EDIT_PROFILE,
      page: () => const NakesEditProfileView(),
      binding: NakesEditProfileBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_INFORMASI_KESEHATAN,
      page: () => const NakesInformasiKesehatanView(),
      binding: NakesInformasiKesehatanBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_PROFILE,
      page: () => const NakesProfileView(),
      binding: NakesProfileBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_GANTI_KATA_SANDI,
      page: () => const NakesGantiKataSandiView(),
      binding: NakesGantiKataSandiBinding(),
    ),
    GetPage(
      name: _Paths.KATALOG,
      page: () => const KatalogView(),
      binding: KatalogBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_PASIEN_GATIVA,
      page: () => const NakesPasienGativaView(),
      binding: NakesPasienGativaBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_DETAIL_PASIEN_CHAT,
      page: () => const NakesDetailPasienChatView(),
      binding: NakesDetailPasienChatBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_TENTANG_APLIKASI,
      page: () => const NakesTentangAplikasiView(),
      binding: NakesTentangAplikasiBinding(),
    ),
    GetPage(
      name: _Paths.NAKES_BANTUAN_FAQ,
      page: () => const NakesBantuanFaqView(),
      binding: NakesBantuanFaqBinding(),
    ),
    GetPage(
      name: _Paths.TENTANG_APLIKASI,
      page: () => const TentangAplikasiView(),
      binding: TentangAplikasiBinding(),
    ),
    GetPage(
      name: _Paths.SCANNER_RESULT,
      page: () => const ScannerResultView(),
      binding: ScannerResultBinding(),
    ),
    GetPage(
      name: _Paths.ROOM_CHAT,
      page: () => const RoomChatView(),
      binding: RoomChatBinding(),
    ),
    GetPage(
      name: _Paths.ROOM_NAKES_CHAT,
      page: () => const RoomNakesChatView(),
      binding: RoomNakesChatBinding(),
    ),
    GetPage(
      name: _Paths.SCAN_DOKTER_AKSES,
      page: () => const ScanDokterAksesView(),
      binding: ScanDokterAksesBinding(),
    ),
  ];
}
