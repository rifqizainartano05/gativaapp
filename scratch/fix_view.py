import sys

file_paths = [
    'lib/app/modules/riwayat/views/riwayat_view.dart',
    'lib/app/modules/riwayat_anggota/views/riwayat_anggota_view.dart'
]

for path in file_paths:
    try:
        with open(path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        # Find where the broken block starts
        start_idx = -1
        for i, line in enumerate(lines):
            if "const SizedBox(height: 16)," in line and i + 5 < len(lines) and "Row(" in lines[i+1]:
                start_idx = i
                break
                
        if start_idx == -1:
            print(f"Start not found in {path}")
            continue
            
        # Find where it ends
        end_idx = -1
        for i in range(start_idx, len(lines)):
            if "const Text('Dari'" in lines[i]:
                end_idx = i - 2  # child: Column( is i-1, so end_idx is i-2
                break
                
        if end_idx == -1:
            print(f"End not found in {path}")
            continue
            
        print(f"Replacing {path} lines {start_idx} to {end_idx}")
        
        # What should go here?
        # 1. Close the LineChart container (which actually wasn't closed properly because my dark_chart replaced its decoration! Wait, no, dark chart replaced the FIRST `decoration: BoxDecoration` it found with `Colors.transparent`!
        # Which was the LineChart container? Yes, LineChart container had `color: Colors.transparent`.
        # Wait, let's look at what `revert_chart.py` put.
        # Actually, it's easier to just reconstruct the whole widget tree from `child: LineChart` up to `// Filter`.
    except Exception as e:
        print(f"Error {e}")
