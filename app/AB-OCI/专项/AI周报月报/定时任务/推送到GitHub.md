# 推送到 GitHub（供 Cloud Agent 绑定仓库）

本地已完成 `git init` 与首次提交。Cloud Agent 定时任务需要 **远程仓库 URL**。

---

## 方式 A · 在 GitHub 网页创建空仓库

1. 打开 https://github.com/new
2. Repository name 建议：`airbrush-analytics`（或任意名称）
3. **不要**勾选 "Add a README"（本地已有提交）
4. 创建后复制 HTTPS 地址，例如：`https://github.com/<你的用户名>/airbrush-analytics.git`

在终端执行（仓库已创建）：

```bash
cd "/Users/xuyunhui/Documents/项目"
git remote add origin https://github.com/yunhuixu-prog/winne.git   # 若已添加可跳过
git branch -M main
git push -u origin main
```

> **当前状态**：`origin` 已指向 `https://github.com/yunhuixu-prog/winne.git`，本地 commit 待 push。

### 认证（push 前必做，任选其一）

**A · GitHub CLI（已安装 `gh`）**

```bash
gh auth login
# 选 GitHub.com → HTTPS → Login with a web browser
cd "/Users/xuyunhui/Documents/项目"
git push -u origin main
```

**B · Personal Access Token**

1. GitHub → Settings → Developer settings → [Personal access tokens](https://github.com/settings/tokens) → 生成 classic token（勾选 `repo`）
2. push 时 Username 填 `yunhuixu-prog`，Password 填 token

**C · SSH**

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub   # 添加到 GitHub → Settings → SSH keys
git remote set-url origin git@github.com:yunhuixu-prog/winne.git
git push -u origin main
```

---

## 方式 B · 已有远程仓库

若代码已在 GitLab / 公司 GitHub：

```bash
cd "/Users/xuyunhui/Documents/项目"
git remote add origin <你的仓库 HTTPS 或 SSH URL>
git push -u origin main
```

若远程已有历史且需合并，先 `git pull origin main --allow-unrelated-histories` 再 push。

---

## 推送后 · 绑定 Automation

1. 打开 https://cursor.com/automations/new
2. **Repository** 选刚 push 的仓库
3. 按 [`一键创建Automations.md`](./一键创建Automations.md) 创建两条定时任务

---

## Cloud Agent 环境变量

在 [Cloud Agents → Environment](https://cursor.com/dashboard?tab=cloud-agents) 配置：

| 变量 | 用途 |
|------|------|
| `OMNIBUS_ACCESS_TOKEN` | 知识库 Confluence / 北斗拉取（周一任务） |

---

## 本地试跑结果（2026-08-12）

| 步骤 | 状态 |
|------|------|
| 知识库 raw 拉取（marks + CF） | ✅ 成功；**26 个文件待 INGEST** |
| 周报 Phase A（0803～0809） | ✅ 成功；v1 + 下钻/贡献度/下钻报告已生成 |

下一步（Agent）：wiki INGEST → Phase B～E 生成 v2/v3。
