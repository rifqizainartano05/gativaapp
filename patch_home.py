import re

with open('lib/app/modules/home/views/home_view.dart', 'r') as f:
    content = f.read()

# The transformation:
# 1. Replace the body: SingleChildScrollView( ... child: Column( ... children: [
#    with body: Column( ... children: [
# 2. Find the end of Top Header Box Container and wrap the rest in Expanded(child: SingleChildScrollView( ... child: Padding( ... ) ))

# This is a bit tricky with regex, let's use string manipulation

start_idx = content.find('body: SingleChildScrollView(')
column_idx = content.find('child: Column(', start_idx)
children_idx = content.find('children: [', column_idx)

# Replace the start
new_content = content[:start_idx] + 'body: Column(\n          crossAxisAlignment: CrossAxisAlignment.start,\n          children: ['

# Find the end of the top header box
# It starts right after children: [
header_start = content.find('// Top Header Box (Full Width)', children_idx)

# Find the padding that comes right after it
padding_start = content.find('Padding(', header_start + 100)
# We know the container ends before Padding(

new_content += content[children_idx + len('children: ['):padding_start]

# Now insert Expanded
new_content += 'Expanded(\n              child: SingleChildScrollView(\n                physics: const BouncingScrollPhysics(),\n                padding: const EdgeInsets.only(bottom: 100),\n                child: '

# The rest of the content until the end of the original Column.
# The original column ends with ] \n        ),\n      ),
end_idx = content.rfind('        ),\n      ),\n    );')
if end_idx == -1:
    end_idx = content.rfind('        ),\n      )')

new_content += content[padding_start:end_idx]

# Close the new Expanded and Column
new_content += '              ),\n            ),\n          ],\n        ),\n      ),\n    );'

# Write back
with open('lib/app/modules/home/views/home_view.dart', 'w') as f:
    f.write(new_content)

print('Patched HomeView')
