#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Confluence内容提取工具

从Confluence递归提取指定页面及其所有子页面信息，
支持多个地址批量提取，自动转换为Markdown格式，并生成页面结构树。
支持排除规则（按pageId或页面标题关键词）。

配置来源:
    token: 环境变量 OMNIBUS_ACCESS_TOKEN
    地址列表: 计算脚本/提取cf/知识库地址.csv
"""

import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import json
import os
import re
import csv
from pathlib import Path

import sys

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))
from skill_paths import kb_raw_dir

CSV_FILE = SCRIPT_DIR / "知识库地址.csv"
OUTPUT_BASE = kb_raw_dir("知识库")
_CONNECTORS_BASE = os.environ.get("MEITU_CONNECTORS_BASE_URL", "http://localhost:3141").rstrip("/")
DEFAULT_BASE_URL = f"{_CONNECTORS_BASE}/gateway/cf.meitu.com/confluence/rest/api/content"


def load_token():
    token = os.environ.get("OMNIBUS_ACCESS_TOKEN", "").strip()
    if token:
        return token
    raise RuntimeError("未读取到 OMNIBUS_ACCESS_TOKEN，请先配置环境变量")


def is_numeric(s):
    return re.fullmatch(r"\d+", s.strip()) is not None


def load_sites():
    sites = []
    with open(str(CSV_FILE), "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            tp = row.get("类型", "").strip()
            if tp != "cf":
                continue
            param = row.get("参数", "").strip()
            raw_exclude = row.get("排除", "").strip()
            exclude_list = []
            if raw_exclude:
                for item in re.split(r"[、,，]", raw_exclude):
                    item = item.strip()
                    if item:
                        exclude_list.append(item)
            sites.append({"page_id": param, "exclude": exclude_list})
    if not sites:
        raise ValueError(f"CSV中未找到 类型=cf 的记录: {CSV_FILE}")
    return sites


class ConfluenceExtractor:
    def __init__(self, token, base_url):
        self.token = token
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        })
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[],
            allowed_methods=["GET"],
            raise_on_status=False
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("https://", adapter)
        self.session.mount("http://", adapter)

    def sanitize_filename(self, name):
        name = re.sub(r'[<>:"/\\|?*]', '_', name)
        name = re.sub(r'[\[\]]', '', name)
        return name.strip()

    def html_to_text(self, html_content):
        text = html_content
        text = re.sub(r'<br\s*/?>', '\n', text)
        text = re.sub(r'</p>', '\n', text)
        text = re.sub(r'<p[^>]*>', '', text)
        text = re.sub(r'</?strong>', '**', text)
        text = re.sub(r'</?b>', '**', text)
        text = re.sub(r'</?em>', '*', text)
        text = re.sub(r'</?i>', '*', text)
        text = re.sub(r'<li[^>]*>', '- ', text)
        text = re.sub(r'</li>', '\n', text)
        text = re.sub(r'</?ul[^>]*>', '\n', text)
        text = re.sub(r'</?ol[^>]*>', '\n', text)
        text = re.sub(r'<h([1-6])[^>]*>', lambda m: '\n' + '#' * int(m.group(1)) + ' ', text)
        text = re.sub(r'</h[1-6]>', '\n', text)
        text = re.sub(r'<a[^>]*href="([^"]*)"[^>]*>', r'[\1](', text)
        text = re.sub(r'</a>', ')', text)
        text = re.sub(r'<ac:link[^>]*>', '', text)
        text = re.sub(r'</ac:link>', '', text)
        text = re.sub(r'<ri:user[^>]*/>', '', text)
        text = re.sub(r'<ri:page[^>]*/>', '', text)
        text = re.sub(r'<time[^>]*datetime="([^"]*)"[^>]*/>', r'\1', text)
        text = re.sub(r'<ac:structured-macro[^>]*>.*?</ac:structured-macro>', '', text, flags=re.DOTALL)
        text = re.sub(r'<ac:parameter[^>]*>[^<]*</ac:parameter>', '', text)
        text = re.sub(r'<colgroup>.*?</colgroup>', '', text, flags=re.DOTALL)
        text = re.sub(r'<col[^>]*/>', '', text)
        text = re.sub(r'<table[^>]*>', '\n', text)
        text = re.sub(r'</table>', '\n', text)
        text = re.sub(r'<thead[^>]*>', '', text)
        text = re.sub(r'</thead>', '', text)
        text = re.sub(r'<tbody[^>]*>', '', text)
        text = re.sub(r'</tbody>', '', text)
        text = re.sub(r'<tr[^>]*>', '|', text)
        text = re.sub(r'</tr>', '|\n', text)
        text = re.sub(r'<t[hd][^>]*>', ' ', text)
        text = re.sub(r'</t[hd]>', ' |', text)
        text = re.sub(r'<div[^>]*>', '', text)
        text = re.sub(r'</div>', '', text)
        text = re.sub(r'<span[^>]*>', '', text)
        text = re.sub(r'</span>', '', text)
        text = re.sub(r'<[^>]+>', '', text)
        text = re.sub(r'&nbsp;', ' ', text)
        text = re.sub(r'&lt;', '<', text)
        text = re.sub(r'&gt;', '>', text)
        text = re.sub(r'&amp;', '&', text)
        text = re.sub(r'&ldquo;', '"', text)
        text = re.sub(r'&rdquo;', '"', text)
        text = re.sub(r'\n\s*\n', '\n\n', text)
        text = re.sub(r'[ \t]+', ' ', text)
        return text.strip()

    def get_child_pages(self, page_id):
        all_results = []
        start = 0
        limit = 100
        while True:
            url = f"{self.base_url}/{page_id}/child/page?limit={limit}&start={start}"
            try:
                response = self.session.get(url, timeout=60)
                response.raise_for_status()
                data = response.json()
                results = data.get("results", [])
                all_results.extend([(r["id"], r["title"]) for r in results])
                if len(results) < limit:
                    break
                start += limit
            except Exception as e:
                print(f"  Error fetching child pages for {page_id}: {e}")
                break
        return all_results

    def get_page_version(self, page_id):
        url = f"{self.base_url}/{page_id}?expand=version"
        try:
            response = self.session.get(url, timeout=60)
            response.raise_for_status()
            data = response.json()
            title = data.get("title", "Untitled")
            version = data.get("version", {})
            when = version.get("when", "")
            number = version.get("number", 0)
            return title, when, number
        except Exception as e:
            print(f"  Error fetching version for {page_id}: {e}")
            return None, None, None

    def get_page_body(self, page_id):
        url = f"{self.base_url}/{page_id}?expand=body.storage"
        try:
            response = self.session.get(url, timeout=60)
            response.raise_for_status()
            data = response.json()
            title = data.get("title", "Untitled")
            body = data.get("body")
            storage = body.get("storage") if isinstance(body, dict) else None
            html_content = storage.get("value", "") if isinstance(storage, dict) else ""
            return title, html_content
        except Exception as e:
            print(f"  Error fetching body for {page_id}: {e}")
            return None, None

    def _is_excluded(self, page_id, page_title, exclude_rules):
        for rule in exclude_rules:
            if is_numeric(rule):
                if page_id == rule:
                    return True
            else:
                if rule in page_title:
                    return True
        return False

    def _load_version_tracker(self, output_dir):
        path = os.path.join(output_dir, "_update_times.json")
        if os.path.exists(path):
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        return {}

    def _save_version_tracker(self, output_dir, tracker):
        path = os.path.join(output_dir, "_update_times.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(tracker, f, indent=2, ensure_ascii=False)

    def _needs_update(self, page_id, when, number, tracker):
        if page_id not in tracker:
            return True
        prev = tracker[page_id]
        if prev.get("number", 0) < number:
            return True
        if prev.get("when", "") < when:
            return True
        return False

    def traverse_and_save_recursive(self, output_dir, page_id, exclude_rules,
                                    global_count, version_tracker, depth=0, parent_path=""):
        result = []
        children = self.get_child_pages(page_id)
        for child_id, child_title in children:
            if self._is_excluded(child_id, child_title, exclude_rules):
                print(f"  (排除) {child_title} (id={child_id})")
                continue
            safe_title = self.sanitize_filename(child_title)
            current_path = f"{parent_path}/{safe_title}" if parent_path else safe_title

            # 先查版本
            ver_title, ver_when, ver_number = self.get_page_version(child_id)
            if not ver_title:
                continue

            do_download = self._needs_update(child_id, ver_when, ver_number, version_tracker)

            if do_download:
                title, html_content = self.get_page_body(child_id)
                if title and html_content is not None:
                    if parent_path:
                        page_dir = os.path.join(output_dir, *[self.sanitize_filename(p) for p in parent_path.split("/")])
                        os.makedirs(page_dir, exist_ok=True)
                        filepath = os.path.join(page_dir, f"{safe_title}.md")
                    else:
                        filepath = os.path.join(output_dir, f"{safe_title}.md")
                    text_content = self.html_to_text(html_content) if html_content else ""
                    with open(filepath, "w", encoding="utf-8") as f:
                        f.write(f"# {title}\n\n")
                        f.write(f"**页面ID**: {child_id}\n\n")
                        if parent_path:
                            f.write(f"**路径**: {parent_path}/{title}\n\n")
                        f.write("---\n\n")
                        f.write(text_content)
                    # 写入版本标记
                    version_tracker[child_id] = {"when": ver_when, "number": ver_number}
                    global_count[0] += 1
                    print(f"  [{global_count[0]}] {child_title}.md")
                else:
                    if title:
                        print(f"  (空内容) {child_title} (id={child_id})")
                    else:
                        print(f"  (内容获取失败) {child_title} (id={child_id})")
            else:
                print(f"  (跳过) {child_title} (id={child_id})")

            child_children = self.get_child_pages(child_id)
            has_children = len(child_children) > 0
            sub_pages = []
            if has_children:
                sub_pages = self.traverse_and_save_recursive(
                    output_dir, child_id, exclude_rules, global_count,
                    version_tracker, depth + 1, current_path
                )
            result.append({
                "id": child_id,
                "title": child_title,
                "depth": depth,
                "path": current_path,
                "has_children": has_children
            })
            result.extend(sub_pages)
        return result

    def generate_structure_tree(self, pages, root_title):
        lines = [f"# {root_title} 页面结构树", "", "```"]
        for page in pages:
            indent = "  " * page["depth"]
            prefix = "├── " if not page["has_children"] else "┬── "
            lines.append(f"{indent}{prefix}{page['title']}")
            if page["has_children"]:
                child_indent = "  " * (page["depth"] + 1)
                lines.append(f"{child_indent}└── ...")
        lines.append("```")
        lines.append("")
        lines.append(f"**总计**: {len(pages)} 个页面")
        lines.append("")
        lines.append("---")
        lines.append("")
        lines.append("## 详细列表")
        lines.append("")
        for page in pages:
            indent = "  " * page["depth"]
            children_mark = " " if page["has_children"] else ""
            if "/" in page["path"]:
                rel_path = os.path.join(*[self.sanitize_filename(p) for p in page["path"].split("/")]) + ".md"
            else:
                rel_path = self.sanitize_filename(page["title"]) + ".md"
            lines.append(f"{indent}- [{page['title']}](./{rel_path}){children_mark} `({page['id']})`")
        return "\n".join(lines)

    def extract_site(self, output_dir, root_page_id, root_title, exclude_rules,
                     global_count=None, version_tracker=None):
        os.makedirs(output_dir, exist_ok=True)
        if version_tracker is None:
            version_tracker = self._load_version_tracker(output_dir)
        print(f"  边扫描边保存...")
        all_pages = self.traverse_and_save_recursive(
            output_dir, root_page_id, exclude_rules, global_count or [0],
            version_tracker
        )
        self._save_version_tracker(output_dir, version_tracker)
        structure_content = self.generate_structure_tree(all_pages, root_title)
        structure_file = os.path.join(output_dir, "structure.md")
        with open(structure_file, "w", encoding="utf-8") as f:
            f.write(structure_content)
        print(f"  已生成结构树: structure.md")
        print(f"  该站点共 {len(all_pages)} 页")
        return len(all_pages)


def main():
    token = load_token()
    sites = load_sites()
    extractor = ConfluenceExtractor(token, DEFAULT_BASE_URL)
    total_sites = len(sites)
    total_pages = 0
    global_count = [0]

    print(f"\n从 {CSV_FILE} 读取到 {total_sites} 个CF站点配置")
    print(f"输出目录: {OUTPUT_BASE.resolve()}")

    for i, site in enumerate(sites, 1):
        page_id = site["page_id"]
        exclude_rules = site["exclude"]
        site_dir = os.path.join(OUTPUT_BASE, f"site_{page_id}")

        print(f"\n========== 站点 {i}/{total_sites} ==========")
        print(f"根页面ID: {page_id}")
        print(f"排除规则: {exclude_rules if exclude_rules else '无'}")
        print(f"输出: {site_dir}")

        title, _, _ = extractor.get_page_version(page_id)
        if not title:
            title = f"site_{page_id}"
        print(f"根页面: {title}")
        print(f"开始边扫描边保存...")

        version_tracker = extractor._load_version_tracker(site_dir)
        count = extractor.extract_site(site_dir, page_id, title, exclude_rules,
                                       global_count, version_tracker)
        total_pages += count

    print(f"\n========== 全部完成 ==========")
    print(f"共处理 {total_sites} 个站点")
    print(f"总计保存 {total_pages} 个页面")


if __name__ == "__main__":
    main()
