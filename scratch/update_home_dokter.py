import re

def update_home_dokter():
    path = 'lib/app/modules/home_dokter/views/home_dokter_view.dart'
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    old_button = """            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.DOKTER_CHAT),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100), // Match the clipper's pill shape perfectly
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Konsultasi Live Chat',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),"""
            
    # wait, the original code uses withValues(alpha: 0.1) instead of withOpacity(0.1) because of deprecation warnings!
    # Let me check the exact string: color: Colors.black.withValues(alpha: 0.1),
    # Wait, my previous view_file response:
    # color: Colors.black.withValues(alpha: 0.1),
    
    # I'll just use regex to replace the child of Positioned.

    new_button = """            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100), // Match the clipper's pill shape perfectly
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(Routes.DOKTER_CHAT),
                      behavior: HitTestBehavior.opaque,
                      child: const Center(
                        child: Text(
                          'Konsultasi',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(Routes.EDUKASI_DOKTER),
                      behavior: HitTestBehavior.opaque,
                      child: const Center(
                        child: Text(
                          'Edukasi',
                          style: TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),"""

    # We can replace the child of Positioned using string replace if we extract the old string carefully.
    old_button_exact = """            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.DOKTER_CHAT),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100), // Match the clipper's pill shape perfectly
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Konsultasi Live Chat',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),"""
    
    if old_button_exact in content:
        content = content.replace(old_button_exact, new_button)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

update_home_dokter()
print("Updated home_dokter_view.dart")
