import pandas as pd

# 读取数据
df = pd.read_csv("app/ab新sdk/实验/Face限免实验/进一步/Face实验保存数据.csv")

# 重新应用同样的分类函数
def categorize_face(row):
    # 如果保存数为0（func_cnt为0 或 uv为0）或者组合为空，则视为“未保存”
    if pd.isna(row['save_func_combo']) or row['save_func_cnt'] == 0 or row['save_user_uv'] == 0:
        return "未保存"
        
    # 以逗号拆分并去除前后空格
    funcs = [f.strip() for f in str(row['save_func_combo']).split(',')]
    
    if 'Face' in funcs:
        if len(funcs) == 1:
            return "仅使用Face保存"
        else:
            return "使用Face+其他功能保存"
    else:
        return "未使用Face保存"

# 应用分类逻辑
df['face_category'] = df.apply(categorize_face, axis=1)

# 分组统计 保存人数 和 保存次数
grouped = df.groupby(['ab_group', 'os_p', 'face_category']).agg({
    'save_user_uv': 'sum',
    'save_pv': 'sum'
}).reset_index()

# 获取总人数用于计算占比
totals = df.groupby(['ab_group', 'os_p'])['save_user_uv'].sum().reset_index()
totals.rename(columns={'save_user_uv': 'total_uv'}, inplace=True)

# 合并并计算占比
result = pd.merge(grouped, totals, on=['ab_group', 'os_p'])
result['人数占比(%)'] = (result['save_user_uv'] / result['total_uv']) * 100
result['人数占比(%)'] = result['人数占比(%)'].round(2)

# 重命名列名
result.rename(columns={
    'ab_group': '实验组别',
    'os_p': '操作系统',
    'face_category': 'Face保存类别',
    'save_user_uv': '保存人数',
    'save_pv': '保存次数'
}, inplace=True)

# 调整列顺序
final_df = result[['实验组别', '操作系统', 'Face保存类别', '保存人数', '保存次数', '人数占比(%)']]

# 按照固定顺序排列
category_order = ["仅使用Face保存", "使用Face+其他功能保存", "未使用Face保存", "未保存"]
final_df['Face保存类别'] = pd.Categorical(final_df['Face保存类别'], categories=category_order, ordered=True)
final_df = final_df.sort_values(by=['实验组别', '操作系统', 'Face保存类别']).reset_index(drop=True)

# 打印结果供核对
print(final_df.to_string(index=False))

# 导出为CSV
output_path = "app/ab新sdk/实验/Face限免实验/进一步/Face组合保存占比分析.csv"
final_df.to_csv(output_path, index=False, encoding='utf-8-sig')
print(f"\nFile saved: {output_path}")