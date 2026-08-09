import re

path = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'import \'package:flutter/services.dart\';' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';")

old_edukasi_class = """class EdukasiDokterView extends GetView<EdukasiDokterController> {
  const EdukasiDokterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold("""

new_edukasi_class = """class EdukasiDokterView extends StatelessWidget {
  const EdukasiDokterView({super.key});

  @override
  Widget build(BuildContext context) {
    final EdukasiDokterController controller = Get.put(EdukasiDokterController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold("""
content = content.replace(old_edukasi_class, new_edukasi_class)

old_edukasi_end = """      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Get.to(() => const TambahEdukasiView());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}"""

new_edukasi_end = """      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () {
          Get.to(() => const TambahEdukasiView());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ),
    );
  }
}"""
content = content.replace(old_edukasi_end, new_edukasi_end)


old_tambah_class = """class TambahEdukasiView extends GetView<EdukasiDokterController> {
  const TambahEdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold("""

new_tambah_class = """class TambahEdukasiView extends StatelessWidget {
  const TambahEdukasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final EdukasiDokterController controller = Get.put(EdukasiDokterController());
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold("""
content = content.replace(old_tambah_class, new_tambah_class)


old_tambah_end = """            Expanded(
              child: TabBarView(
                children: [
                  _buildManualTab(context),
                  _buildDocumentTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualTab"""

new_tambah_end = """            Expanded(
              child: TabBarView(
                children: [
                  _buildManualTab(controller, context),
                  _buildDocumentTab(controller, context),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildManualTab"""
content = content.replace(old_tambah_end, new_tambah_end)

content = content.replace("Widget _buildManualTab(BuildContext context) {", "Widget _buildManualTab(EdukasiDokterController controller, BuildContext context) {")
content = content.replace("Widget _buildDocumentTab(BuildContext context) {", "Widget _buildDocumentTab(EdukasiDokterController controller, BuildContext context) {")
content = content.replace("Widget _buildPdfTab(BuildContext context) {", "Widget _buildPdfTab(EdukasiDokterController controller, BuildContext context) {")
content = content.replace("Widget _buildLinkTab(BuildContext context) {", "Widget _buildLinkTab(EdukasiDokterController controller, BuildContext context) {")

content = content.replace("_buildPdfTab(context)", "_buildPdfTab(controller, context)")
content = content.replace("_buildLinkTab(context)", "_buildLinkTab(controller, context)")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
