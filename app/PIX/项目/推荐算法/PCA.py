import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

# pd.set_option('display.max_columns',None)
# pd.set_option('display.max_rows',None)

data=pd.read_csv('../../data/recommend_test.csv')
X=(data.dropna(axis=1,how="all")).iloc[:,1:]
X=X.fillna(0)

# 要不先看下相关系数之类的

# 标准化数据（重要步骤，通常PCA之前需要中心化和标准化数据）
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 初始化PCA并指定要保留的主成分数量，例如保留80%的信息
# 如果你知道想要降低到的维数，也可以直接指定一个整数
pca = PCA(n_components=0.8)

# 对数据应用PCA
X_pca = pca.fit_transform(X_scaled)

# 输出转换后的数据以及保留的成分数
print("Original shape: ", X.shape)
print("Transformed shape:", X_pca.shape)

# 输出各主成分解释的方差比例
print("Explained variance ratio:", pca.explained_variance_ratio_)

pca.components_