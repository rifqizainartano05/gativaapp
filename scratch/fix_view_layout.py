import os
import re

broken_code = """                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: const Color(0xFF282142),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  const Text('Dari', style: TextStyle(fontSize: 12, color: Colors.black54)),"""

fixed_code = """                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.safe, borderRadius: BorderRadius.circular(3))),
                                      const SizedBox(width: 6),
                                      const Text('Aman', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 16),
                                      Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(3))),
                                      const SizedBox(width: 6),
                                      const Text('Waspada', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 16),
                                      Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(3))),
                                      const SizedBox(width: 6),
                                      const Text('Bahaya', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Filter by time
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Riwayat Detail',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) {
                                  return CustomPopup(
                                    child: Obx(() {
                                      return Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Pilih Rentang Waktu',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 16),
                                            ...controller.filterOptionsList.map((option) {
                                              return Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      controller.changeFilterOption(option);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            option,
                                                            style: TextStyle(
                                                              color: controller.selectedFilterOption.value == option
                                                                  ? AppColors.primary
                                                                  : Colors.black87,
                                                              fontWeight: controller.selectedFilterOption.value == option
                                                                  ? FontWeight.bold
                                                                  : FontWeight.normal,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          if (controller.selectedFilterOption.value == option)
                                                            const Icon(Icons.check, color: AppColors.primary, size: 20),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (option != controller.filterOptionsList.last)
                                                    Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                                                ],
                                              );
                                            }),
                                            if (controller.selectedFilterOption.value == 'Kustom')
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16.0),
                                                child: Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: Colors.grey.shade200),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            final DateTime? picked = await showDatePicker(
                                                              context: context,
                                                              initialDate: controller.customDateRange.value?.start ?? DateTime.now(),
                                                              firstDate: DateTime(2000),
                                                              lastDate: DateTime.now(),
                                                            );
                                                            if (picked != null) {
                                                              final end = controller.customDateRange.value?.end ?? picked;
                                                              controller.customDateRange.value = DateTimeRange(start: picked, end: end.isBefore(picked) ? picked : end);
                                                            }
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                            decoration: const BoxDecoration(color: Colors.transparent),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                const Text('Dari', style: TextStyle(fontSize: 12, color: Colors.black54)),"""

def replace_in_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if broken_code in content:
        content = content.replace(broken_code, fixed_code)
        
        # Now we need to make sure we fix the decoration of the chart container which was overwritten.
        # It's right above LineChart(
        chart_container_pattern = r"height:\s*250,\s*width:\s*double\.infinity,\s*decoration:\s*BoxDecoration\([\s\S]*?border:\s*Border\.all\(color:\s*Colors\.grey\.shade200\),\s*\n\s*\),"
        fixed_container = """height: 250,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: const Color(0xFF282142),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),"""
        
        content = re.sub(chart_container_pattern, fixed_container, content)

        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    else:
        # Just print why it didn't match
        print(f"Could not find broken_code in {path}")
        return False

print("Riwayat:", replace_in_file('lib/app/modules/riwayat/views/riwayat_view.dart'))
print("Riwayat Anggota:", replace_in_file('lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart'))
