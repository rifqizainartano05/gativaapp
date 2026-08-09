import os

files_to_update = [
    'lib/app/modules/edukasi_dokter/controllers/edukasi_dokter_controller.dart',
    'lib/app/modules/edukasi_dokter/views/edukasi_dokter_view.dart',
    'lib/app/modules/edukasi/views/edukasi_view.dart',
    'lib/app/modules/home/controllers/home_controller.dart'
]

old_str = "FirebaseFirestore.instance.collection('edukasi')"
new_str = "FirebaseFirestore.instance.collection('mobile').doc('roles').collection('edukasi')"

for file_path in files_to_update:
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace occurrences
        if old_str in content:
            content = content.replace(old_str, new_str)
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {file_path}")
        else:
            # Special case for home_controller where it might be broken into multiple lines
            pass

# Handle home_controller.dart specially
home_controller_path = 'lib/app/modules/home/controllers/home_controller.dart'
if os.path.exists(home_controller_path):
    with open(home_controller_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    old_home_str = """    FirebaseFirestore.instance
        .collection('edukasi')"""
    new_home_str = """    FirebaseFirestore.instance
        .collection('mobile')
        .doc('roles')
        .collection('edukasi')"""
        
    if old_home_str in content:
        content = content.replace(old_home_str, new_home_str)
        with open(home_controller_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {home_controller_path}")

