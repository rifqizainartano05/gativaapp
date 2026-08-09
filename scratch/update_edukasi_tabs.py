import re

path = 'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove "URL Gambar (Opsional)" block
image_block = """            const Text('URL Gambar (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.imageUrlController,
              decoration: InputDecoration(
                hintText: 'https://...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),"""

content = content.replace(image_block, "")

# 2. Redesign Document TabBar
old_document_tab = """  Widget _buildDocumentTab(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              indicatorColor: Color(0xFF2E7D32),
              labelColor: Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Dokumen PDF'),
                Tab(text: 'Tautan / Link'),
              ],
            ),
          ),"""

new_document_tab = """  Widget _buildDocumentTab(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color(0xFF2E7D32),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade700,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Dokumen PDF'),
                  Tab(text: 'Tautan / Link'),
                ],
              ),
            ),
          ),"""

content = content.replace(old_document_tab, new_document_tab)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
