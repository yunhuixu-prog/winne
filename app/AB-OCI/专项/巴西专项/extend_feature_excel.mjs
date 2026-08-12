import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

process.on("uncaughtException", (error) => {
  console.error(`BUILD_ERROR: ${error.message}`);
  process.exit(1);
});
process.on("unhandledRejection", (error) => {
  console.error(`BUILD_ERROR: ${error?.message ?? error}`);
  process.exit(1);
});

const inputPath = "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西专项_功能数据_202606.xlsx";
const outputDir = "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302";
const outputPath = path.join(outputDir, "巴西专项_功能数据及排序表_202606.xlsx");
const qaDir = path.join(outputDir, "qa_tables");
const inspectOnly = process.argv.includes("--inspect-only");

const input = await FileBlob.load(inputPath);
const workbook = await SpreadsheetFile.importXlsx(input);
const sourceSheet = workbook.worksheets.getItem("功能数据");

const overview = await workbook.inspect({
  kind: "workbook,sheet,table",
  maxChars: 5000,
  tableMaxRows: 8,
  tableMaxCols: 10,
});
console.log(overview.ndjson);

await fs.mkdir(qaDir, { recursive: true });
const sourcePreview = await workbook.render({ sheetName: "功能数据", range: "A1:J24", scale: 1.25, format: "png" });
await fs.writeFile(path.join(qaDir, "00_原始功能数据.png"), new Uint8Array(await sourcePreview.arrayBuffer()));

if (inspectOnly) {
  console.log(JSON.stringify({ preview: path.join(qaDir, "00_原始功能数据.png") }));
  process.exit(0);
}

const sourceValues = sourceSheet.getRange("A4:J159").values;
const sourceHeaders = sourceValues[0];
const col = Object.fromEntries(sourceHeaders.map((name, i) => [name, i]));
const records = sourceValues.slice(1)
  .map((row, i) => ({
    sourceRow: i + 5,
    country: row[col["国家维度"]],
    feature: row[col["功能"]],
    exposure: Number(row[col["曝光人数"]] ?? 0),
    enter: Number(row[col["进入人数"]] ?? 0),
    tick: Number(row[col["打勾人数"]] ?? 0),
    save: Number(row[col["保存人数"]] ?? 0),
    penetration: Number(row[col["进入渗透率"]] ?? 0),
    revenue: Number(row[col["订阅收入（分成后）"]] ?? 0),
  }))
  .filter((r) => r.country && r.feature);

const markets = ["巴西", "整体", "美国", "英国", "墨西哥"];
const byMarket = Object.fromEntries(markets.map((m) => [m, records.filter((r) => r.country === m)]));
const sortDesc = (items, field) => [...items].sort((a, b) => b[field] - a[field] || a.feature.localeCompare(b.feature, "en"));
const src = (columnLetter, row) => `='功能数据'!${columnLetter}${row}`;

const titleStyle = {
  fill: "#17365D",
  font: { bold: true, color: "#FFFFFF", size: 16 },
  verticalAlignment: "center",
  horizontalAlignment: "left",
};
const subtitleStyle = {
  fill: "#DCE6F1",
  font: { color: "#385D8A", size: 10 },
  verticalAlignment: "center",
};
const headerStyle = {
  fill: "#4472C4",
  font: { bold: true, color: "#FFFFFF" },
  horizontalAlignment: "center",
  verticalAlignment: "center",
  wrapText: true,
};
const bodyBorder = { insideHorizontal: { style: "thin", color: "#E7E6E6" } };

function setupSheet(sheet, title, subtitle, endCol) {
  sheet.showGridLines = false;
  sheet.mergeCells(`A1:${endCol}1`);
  sheet.getRange("A1").values = [[title]];
  sheet.getRange(`A1:${endCol}1`).format = titleStyle;
  sheet.getRange(`A1:${endCol}1`).format.rowHeight = 32;
  sheet.mergeCells(`A2:${endCol}2`);
  sheet.getRange("A2").values = [[subtitle]];
  sheet.getRange(`A2:${endCol}2`).format = subtitleStyle;
  sheet.getRange(`A2:${endCol}2`).format.rowHeight = 24;
}

function finishTable(sheet, range, tableName, numberRanges = [], percentRanges = [], currencyRanges = []) {
  const table = sheet.tables.add(range, true, tableName);
  table.style = "TableStyleMedium2";
  table.showFilterButton = true;
  for (const r of numberRanges) sheet.getRange(r).format.numberFormat = "#,##0";
  for (const r of percentRanges) sheet.getRange(r).format.numberFormat = "0.00%";
  for (const r of currencyRanges) sheet.getRange(r).format.numberFormat = '"$"#,##0.00';
}

