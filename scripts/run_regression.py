import glob
import os
import subprocess
import sys
import re
from concurrent.futures import ThreadPoolExecutor

failures = 0
passes = 0

def run_test(test):
	result = subprocess.run(["make", "sim", f"TEST={test}"], capture_output= True,  text = True)
	passed = result.returncode == 0 and  re.search(f"TEST {test} PASS", result.stdout)
	return test, passed



files = glob.glob("tb/tb_*.sv")
if not files:
	print("ERROR: no testbenches found")
	sys.exit(1)

tests = [os.path.basename(f).replace(".sv", "") for f in files]

#using a thread pool to run the tests at the same time, because they don't depend on each other
#each test still builds and then runs in order
with ThreadPoolExecutor(max_workers=4) as pool:
	results = list(pool.map(run_test, tests))


for test, passed in results:
	
	if passed:
		print(f"PASS {test}")
		passes += 1
	else:
		print(f"FAIL {test}")
		failures += 1
		

print(f"{passes} PASSED")
print(f"{failures} FAILED")
if failures > 0:
	sys.exit(1)

