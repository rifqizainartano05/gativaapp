import 'package:get/get.dart';

import '../modules/CATATAN_DOKTER/bindings/CATATAN_DOKTER_binding.dart';
import '../modules/CATATAN_DOKTER/bindings/CATATAN_DOKTER_binding.dart';
import '../modules/CATATAN_DOKTER/views/CATATAN_DOKTER_view.dart';
import '../modules/CATATAN_DOKTER/views/CATATAN_DOKTER_view.dart';
import '../modules/anggota/bindings/anggota_binding.dart';
import '../modules/anggota/views/anggota_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/detail_dokter/bindings/detail_dokter_binding.dart';
import '../modules/detail_dokter/views/detail_dokter_view.dart';
import '../modules/dokter_bantuan_faq/bindings/dokter_bantuan_faq_binding.dart';
import '../modules/dokter_bantuan_faq/views/dokter_bantuan_faq_view.dart';
import '../modules/dokter_chat/bindings/dokter_chat_binding.dart';
import '../modules/dokter_chat/views/dokter_chat_view.dart';
import '../modules/dokter_detail_pasien_chat/bindings/dokter_detail_pasien_chat_binding.dart';
import '../modules/dokter_detail_pasien_chat/views/dokter_detail_pasien_chat_view.dart';
import '../modules/dokter_edit_profile/bindings/dokter_edit_profile_binding.dart';
import '../modules/dokter_edit_profile/views/dokter_edit_profile_view.dart';
import '../modules/dokter_ganti_kata_sandi/bindings/dokter_ganti_kata_sandi_binding.dart';
import '../modules/dokter_ganti_kata_sandi/views/dokter_ganti_kata_sandi_view.dart';
import '../modules/dokter_profile/bindings/dokter_profile_binding.dart';
import '../modules/dokter_profile/views/dokter_profile_view.dart';
import '../modules/dokter_tentang_aplikasi/bindings/dokter_tentang_aplikasi_binding.dart';
import '../modules/dokter_tentang_aplikasi/views/dokter_tentang_aplikasi_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edukasi/bindings/edukasi_binding.dart';
import '../modules/edukasi/views/edukasi_view.dart';
import '../modules/edukasi_dokter/bindings/edukasi_dokter_binding.dart';
import '../modules/edukasi_dokter/views/edukasi_dokter_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/gabung_grup_anggota/bindings/gabung_grup_anggota_binding.dart';
import '../modules/gabung_grup_anggota/views/gabung_grup_anggota_view.dart';
import '../modules/ganti_kata_sandi/bindings/ganti_kata_sandi_binding.dart';
import '../modules/ganti_kata_sandi/views/ganti_kata_sandi_view.dart';
import '../modules/hasil_pindai_label/bindings/hasil_pindai_label_binding.dart';
import '../modules/hasil_pindai_label/views/hasil_pindai_label_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home_dokter/bindings/home_dokter_binding.dart';
import '../modules/home_dokter/views/home_dokter_view.dart';

import '../modules/katalog/bindings/katalog_binding.dart';
import '../modules/katalog/views/katalog_view.dart';
import '../modules/lensa_pintar/bindings/lensa_pintar_binding.dart';
import '../modules/lensa_pintar/views/lensa_pintar_view.dart';
import '../modules/lensa_pintar_detail/bindings/lensa_pintar_detail_binding.dart';
import '../modules/lensa_pintar_detail/views/lensa_pintar_detail_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main_navigation/bindings/main_navigation_binding.dart';
import '../modules/main_navigation/views/main_navigation_view.dart';
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
import '../modules/riwayat_anggota/bindings/riwayat_anggota_binding.dart';
import '../modules/riwayat_anggota/views/riwayat_anggota_view.dart';
import '../modules/room_chat/bindings/room_chat_binding.dart';
import '../modules/room_chat/views/room_chat_view.dart';
import '../modules/room_dokter_chat/bindings/room_dokter_chat_binding.dart';
import '../modules/room_dokter_chat/views/room_dokter_chat_view.dart';
import '../modules/scan_label/bindings/scan_label_binding.dart';
import '../modules/scan_label/views/scan_label_view.dart';
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
      name: _Paths.SCAN_LABEL,
      page: () => const ScanLabelView(),
      binding: ScanLabelBinding(),
    ),
    GetPage(
      name: _Paths.gabung_grup_anggota,
      page: () => const GabungGrupAnggotaView(),
      binding: GabungGrupAnggotaBinding(),
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
      name: _Paths.RIWAYAT_ANGGOTA,
      page: () => const RiwayatAnggotaView(),
      binding: RiwayatAnggotaBinding(),
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
      transition: Transition.noTransition,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.noTransition,
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
      name: _Paths.LENSA_PINTAR,
      page: () => const LensaPintarView(),
      binding: LensaPintarBinding(),
    ),
    GetPage(
      name: _Paths.LENSA_PINTAR_DETAIL,
      page: () => const LensaPintarDetailView(),
      binding: LensaPintarDetailBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
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
      name: _Paths.CATATAN_DOKTER,
      page: () => const CatatanDokterView(),
      binding: CatatanDokterBinding(),
    ),
    GetPage(
      name: _Paths.HOME_DOKTER,
      page: () => const HomeDokterView(),
      binding: HomeDokterBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_CHAT,
      page: () => const DokterChatView(),
      binding: DokterChatBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_EDIT_PROFILE,
      page: () => const DokterEditProfileView(),
      binding: DokterEditProfileBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_PROFILE,
      page: () => const DokterProfileView(),
      binding: DokterProfileBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_GANTI_KATA_SANDI,
      page: () => const DokterGantiKataSandiView(),
      binding: DokterGantiKataSandiBinding(),
    ),
    GetPage(
      name: _Paths.KATALOG,
      page: () => const KatalogView(),
      binding: KatalogBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_DETAIL_PASIEN_CHAT,
      page: () => const DokterDetailPasienChatView(),
      binding: DokterDetailPasienChatBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_TENTANG_APLIKASI,
      page: () => const DokterTentangAplikasiView(),
      binding: DokterTentangAplikasiBinding(),
    ),
    GetPage(
      name: _Paths.DOKTER_BANTUAN_FAQ,
      page: () => const DokterBantuanFaqView(),
      binding: DokterBantuanFaqBinding(),
    ),
    GetPage(
      name: _Paths.TENTANG_APLIKASI,
      page: () => const TentangAplikasiView(),
      binding: TentangAplikasiBinding(),
    ),
    GetPage(
      name: _Paths.SCAN_LABEL_RESULT,
      page: () => const HasilPindaiLabelView(),
      binding: HasilPindaiLabelBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: _Paths.ROOM_CHAT,
      page: () => const RoomChatView(),
      binding: RoomChatBinding(),
    ),
    GetPage(
      name: _Paths.ROOM_DOKTER_CHAT,
      page: () => const RoomDokterChatView(),
      binding: RoomDokterChatBinding(),
    ),
    GetPage(
      name: _Paths.GANTI_KATA_SANDI,
      page: () => const GantiKataSandiView(),
      binding: GantiKataSandiBinding(),
    ),
    GetPage(
      name: _Paths.EDUKASI,
      page: () => const EdukasiView(),
      binding: EdukasiBinding(),
    ),
    GetPage(
      name: _Paths.EDUKASI_DOKTER,
      page: () => const EdukasiDokterView(),
      binding: EdukasiDokterBinding(),
    ),
  ];
}
