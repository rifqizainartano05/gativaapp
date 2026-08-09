import re

path = 'lib/app/modules/edukasi/views/edukasi_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add url_launcher import
if "import 'package:url_launcher/url_launcher.dart';" not in content:
    content = content.replace("import 'package:intl/intl.dart';", "import 'package:intl/intl.dart';\nimport 'package:url_launcher/url_launcher.dart';")

# 2. Update the onTap logic in ListView.builder
old_ontap = "onTap: () => Get.toNamed('/edukasi', arguments: data),"
new_ontap = """onTap: () async {
                  if (data['type'] == 'pdf' && data['fileUrl'] != null) {
                    final Uri url = Uri.parse(data['fileUrl']);
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      Get.snackbar('Error', 'Tidak dapat membuka PDF');
                    }
                  } else if (data['type'] == 'link' && data['linkUrl'] != null) {
                    final Uri url = Uri.parse(data['linkUrl']);
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      Get.snackbar('Error', 'Tidak dapat membuka Tautan');
                    }
                  } else {
                    Get.toNamed('/edukasi', arguments: data);
                  }
                },"""
content = content.replace(old_ontap, new_ontap)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

# Update home_view.dart as well!
path2 = 'lib/app/modules/home/views/home_view.dart'
with open(path2, 'r', encoding='utf-8') as f:
    content2 = f.read()

if "import 'package:url_launcher/url_launcher.dart';" not in content2:
    content2 = content2.replace("import 'package:intl/intl.dart';", "import 'package:intl/intl.dart';\nimport 'package:url_launcher/url_launcher.dart';")

old_ontap2 = "onTap: () => Get.toNamed('/edukasi', arguments: item),"
new_ontap2 = """onTap: () async {
                                  if (item['type'] == 'pdf' && item['fileUrl'] != null) {
                                    final Uri url = Uri.parse(item['fileUrl']);
                                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                      Get.snackbar('Error', 'Tidak dapat membuka PDF');
                                    }
                                  } else if (item['type'] == 'link' && item['linkUrl'] != null) {
                                    final Uri url = Uri.parse(item['linkUrl']);
                                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                      Get.snackbar('Error', 'Tidak dapat membuka Tautan');
                                    }
                                  } else {
                                    Get.toNamed('/edukasi', arguments: item);
                                  }
                                },"""
content2 = content2.replace(old_ontap2, new_ontap2)

# One more thing: The default icon in EdukasiView and HomeView for link/pdf
# In HomeView:
old_image2 = """                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          image: item['imageUrl'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(item['imageUrl']),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.grey.shade100,
                                        ),
                                        child: item['imageUrl'] == null
                                            ? const Center(child: Icon(Icons.image, color: Colors.grey, size: 40))
                                            : null,
                                      ),"""
new_image2 = """                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          image: item['imageUrl'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(item['imageUrl']),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.grey.shade100,
                                        ),
                                        child: item['imageUrl'] == null
                                            ? Center(
                                                child: Icon(
                                                  item['type'] == 'pdf' ? Icons.picture_as_pdf : 
                                                  item['type'] == 'link' ? Icons.link : Icons.article, 
                                                  color: Colors.grey, 
                                                  size: 40
                                                )
                                              )
                                            : null,
                                      ),"""
content2 = content2.replace(old_image2, new_image2)

with open(path2, 'w', encoding='utf-8') as f:
    f.write(content2)

print("Updated patient views")
