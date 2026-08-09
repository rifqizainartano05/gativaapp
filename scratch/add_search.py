import os

path = 'lib/app/modules/edukasi/views/edukasi_view.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_expanded = """            Expanded(
              child: Obx(() {"""

new_expanded = """            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                onChanged: (value) => controller.updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Cari artikel edukasi...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                ),
              ),
            ),
            Expanded(
              child: Obx(() {"""

if old_expanded in content:
    content = content.replace(old_expanded, new_expanded)

old_list = """                  final docs = controller.edukasiList;"""
new_list = """                  final docs = controller.filteredEdukasiList;"""
if old_list in content:
    content = content.replace(old_list, new_list)

# wait boxshadow is not supported directly in InputDecoration. Let's fix that.
# I should wrap TextField in a Container for boxShadow.
new_expanded_fixed = """            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => controller.updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Cari artikel edukasi...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {"""
content = content.replace(new_expanded, new_expanded_fixed)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
