import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

process.on("uncaughtException", (error) => {
  console.error(`BUILD_ERROR: ${error.message}`);
  process.exit(1);
});
process.on("unhandledRejection", (error) => {
  console.error(`BUILD_ERROR: ${error?.message ?? error}`);
  process.exit(1);
});

const sourcePath = "/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/巴西专项_功能数据_202606.json";
const outputDir = "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302";
const outputPath = path.join(outputDir, "巴西专项_功能数据_202606.xlsx");
const qaDir = path.join(outputDir, "qa");

const payload = JSON.parse(await fs.readFile(sourcePath, "utf8"));
const headers = [
  "国家维度",
  "功能",
  "曝光人数",
  "进入人数",
  "打勾人数",
  "保存人数",
  "进入渗透率",
  "订阅成功人数",
  "付费人数",
  "订阅收入（分成后）",
];

const rows = payload.rows.map((r) => headers.map((h) => r[h] ?? 0));
const workbook = Workbook.create();
const dataSheet = workbook.worksheets.add("功能数据");
const notesSheet = workbook.worksheets.add("口径说明");

dataSheet.showGridLines = false;
dataSheet.mergeCells("A1:J1");
dataSheet.getRange("A1").values = [["巴西专项｜功能行为与订阅数据"]];
dataSheet.getRange("A2:J2").merge();
dataSheet.getRange("A2").values = [["时间：2026-06-01 至 2026-06-30｜行为人数与渗透率为日均；订阅人数与收入为月累计"]];
dataSheet.getRange("A4:J4").values = [headers];
dataSheet.getRange(`A5:J${4 + rows.length}`).values = rows;