// 表 1
const t1 = workbook.worksheets.add("表1_巴西进入排序");
setupSheet(t1, "表1｜巴西功能进入人数排序", "按巴西日均进入人数从高到低；渗透率为 2026 年 6 月日均", "D");
const t1Headers = ["功能", "巴西进入人数", "巴西进入渗透率", "整体进入渗透率"];
t1.getRange("A4:D4").values = [t1Headers];
t1.getRange("A4:D4").format = headerStyle;
const t1Sorted = sortDesc(byMarket["巴西"], "enter");
const overallByFeature = new Map(byMarket["整体"].map((r) => [r.feature, r]));
for (let i = 0; i < t1Sorted.length; i++) {
  const r = t1Sorted[i];
  const o = overallByFeature.get(r.feature);
  t1.getRange(`A${i + 5}:D${i + 5}`).formulas = [[src("B", r.sourceRow), src("D", r.sourceRow), src("G", r.sourceRow), src("G", o.sourceRow)]];
}
const t1Last = 4 + t1Sorted.length;
t1.getRange(`A5:D${t1Last}`).format.borders = bodyBorder;
t1.getRange("A:A").format.columnWidth = 22;
t1.getRange("B:B").format.columnWidth = 18;
t1.getRange("C:D").format.columnWidth = 20;
t1.freezePanes.freezeRows(4);
finishTable(t1, `A4:D${t1Last}`, "BrazilEntryRanking", [`B5:B${t1Last}`], [`C5:D${t1Last}`]);
t1.getRange(`B5:B${t1Last}`).conditionalFormats.add("dataBar", { color: "#5B9BD5", gradient: true });

// 表 2
const t2 = workbook.worksheets.add("表2_各市场渗透率");
setupSheet(t2, "表2｜各市场功能进入渗透率完整排序", "每个市场独立按进入渗透率从高到低排列；包含全部 31 个已对齐功能", "K");
const t2Headers = ["排名", ...markets.flatMap((m) => [`${m}功能`, `${m}进入渗透率`])];
t2.getRange("A4:K4").values = [t2Headers];
t2.getRange("A4:K4").format = headerStyle;
const penetrationRanks = Object.fromEntries(markets.map((m) => [m, sortDesc(byMarket[m], "penetration")]));
for (let i = 0; i < 31; i++) {
  const excelRow = i + 5;
  t2.getRange(`A${excelRow}`).values = [[i + 1]];
  const formulas = [];
  for (const m of markets) {
    const r = penetrationRanks[m][i];
    formulas.push(src("B", r.sourceRow), src("G", r.sourceRow));
  }
  t2.getRange(`B${excelRow}:K${excelRow}`).formulas = [formulas];
}
const t2Last = 35;
t2.getRange(`A5:K${t2Last}`).format.borders = bodyBorder;
t2.getRange("A:A").format.columnWidth = 8;
for (const c of ["B", "D", "F", "H", "J"]) t2.getRange(`${c}:${c}`).format.columnWidth = 18;
for (const c of ["C", "E", "G", "I", "K"]) t2.getRange(`${c}:${c}`).format.columnWidth = 17;
t2.freezePanes.freezeRows(4);
t2.freezePanes.freezeColumns(1);
finishTable(t2, `A4:K${t2Last}`, "MarketPenetrationRanking", [`A5:A${t2Last}`], ["C5:C35", "E5:E35", "G5:G35", "I5:I35", "K5:K35"]);

// 表 3
const t3 = workbook.worksheets.add("表3_各市场订阅毛利");
setupSheet(t3, "表3｜各市场功能订阅毛利完整排序", "每个市场独立按 2026 年 6 月订阅收入（分成后）从高到低排列；Skin 子功能使用归因 L4", "K");
const t3Headers = ["排名", ...markets.flatMap((m) => [`${m}功能`, `${m}订阅毛利`])];
t3.getRange("A4:K4").values = [t3Headers];
t3.getRange("A4:K4").format = headerStyle;
const revenueRanks = Object.fromEntries(markets.map((m) => [m, sortDesc(byMarket[m], "revenue")]));
for (let i = 0; i < 31; i++) {
  const excelRow = i + 5;
  t3.getRange(`A${excelRow}`).values = [[i + 1]];
  const formulas = [];
  for (const m of markets) {
    const r = revenueRanks[m][i];
    formulas.push(src("B", r.sourceRow), src("J", r.sourceRow));
  }
  t3.getRange(`B${excelRow}:K${excelRow}`).formulas = [formulas];
}
const t3Last = 35;
t3.getRange(`A5:K${t3Last}`).format.borders = bodyBorder;
t3.getRange("A:A").format.columnWidth = 8;
for (const c of ["B", "D", "F", "H", "J"]) t3.getRange(`${c}:${c}`).format.columnWidth = 18;
for (const c of ["C", "E", "G", "I", "K"]) t3.getRange(`${c}:${c}`).format.columnWidth = 18;
t3.freezePanes.freezeRows(4);
t3.freezePanes.freezeColumns(1);
finishTable(t3, `A4:K${t3Last}`, "MarketRevenueRanking", [`A5:A${t3Last}`], [], ["C5:C35", "E5:E35", "G5:G35", "I5:I35", "K5:K35"]);

