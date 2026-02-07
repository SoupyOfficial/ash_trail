import re
import sys

filepath = sys.argv[1]
with open(filepath, 'r') as f:
    c = f.read()

# Add import for helpers
c = c.replace(
    "import 'package:geolocator/geolocator.dart';",
    "import 'package:geolocator/geolocator.dart';\nimport 'e2e_helpers.dart' as helpers;"
)

# Replace app.main() + pumpAndSettle with robust pumping
c = re.sub(
    r"app\.main\(\);\n\s*await tester\.pumpAndSettle\(const Duration\(seconds: \d+\)\);",
    "app.main();\n      await helpers.testerPumpUntilFound(tester, find.text('Welcome to Ash Trail'));",
    c
)

# Replace remaining pumpAndSettle calls with simple pump
c = c.replace('await tester.pumpAndSettle(const Duration(seconds: 3));', 'await tester.pump(const Duration(seconds: 3));')
c = c.replace('await tester.pumpAndSettle(const Duration(seconds: 2));', 'await tester.pump(const Duration(seconds: 2));')
c = c.replace('await tester.pumpAndSettle(const Duration(seconds: 1));', 'await tester.pump(const Duration(seconds: 1));')
c = c.replace('await tester.pumpAndSettle();', 'await tester.pump(const Duration(seconds: 2));')

with open(filepath, 'w') as f:
    f.write(c)

print(f"Done: {c.count('testerPumpUntilFound')} testerPumpUntilFound, {c.count('pumpAndSettle')} pumpAndSettle remaining")