const titleFormat = {
  fill: "#17365D",
  font: { bold: true, color: "#FFFFFF", size: 16 },
  verticalAlignment: "center",
  horizontalAlignment: "left",
};
dataSheet.getRange("A1:J1").format = titleFormat;
dataSheet.getRange("A1:J1").format.rowHeight = 32;
dataSheet.getRange("A2:J2").format = {
  fill: "#DCE6F1",
  font: { color: "#385D8A", size: 10 },
  verticalAlignment: "center",
};
dataSheet.getRange("A2:J2").format.rowHeight = 24;
dataSheet.getRange("A4:J4").format = {
  fill: "#4472C4",
  font: { bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
  borders: { preset: "outside", style: "thin", color: "#B4C6E7" },
};
dataSheet.getRange("A4:J4").format.rowHeight = 30;

const lastRow = 4 + rows.length;
dataSheet.getRange(`A5:B${lastRow}`).format.horizontalAlignment = "left";
dataSheet.getRange(`C5:F${lastRow}`).format.numberFormat = "#,##0";
dataSheet.getRange(`G5:G${lastRow}`).format.numberFormat = "0.00%";
dataSheet.getRange(`H5:I${lastRow}`).format.numberFormat = "#,##0";
dataSheet.getRange(`J5:J${lastRow}`).format.numberFormat = '"$"#,##0.00';
dataSheet.getRange(`A5:J${lastRow}`).format.borders = {
  insideHorizontal: { style: "thin", color: "#E7E6E6" },
};
dataSheet.getRange(`A5:J${lastRow}`).format.rowHeight = 20;
dataSheet.getRange(`A4:J${lastRow}`).format.autofitColumns();
dataSheet.getRange("A:A").format.columnWidth = 12;
dataSheet.getRange("B:B").format.columnWidth = 18;
dataSheet.getRange("C:F").format.columnWidth = 14;
dataSheet.getRange("G:G").format.columnWidth = 14;
dataSheet.getRange("H:I").format.columnWidth = 16;
dataSheet.getRange("J:J").format.columnWidth = 20;
dataSheet.freezePanes.freezeRows(4);
dataSheet.freezePanes.freezeColumns(2);

const table = dataSheet.tables.add(`A4:J${lastRow}`, true, "FunctionMetricsTable");
table.style = "TableStyleMedium2";

dataSheet.getRange(`G5:G${lastRow}`).conditionalFormats.add("colorScale", {
  colors: ["#FFFFFF", "#FFE699", "#70AD47"],
});
dataSheet.getRange(`J5:J${lastRow}`).conditionalFormats.add("dataBar", {
  color: "#5B9BD5",
  gradient: true,
});

notesSheet.showGridLines = false;
notesSheet.mergeCells("A1:D1");
notesSheet.getRange("A1").values = [["口径说明与数据来源"]];
notesSheet.getRange("A1:D1").format = titleFormat;
notesSheet.getRange("A1:D1").format.rowHeight = 32;
notesSheet.getRange("A3:D3").values = [["项目", "口径", "来源 / 看板", "备注"]];
notesSheet.getRange("A3:D3").format = {
  fill: "#4472C4",
  font: { bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "center",
};
const notes = [
  ["时间范围", "2026-06-01 至 2026-06-30", "—", "完整自然月筛选"],
  ["国家维度", "整体、巴西、美国、英国、墨西哥", "—", "整体包含巴西"],
  ["行为指标", "曝光、进入、打勾、保存人数及进入渗透率均为北斗返回日值的平均", "dashboardId=10015706；chartId=88513/88192/88217/88193/90774", "平台、新老、渠道、版本、付费状态均为整体；一级功能=图片编辑"],
  ["一般功能订阅", "订阅成功人数、付费人数、分成后收入为 6 月累计", "dashboardId=10015763；chartId=88544/88545/88546", "分类=Edit；按 L3 功能归因"],
  ["Skin 子功能订阅", "功能二级看板展示 Skin 子功能，订阅侧必须取 L4 对齐", "dashboardId=10015764；chartId=88556/88557/88558", "路径：Edit → Retouch → Skin → 四级子功能"],
  ["Detail 名称", "行为侧 Details 与订阅侧 Detail 对齐后统一输出为 Detail", "官方分级 mapping", "仅做名称标准化，不改变指标值"],
  ["免费策略", "仅巴西 Reshape、Resize 免费；其他国家均付费", "业务补充口径", "跨国订阅效率比较时需单独解释"],
  ["Skin 零值", "Smooth、Clean Skin 等若订阅列为 0，表示 6 月归因结果无记录或为 0", "Skin L4", "不能直接解释为没有商业价值"],
  ["行为看板", "https://beidou.tatstm.com/dashboard/10015706", "北斗 OCI", "图片编辑二级功能"],
  ["订阅 L3 看板", "https://beidou.tatstm.com/dashboard/10015763", "北斗 OCI", "一般功能归因"],
  ["订阅 L4 看板", "https://beidou.tatstm.com/dashboard/10015764", "北斗 OCI", "Skin 子功能归因"],
];
notesSheet.getRange(`A4:D${3 + notes.length}`).values = notes;
notesSheet.getRange(`A4:D${3 + notes.length}`).format = {
  verticalAlignment: "top",
  wrapText: true,
  borders: { insideHorizontal: { style: "thin", color: "#E7E6E6" } },
};
notesSheet.getRange("A:A").format.columnWidth = 18;
notesSheet.getRange("B:B").format.columnWidth = 48;
notesSheet.getRange("C:C").format.columnWidth = 58;
notesSheet.getRange("D:D").format.columnWidth = 38;
notesSheet.getRange(`A4:D${3 + notes.length}`).format.rowHeight = 38;
notesSheet.freezePanes.freezeRows(3);

await fs.mkdir(outputDir, { recursive: true });
await fs.mkdir(qaDir, { recursive: true });

const inspection = await workbook.inspect({
  kind: "table",
  range: "功能数据!A1:J12",
  include: "values,formulas",
  tableMaxRows: 12,
  tableMaxCols: 10,
});
console.log(inspection.ndjson);
const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 100 },
  summary: "final formula error scan",
});
console.log(errors.ndjson);

for (const [sheetName, range] of [["功能数据", "A1:J28"], ["口径说明", `A1:D${3 + notes.length}`]]) {
  const preview = await workbook.render({ sheetName, range, scale: 1.5, format: "png" });
  await fs.writeFile(path.join(qaDir, `${sheetName}.png`), new Uint8Array(await preview.arrayBuffer()));
}

const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
console.log(JSON.stringify({ outputPath, rows: rows.length, sheets: ["功能数据", "口径说明"] }));
