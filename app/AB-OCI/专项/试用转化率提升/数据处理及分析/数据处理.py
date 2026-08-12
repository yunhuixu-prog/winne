# 3天新用户功能组合推荐
import pandas as pd
from itertools import combinations
from collections import defaultdict

# 读取数据
df = pd.read_csv('试用用户分析.csv')
new_users = df[df['user_type'].str.contains('3天内新用户', na=False)].copy()
total_new_users = len(new_users)

single_stats = defaultdict(lambda: {'total': 0, 'paid': 0})
pair_stats = defaultdict(lambda: {'total': 0, 'paid': 0})
triple_stats = defaultdict(lambda: {'total': 0, 'paid': 0})

for _, row in new_users.dropna(subset=['use_func_list']).iterrows():
    funcs = [f.strip() for f in str(row['use_func_list']).split(',') if f.strip() and f.strip() != '\\N']
    unique_funcs = sorted(list(set(funcs)))
    is_paid = row['is_paid']
    
    # 单功能
    for f in unique_funcs:
        single_stats[f]['total'] += 1
        single_stats[f]['paid'] += is_paid
        
    # 双功能
    if len(unique_funcs) >= 2:
        for pair in combinations(unique_funcs, 2):
            p_name = f"{pair[0]} + {pair[1]}"
            pair_stats[p_name]['total'] += 1
            pair_stats[p_name]['paid'] += is_paid
            
    # 三功能
    if len(unique_funcs) >= 3:
        for trip in combinations(unique_funcs, 3):
            t_name = f"{trip[0]} + {trip[1]} + {trip[2]}"
            triple_stats[t_name]['total'] += 1
            triple_stats[t_name]['paid'] += is_paid

def process_stats(stats_dict):
    res = []
    for name, data in stats_dict.items():
        pct = data['total'] / total_new_users
        if pct > 0.05: # 大于5%
            res.append({
                '功能/组合': name,
                '使用人数': data['total'],
                '使用占比': pct,
                '付费率': data['paid'] / data['total'] if data['total'] > 0 else 0
            })
    df_res = pd.DataFrame(res)
    if not df_res.empty:
        df_res = df_res.sort_values(by='使用占比', ascending=False)
        df_res['使用占比'] = df_res['使用占比'].apply(lambda x: f"{x*100:.2f}%")
        df_res['付费率'] = df_res['付费率'].apply(lambda x: f"{x*100:.2f}%")
    return df_res

print("单功能:")
print(process_stats(single_stats).to_string(index=False))
print("\n双功能:")
print(process_stats(pair_stats).to_string(index=False))
print("\n三功能:")
print(process_stats(triple_stats).to_string(index=False))