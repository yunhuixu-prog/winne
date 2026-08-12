import sys
import os

d = sys.argv[1]
print(d)

if os.path.exists('/home/yunhui/bp/model/stacking_else_1_2_1_0_all_all_all_all_all_all_bucket_1.joblib'):
    print(f'has model')
else:
    print(f'not has')