// 表 4
const t4 = workbook.worksheets.add("表4_巴西曝光排序");
t4.showGridLines = false;
t4.mergeCells("A1:K1");
t4.getRange("A1").values = [["表4｜巴西曝光人数排序及巴西/整体行为指标"]];
t4.getRange("A1:K1").format = titleStyle;
t4.getRange("A1:K1").format.rowHeight = 32;
t4.getRange("A2:E2").values = [["DAU 参数", "巴西", 301029, "整体", 731237]];
t4.getRange("A2:E2").format = subtitleStyle;
t4.getRange("C2").format.numberFormat = "#,##0";
t4.getRange("E2").format.numberFormat = "#,##0";
t4.mergeCells("F2:K2");
t4.getRange("F2").values = [["按巴西日均曝光人数从高到低；行为指标均为 2026 年 6 月日均"]];
t4.getRange("F2:K2").format = subtitleStyle;
const t4Headers = ["功能", "巴西 DAU", "巴西曝光人数", "巴西进入人数", "巴西打勾人数", "巴西保存人数", "整体 DAU", "整体曝光人数", "整体进入人数", "整体打勾人数", "整体保存人数"];
t4.getRange("A4:K4").values = [t4Headers];
t4.getRange("A4:K4").format = headerStyle;
const exposureRanks = sortDesc(byMarket["巴西"], "exposure");
for (let i = 0; i < exposureRanks.length; i++) {
  const excelRow = i + 5;
  const b = exposureRanks[i];
  const o = overallByFeature.get(b.feature);
  t4.getRange(`A${excelRow}:K${excelRow}`).formulas = [[
    src("B", b.sourceRow), "=$C$2", src("C", b.sourceRow), src("D", b.sourceRow), src("E", b.sourceRow), src("F", b.sourceRow),
    "=$E$2", src("C", o.sourceRow), src("D", o.sourceRow), src("E", o.sourceRow), src("F", o.sourceRow),
  ]];
}
const t4Last = 4 + exposureRanks.length;
t4.getRange(`A5:K${t4Last}`).format.borders = bodyBorder;
t4.getRange("A:A").format.columnWidth = 20;
t4.getRange("B:K").format.columnWidth = 16;
t4.freezePanes.freezeRows(4);
t4.freezePanes.freezeColumns(1);
finishTable(t4, `A4:K${t4Last}`, "BrazilExposureRanking", [`B5:K${t4Last}`]);
t4.getRange(`C5:C${t4Last}`).conditionalFormats.add("dataBar", { color: "#5B9BD5", gradient: true });

const checks = [];
for (const [sheet, range] of [["表1_巴西进入排序", "A1:D12"], ["表2_各市场渗透率", "A1:K12"], ["表3_各市场订阅毛利", "A1:K12"], ["表4_巴西曝光排序", "A1:K12"]]) {
  const check = await workbook.inspect({ kind: "table", range: `${sheet}!${range}`, include: "values,formulas", tableMaxRows: 12, tableMaxCols: 12 });
  checks.push(check.ndjson);
}
console.log(checks.join("\n"));
const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 200 },
  summary: "final formula error scan",
});
console.log(errors.ndjson);

for (const [sheetName, range] of [
  ["功能数据", "A1:J24"],
  ["口径说明", "A1:D14"],
  ["表1_巴西进入排序", "A1:D35"],
  ["表2_各市场渗透率", "A1:K35"],
  ["表3_各市场订阅毛利", "A1:K35"],
  ["表4_巴西曝光排序", "A1:K35"],
]) {
  const preview = await workbook.render({ sheetName, range, scale: 1.15, format: "png" });
  await fs.writeFile(path.join(qaDir, `${sheetName}.png`), new Uint8Array(await preview.arrayBuffer()));
}

await fs.mkdir(outputDir, { recursive: true });
const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
console.log(JSON.stringify({ outputPath, records: records.length, sheetsAdded: 4 }));
