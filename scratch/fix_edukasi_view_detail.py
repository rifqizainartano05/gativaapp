import os

path_edukasi_view = 'lib/app/modules/edukasi/views/edukasi_view.dart'
with open(path_edukasi_view, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update onTap to ALWAYS go to detail view
old_ontap = """                        onTap: () async {
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
new_ontap = """                        onTap: () {
                          Get.toNamed('/edukasi', arguments: data);
                        },"""
content = content.replace(old_ontap, new_ontap)

# 2. Update the preview summary box to fallback to content if summary is null
old_summary_check = """                                        if (data['summary'] != null && data['summary'].toString().isNotEmpty) ...["""
new_summary_check = """                                        if ((data['summary'] ?? data['content'] ?? '').toString().isNotEmpty) ...["""
content = content.replace(old_summary_check, new_summary_check)

old_summary_text = """                                                  child: Text(
                                                    data['summary'],"""
new_summary_text = """                                                  child: Text(
                                                    (data['summary'] ?? data['content']).toString(),"""
content = content.replace(old_summary_text, new_summary_text)

# 3. Update Detail View to show summary if content is null, and add buttons for link/pdf
old_detail_content = """                  Text(
                    data['content'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );"""

new_detail_content = """                  Text(
                    (data['content'] ?? data['summary'] ?? '').toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  if (data['type'] == 'pdf' && data['fileUrl'] != null) ...[
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(data['fileUrl']);
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            Get.snackbar('Error', 'Tidak dapat membuka PDF');
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: const Text('Buka Dokumen PDF', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                  if (data['type'] == 'link' && data['linkUrl'] != null) ...[
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(data['linkUrl']);
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            Get.snackbar('Error', 'Tidak dapat membuka Tautan');
                          }
                        },
                        icon: const Icon(Icons.link, color: Colors.white),
                        label: const Text('Kunjungi Tautan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );"""
content = content.replace(old_detail_content, new_detail_content)

with open(path_edukasi_view, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
