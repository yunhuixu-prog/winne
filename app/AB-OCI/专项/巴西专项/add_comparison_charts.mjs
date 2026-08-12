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

const inputPath = "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西专项_功能数据及排序表_202606.xlsx";
const outputDir = "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302";
const outputPath = path.join(outputDir, "巴西专项_功能数据排序及对比图_202606.xlsx");
const qaDir = path.join(outputDir, "qa_charts");
const inspectOnly = process.argv.includes("--inspect-only");

const input = await FileBlob.load(inputPath);
const workbook = await SpreadsheetFile.importXlsx(input);
const sourceSheet = workbook.worksheets.getItem("功能数据");

const before = await workbook.inspect({
  kind: "workbook,sheet,table,drawing",
  maxChars: 6000,
  tableMaxRows: 8,
  tableMaxCols: 12,
});
console.log(before.ndjson);

await fs.mkdir(qaDir, { recursive: true });
for (const [sheetName, range] of [["表2_各市场渗透率", "A1:K20"], ["表3_各市场订阅毛利", "A1:K20"]]) {
  const preview = await workbook.render({ sheetName, range, scale: 1.0, format: "png" });
  await fs.writeFile(path.join(qaDir, `原始_${sheetName}.png`), new Uint8Array(await preview.arrayBuffer()));
}
if (inspectOnly) {
  console.log(JSON.stringify({ inspectOnly: true }));
  process.exit(0);
}

const values = sourceSheet.getRange("A4:J159").values;
const headers = values[0];
const c = Object.fromEntries(headers.map((name, i) => [name, i]));
const records = values.slice(1).map((row, i) => ({
  sourceRow: i + 5,
  market: row[c["国家维度"]],
  feature: row[c["功能"]],
  penetration: Number(row[c["进入渗透率"]] ?? 0),
  revenue: Number(row[c["订阅收入（分成后）"]] ?? 0),
})).filter((r) => r.market && r.feature);

const markets = ["巴西", "整体", "美国", "英国", "墨西哥"];
const byKey = new Map(records.map((r) => [`${r.market}|${r.feature}`, r]));
const brazilRows = records.filter((r) => r.market === "巴西");
const src = (column, row, divisor = null) => divisor ? `='功能数据'!${column}${row}/${divisor}` : `='功能数据'!${column}${row}`;

const colors = {
  "巴西": "#F28E2B",
  "整体": "#4E79A7",
  "美国": "#59A14F",
  "英国": "#9C755F",
  "墨西哥": "#BAB0AC",
};
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
};

function addChartSheet({ name, title, subtitle, field, sourceColumn, divisor, numberFormat, chartTitle }) {
  const sheet = workbook.worksheets.add(name);
  sheet.showGridLines = false;
  sheet.mergeCells("A1:V1");
  sheet.getRange("A1").values = [[title]];
  sheet.getRange("A1:V1").format = titleStyle;
  sheet.getRange("A1:V1").format.rowHeight = 32;
  sheet.mergeCells("A2:V2");
  sheet.getRange("A2").values = [[subtitle]];
  sheet.getRange("A2:V2").format = subtitleStyle;
  sheet.getRange("A2:V2").format.rowHeight = 24;

  const sheetHeaders = ["功能", ...markets];
  sheet.getRange("A4:F4").values = [sheetHeaders];
  sheet.getRange("A4:F4").format = headerStyle;
  const sorted = [...brazilRows].sort((a, b) => b[field] - a[field] || a.feature.localeCompare(b.feature, "en"));
  for (let i = 0; i < sorted.length; i++) {
    const row = i + 5;
    const feature = sorted[i].feature;
    sheet.getRange(`A${row}`).formulas = [[src("B", sorted[i].sourceRow)]];
    const formulas = markets.map((market) => {
      const item = byKey.get(`${market}|${feature}`);
      return src(sourceColumn, item.sourceRow, divisor);
    });
    sheet.getRange(`B${row}:F${row}`).formulas = [formulas];
  }
  const lastRow = 4 + sorted.length;
  sheet.getRange(`B5:F${lastRow}`).format.numberFormat = numberFormat;
  sheet.getRange(`A5:F${lastRow}`).format.borders = { insideHorizontal: { style: "thin", color: "#E7E6E6" } };
  sheet.getRange("A:A").format.columnWidth = 20;
  sheet.getRange("B:F").format.columnWidth = 13;
  sheet.freezePanes.freezeRows(4);

  const chart = sheet.charts.add("bar", sheet.getRange(`A4:F${lastRow}`));
  chart.title = chartTitle;
  chart.titleTextStyle.fontSize = 13;
  chart.hasLegend = true;
  chart.xAxis = { textStyle: { fontSize: 8 } };
  chart.yAxis = { numberFormatCode: numberFormat, textStyle: { fontSize: 9 } };
  chart.setPosition("H4", "V58");
  const series = chart.series.items;
  for (let i = 0; i < series.length; i++) {
    const market = markets[i];
    series[i].fill = colors[market];
  }
  return { sheet, lastRow };
}

const penetration = addChartSheet({
  name: "图1_进入渗透率对比",
  title: "图1｜巴西与其他市场功能进入渗透率对比",
  subtitle: "全部功能按巴西进入渗透率从高到低排列；巴西用橙色突出，其他市场作为对照",
  field: "penetration",
  sourceColumn: "G",
  divisor: null,
  numberFormat: "0.0%",
  chartTitle: "功能进入渗透率：巴西 vs 其他市场",
});

const revenue = addChartSheet({
  name: "图2_订阅毛利对比",
  title: "图2｜巴西与其他市场功能订阅毛利对比",
  subtitle: "全部功能按巴西订阅毛利从高到低排列；单位为千美元（$k），Skin 子功能采用归因 L4",
  field: "revenue",
  sourceColumn: "J",
  divisor: 1000,
  numberFormat: '"$"0.0',
  chartTitle: "功能订阅毛利：巴西 vs 其他市场（$k）",
});

for (const [sheetName, range] of [["图1_进入渗透率对比", `A1:F${penetration.lastRow}`], ["图2_订阅毛利对比", `A1:F${revenue.lastRow}`]]) {
  const check = await workbook.inspect({ kind: "table,drawing", range: `${sheetName}!${range}`, include: "values,formulas", tableMaxRows: 12, tableMaxCols: 8, maxChars: 8000 });
  console.log(check.ndjson);
}
const errors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 200 },
  summary: "final formula error scan",
});
console.log(errors.ndjson);

for (const [sheetName, range] of [["图1_进入渗透率对比", "A1:V58"], ["图2_订阅毛利对比", "A1:V58"]]) {
  const preview = await workbook.render({ sheetName, range, scale: 0.85, format: "png" });
  await fs.writeFile(path.join(qaDir, `${sheetName}.png`), new Uint8Array(await preview.arrayBuffer()));
}

const drawingCheck = await workbook.inspect({ kind: "drawing", maxChars: 5000 });
console.log(drawingCheck.ndjson);

const output = await SpreadsheetFile.exportXlsx(workbook);
await output.save(outputPath);
console.log(JSON.stringify({ outputPath, chartsAdded: 2 }));
