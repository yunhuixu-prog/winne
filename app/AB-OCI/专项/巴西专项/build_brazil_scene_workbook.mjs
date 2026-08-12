import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const outputDir = "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西用户日场景分析_202607";
const outputPath = path.join(outputDir, "巴西用户日场景分析_202607.xlsx");
const previewDir = path.join(outputDir, "_xlsx_previews");

const palette = {
  ink: "#182235",
  muted: "#7E8CA3",
  navy: "#273B59",
  blue: "#4472C4",
  blueLight: "#EAF0FA",
  orange: "#ED7D31",
  orangeLight: "#FFF1E7",
  gold: "#C49A3A",
  green: "#4E8B75",
  grey: "#F5F7FA",
  border: "#DCE2EA",
  white: "#FFFFFF",
};

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = "";
  let quoted = false;
  const clean = text.replace(/^\uFEFF/, "");
  for (let i = 0; i < clean.length; i += 1) {
    const char = clean[i];
    if (quoted) {
      if (char === '"' && clean[i + 1] === '"') {
        value += '"';
        i += 1;
      } else if (char === '"') {
        quoted = false;
      } else {
        value += char;
      }
    } else if (char === '"') {
      quoted = true;
    } else if (char === ",") {
      row.push(value);
      value = "";
    } else if (char === "\n") {
      row.push(value.replace(/\r$/, ""));
      rows.push(row);
      row = [];
      value = "";
    } else {
      value += char;
    }
  }
  if (value.length > 0 || row.length > 0) {
    row.push(value.replace(/\r$/, ""));
    rows.push(row);
  }
  return rows;
}

function typedValue(value, header) {
  if (value === "") return null;
  if (header.includes("日期") && /^\d{8}(?:\.0)?$/.test(value)) {
    return value.replace(/\.0$/, "");
  }
  if (/^-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?$/.test(value)) {
    return Number(value);
  }
  return value;
}

function colName(index) {
  let n = index + 1;
  let out = "";
  while (n > 0) {
    const rem = (n - 1) % 26;
    out = String.fromCharCode(65 + rem) + out;
    n = Math.floor((n - 1) / 26);
  }
  return out;
}

function formatForHeader(header) {
  if (header.includes("毛利")) return '"$"#,##0.00';
  if (
    header.includes("率") ||
    header.includes("占比") ||
    header === "占DAU" ||
    header === "Y占DAU" ||
    header === "Lift" ||
    header === "Jaccard"
  ) {
    return header === "Lift" ? '0.00"x"' : "0.0%";
  }
  if (
    header.includes("PV") ||
    header.includes("UV") ||
    header.includes("用户日") ||
    header.includes("人数") ||
    header === "数量"
  ) {
    return "#,##0";
  }
  if (header.includes("频次") || header.includes("功能数")) return "0.00";
  return null;
}

function widthForHeader(header) {
  if (header === "场景定义" || header === "说明") return 250;
  if (header.includes("组合")) return 260;
  if (header.includes("功能标准化键")) return 160;
  if (header.includes("来源功能") || header === "功能") return 150;
  if (header.includes("场景") || header.includes("维度") || header.includes("分层")) return 130;
  if (header.includes("日期")) return 95;
  if (header.includes("毛利")) return 120;
  if (header.length >= 10) return 140;
  return 110;
}

function safeRateFormula(numeratorCol, denominatorCol, row) {
  return `=IFERROR(${numeratorCol}${row}/${denominatorCol}${row},0)`;
}

function applyDerivedFormulas(sheet, headers, startRow, rowCount) {
  const index = new Map(headers.map((header, i) => [header, i]));
  const denominatorForScene = index.has("场景使用用户日") ? "场景使用用户日" : "进入用户日";
  const formulaPairs = new Map([
    ["场景用户日渗透率", ["场景使用用户日", "DAU用户日"]],
    ["日均进入频次", ["进入PV", "场景使用用户日"]],
    ["进入频次", ["进入PV", "进入用户日"]],
    ["进入打勾率", ["打勾用户日", denominatorForScene]],
    ["进入保存率", ["保存用户日", denominatorForScene]],
    ["打勾保存率", ["保存用户日", "打勾用户日"]],
    ["D1留存率", ["D1留存用户日", "D1样本用户日"]],
    ["D7留存率", ["D7留存用户日", "D7样本用户日"]],
    ["场景订阅页曝光率", ["订阅页曝光用户日", "场景使用用户日"]],
    ["曝光订阅成功率", ["订阅成功用户日", "订阅页曝光用户日"]],
    ["订阅成功付费率", ["订阅付费用户日", "订阅成功用户日"]],
    ["实际D0首购关联率", ["实际D0首购用户日", "场景使用用户日"]],
    ["实际D7首购关联率", ["实际D7首购用户日", "实际D7首购样本用户日"]],
    ["实际D0续费关联率", ["实际D0续费用户日", "场景使用用户日"]],
    ["实际D7续费关联率", ["实际D7续费用户日", "实际D7续费样本用户日"]],
    ["使用X时同时使用Y占比", ["XY共用用户日", "X用户日"]],
  ]);
  for (const [targetHeader, [numHeader, denHeader]] of formulaPairs.entries()) {
    if (!index.has(targetHeader) || !index.has(numHeader) || !index.has(denHeader)) continue;
    const targetCol = colName(index.get(targetHeader));
    const numCol = colName(index.get(numHeader));
    const denCol = colName(index.get(denHeader));
    sheet.getRange(`${targetCol}${startRow}`).formulas = [[safeRateFormula(numCol, denCol, startRow)]];
    if (rowCount > 1) {
      sheet.getRange(`${targetCol}${startRow}:${targetCol}${startRow + rowCount - 1}`).fillDown();
    }
  }
  if (index.has("Lift") && index.has("使用X时同时使用Y占比") && index.has("Y占DAU")) {
    const targetCol = colName(index.get("Lift"));
    const shareCol = colName(index.get("使用X时同时使用Y占比"));
    const baseCol = colName(index.get("Y占DAU"));
    sheet.getRange(`${targetCol}${startRow}`).formulas = [
      [safeRateFormula(shareCol, baseCol, startRow)],
    ];
    if (rowCount > 1) {
      sheet.getRange(`${targetCol}${startRow}:${targetCol}${startRow + rowCount - 1}`).fillDown();
    }
  }
}

async function addCsvSheet(workbook, name, fileName, subtitle, options = {}) {
  const text = await fs.readFile(path.join(outputDir, fileName), "utf8");
  const parsed = parseCsv(text);
  const headers = parsed[0];
  const data = parsed.slice(1).filter((row) => row.some((value) => value !== ""));
  const matrix = data.map((row) => headers.map((header, i) => typedValue(row[i] ?? "", header)));
  const sheet = workbook.worksheets.add(name);
  const lastCol = colName(headers.length - 1);
  sheet.showGridLines = false;
  sheet.getRange(`A1:${lastCol}1`).merge();
  sheet.getRange("A1").values = [[name]];
  sheet.getRange("A1").format = {
    fill: palette.navy,
    font: { bold: true, color: palette.white, size: 18 },
    verticalAlignment: "center",
  };
  sheet.getRange("A1").format.rowHeightPx = 40;
  sheet.getRange(`A2:${lastCol}2`).merge();
  sheet.getRange("A2").values = [[subtitle]];
  sheet.getRange("A2").format = {
    fill: palette.blueLight,
    font: { color: palette.muted, size: 10 },
    wrapText: true,
  };
  sheet.getRange("A2").format.rowHeightPx = 34;
  sheet.getRange(`A4:${lastCol}4`).values = [headers];
  sheet.getRange(`A4:${lastCol}4`).format = {
    fill: palette.blue,
    font: { bold: true, color: palette.white, size: 10 },
    horizontalAlignment: "center",
    verticalAlignment: "center",
    wrapText: true,
    borders: { preset: "all", style: "thin", color: palette.border },
  };
  sheet.getRange(`A4:${lastCol}4`).format.rowHeightPx = 42;
  if (matrix.length > 0) {
    const startRow = 5;
    const endRow = startRow + matrix.length - 1;
    sheet.getRange(`A${startRow}:${lastCol}${endRow}`).values = matrix;
    applyDerivedFormulas(sheet, headers, startRow, matrix.length);
    sheet.getRange(`A${startRow}:${lastCol}${endRow}`).format = {
      font: { color: palette.ink, size: 9 },
      verticalAlignment: "center",
      borders: {
        insideHorizontal: { style: "thin", color: palette.border },
        bottom: { style: "thin", color: palette.border },
      },
    };
    for (let r = startRow; r <= endRow; r += 2) {
      sheet.getRange(`A${r}:${lastCol}${r}`).format.fill = palette.grey;
    }
    headers.forEach((header, i) => {
      const col = colName(i);
      const numberFormat = formatForHeader(header);
      if (numberFormat) {
        sheet.getRange(`${col}${startRow}:${col}${endRow}`).format.numberFormat = numberFormat;
      }
      sheet.getRange(`${col}:${col}`).format.columnWidthPx = widthForHeader(header);
      if (
        header.includes("率") ||
        header.includes("占比") ||
        header === "占DAU" ||
        header === "Y占DAU" ||
        header === "Lift"
      ) {
        sheet
          .getRange(`${col}${startRow}:${col}${endRow}`)
          .conditionalFormats.add("dataBar", {
            color: palette.orange,
            gradient: false,
            thresholds: ["min", "max"],
          });
      }
    });
    sheet.freezePanes.freezeRows(4);
    if (options.table !== false && matrix.length <= 5000) {
      const table = sheet.tables.add(`A4:${lastCol}${endRow}`, true, `${name.replace(/[^\w\u4e00-\u9fa5]/g, "")}Table`);
      table.style = "TableStyleMedium2";
      table.showBandedRows = true;
    }
  }
  return { sheet, headers, rows: matrix };
}

const workbook = Workbook.create();
workbook.comments.setSelf({ displayName: "xuyunhui" });
const overview = workbook.worksheets.add("概览");

const core = await addCsvSheet(
  workbook,
  "场景核心",
  "01_场景核心指标.csv",
  "2026年7月1—30日｜巴西｜同一用户同一天｜比例列由分子/分母公式计算",
);
await addCsvSheet(
  workbook,
  "用户分层",
  "02_场景分层指标.csv",
  "分层包括新老、安装天数、新用户渠道/自然、付费状态、平台；场景不互斥",
);
await addCsvSheet(
  workbook,
  "日趋势",
  "03_场景日趋势.csv",
  "每日场景渗透、漏斗、留存与订阅指标；共30天、6类场景",
);
await addCsvSheet(
  workbook,
  "功能表现",
  "04_场景功能表现.csv",
  "功能归入六类场景后的进入、打勾、保存表现；功能可在同一天组合使用",
);
await addCsvSheet(
  workbook,
  "场景关联",
  "05_场景关联矩阵明细.csv",
  "X用户同日同时使用Y的比例、Lift与Jaccard；Lift>1代表高于随机共用预期",
);
await addCsvSheet(
  workbook,
  "多场景组合",
  "06_多场景组合.csv",
  "同一用户同一天使用的场景集合；按用户日从高到低",
);
await addCsvSheet(
  workbook,
  "单场景组合",
  "07_单场景功能组合.csv",
  "每个场景内部的功能组合；按场景用户日占比排序",
);
await addCsvSheet(
  workbook,
  "数量分布",
  "08_功能及场景数分布.csv",
  "同一用户同一天使用的场景数或场景内功能数分布",
);
await addCsvSheet(
  workbook,
  "订阅来源",
  "09_订阅来源功能.csv",
  "SUB_SOURCE直接来源归因；毛利为分成后美元，不与PAY_EVENT关联毛利相加",
);

overview.showGridLines = false;
overview.getRange("A1:T1").merge();
overview.getRange("A1").values = [["巴西用户日场景分析｜2026年7月"]];
overview.getRange("A1").format = {
  fill: palette.navy,
  font: { bold: true, color: palette.white, size: 20 },
  verticalAlignment: "center",
};
overview.getRange("A1").format.rowHeightPx = 46;
overview.getRange("A2:T2").merge();
overview.getRange("A2").values = [[
  "同一用户同一天｜2026-07-01 至 2026-07-30｜DAU用户日 8,484,472｜六类场景覆盖 83.4%",
]];
overview.getRange("A2").format = {
  fill: palette.blueLight,
  font: { color: palette.muted, size: 11 },
};
overview.getRange("A4:K4").values = [[
  "场景",
  "渗透率",
  "进入打勾率",
  "进入保存率",
  "D1留存率",
  "D7留存率",
  "订阅曝光率",
  "曝光成功率",
  "订阅毛利",
  "毛利占比",
  "每万场景用户日毛利",
]];
overview.getRange("A4:K4").format = {
  fill: palette.blue,
  font: { bold: true, color: palette.white, size: 10 },
  horizontalAlignment: "center",
  wrapText: true,
  borders: { preset: "all", style: "thin", color: palette.border },
};
for (let i = 0; i < 6; i += 1) {
  const row = 5 + i;
  const sourceRow = 5 + i;
  overview.getRange(`A${row}:I${row}`).formulas = [[
    `='场景核心'!A${sourceRow}`,
    `='场景核心'!E${sourceRow}`,
    `='场景核心'!I${sourceRow}`,
    `='场景核心'!K${sourceRow}`,
    `='场景核心'!P${sourceRow}`,
    `='场景核心'!S${sourceRow}`,
    `='场景核心'!V${sourceRow}`,
    `='场景核心'!X${sourceRow}`,
    `='场景核心'!AA${sourceRow}`,
  ]];
  overview.getRange(`J${row}`).formulas = [[`=IFERROR(I${row}/SUM($I$5:$I$10),0)`]];
  overview.getRange(`K${row}`).formulas = [[`=IFERROR(I${row}/'场景核心'!D${sourceRow}*10000,0)`]];
}
overview.getRange("A5:K10").format = {
  font: { color: palette.ink, size: 10 },
  borders: { preset: "all", style: "thin", color: palette.border },
};
for (let row = 6; row <= 10; row += 2) overview.getRange(`A${row}:K${row}`).format.fill = palette.grey;
overview.getRange("B5:H10").format.numberFormat = "0.0%";
overview.getRange("I5:I10").format.numberFormat = '"$"#,##0';
overview.getRange("J5:J10").format.numberFormat = "0.0%";
overview.getRange("K5:K10").format.numberFormat = '"$"#,##0.0';
overview.getRange("A:A").format.columnWidthPx = 150;
overview.getRange("B:H").format.columnWidthPx = 105;
overview.getRange("I:K").format.columnWidthPx = 125;

overview.getRange("A13:K13").merge();
overview.getRange("A13").values = [["业务启发"]];
overview.getRange("A13").format = {
  fill: palette.navy,
  font: { bold: true, color: palette.white, size: 14 },
};
const findings = [
  ["1｜核心留存路径", "人像结构精修渗透率50.7%、毛利$35.1k；自然轻修漏斗最健康。两者同日重叠230.6万用户日，建议组织成连续人像修图路径。"],
  ["2｜渠道拉新错配", "渠道新用户玩法尝试渗透40.6%，但D1仅10.0%；应将Hair等玩法流量承接到Face、Reshape、Filters，并追踪次日场景迁移。"],
  ["3｜跨场景工作流", "至少使用一个场景的用户日中68.0%会使用2个以上场景；氛围出片是任务、玩法和AI后的共同收尾枢纽。"],
  ["4｜高价值任务工具", "任务型工具渗透仅15.5%，但每万场景用户日毛利$152.5、D7首购关联1.91%，优先优化完成质量、等待反馈和付费墙回流。"],
  ["5｜平台差异", "iOS偏人像/自然轻修，Android偏氛围/工具/玩法；Android应优先保证快速编辑和低中端机性能。"],
];
overview.getRange("A14:K18").values = findings.map(([label, text]) => [label, text, null, null, null, null, null, null, null, null, null]);
for (let row = 14; row <= 18; row += 1) {
  overview.getRange(`B${row}:K${row}`).merge();
}
overview.getRange("A14:A18").format = {
  fill: palette.orangeLight,
  font: { bold: true, color: palette.ink, size: 10 },
  verticalAlignment: "center",
  borders: { preset: "all", style: "thin", color: palette.border },
};
overview.getRange("B14:K18").format = {
  font: { color: palette.ink, size: 10 },
  wrapText: true,
  verticalAlignment: "center",
  borders: { preset: "all", style: "thin", color: palette.border },
};
overview.getRange("A14:K18").format.rowHeightPx = 46;

const penetrationChart = overview.charts.add("bar", overview.getRange("A4:B10"));
penetrationChart.title = "六类场景用户日渗透率";
penetrationChart.hasLegend = false;
penetrationChart.xAxis = { axisType: "textAxis", textStyle: { fontSize: 9 } };
penetrationChart.yAxis = { numberFormatCode: "0%", min: 0, max: 0.6 };
penetrationChart.setPosition("M4", "T16");

const grossChart = overview.charts.add("bar", {
  chartType: "bar",
  title: "六类场景订阅毛利",
  hasLegend: false,
});
const grossSeries = grossChart.series.add("订阅毛利");
grossSeries.categoryFormula = "'概览'!$A$5:$A$10";
grossSeries.formula = "'概览'!$I$5:$I$10";
grossSeries.fill = palette.orange;
grossChart.yAxis = { numberFormatCode: "$#,##0", min: 0 };
grossChart.xAxis = { axisType: "textAxis", textStyle: { fontSize: 9 } };
grossChart.setPosition("M18", "T30");
overview.freezePanes.freezeRows(4);

const qa = workbook.worksheets.add("口径与质检");
qa.showGridLines = false;
qa.getRange("A1:H1").merge();
qa.getRange("A1").values = [["口径、来源与数据质检"]];
qa.getRange("A1").format = {
  fill: palette.navy,
  font: { bold: true, color: palette.white, size: 18 },
};
qa.getRange("A3:B3").values = [["项目", "内容"]];
qa.getRange("A3:B3").format = {
  fill: palette.blue,
  font: { bold: true, color: palette.white },
};
const notes = [
  ["分析周期", "2026-07-01 至 2026-07-30"],
  ["国家", "巴西"],
  ["分析粒度", "同一用户同一天"],
  ["DAU分母", "8,484,472 用户日"],
  ["神舟任务", "35139862"],
  ["SQL", "/Users/xuyunhui/Documents/项目/app/AB-OCI/专项/巴西专项/巴西用户日场景分析一次性宽取数_202607.sql"],
  ["原始结果", "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西用户日场景分析一次性宽取数_202607.csv"],
  ["场景关系", "六类场景不互斥；同一用户日可使用多个场景"],
  ["SUB_SOURCE", "订阅来源功能直接归因；用于订阅页曝光、订阅成功、付费与毛利"],
  ["PAY_EVENT", "实际首购/续费事件；用于D0/D7场景关联，不与SUB_SOURCE毛利相加"],
  ["玩法限制", "Hair Dye、Hair Enrich、Hairstyles、MyKit等打勾/保存回传不完整，玩法漏斗会被低估"],
  ["覆盖率", "功能活跃用户日映射到六类场景的覆盖率为99.3%；六类场景覆盖DAU用户日83.4%"],
];
qa.getRange(`A4:B${3 + notes.length}`).values = notes;
qa.getRange(`A4:B${3 + notes.length}`).format = {
  borders: { preset: "all", style: "thin", color: palette.border },
  wrapText: true,
  verticalAlignment: "top",
  font: { color: palette.ink, size: 10 },
};
for (let row = 4; row <= 3 + notes.length; row += 2) qa.getRange(`A${row}:B${row}`).format.fill = palette.grey;
qa.getRange("A:A").format.columnWidthPx = 140;
qa.getRange("B:B").format.columnWidthPx = 620;

const qaText = await fs.readFile(path.join(outputDir, "11_数据质检.csv"), "utf8");
const qaRows = parseCsv(qaText);
qa.getRange("A18:F18").values = [qaRows[0]];
qa.getRange("A18:F18").format = {
  fill: palette.blue,
  font: { bold: true, color: palette.white },
};
const qaMatrix = qaRows.slice(1).filter((row) => row.some((value) => value !== ""));
qa.getRange(`A19:F${18 + qaMatrix.length}`).values = qaMatrix;
qa.getRange(`A19:F${18 + qaMatrix.length}`).format = {
  borders: { preset: "all", style: "thin", color: palette.border },
  font: { color: palette.ink, size: 9 },
};
qa.getRange("F:F").format.columnWidthPx = 300;

const mapText = await fs.readFile(path.join(outputDir, "00_场景功能映射.csv"), "utf8");
const mapRows = parseCsv(mapText);
qa.getRange("H3:K3").values = [mapRows[0]];
qa.getRange("H3:K3").format = {
  fill: palette.blue,
  font: { bold: true, color: palette.white },
};
const mapMatrix = mapRows.slice(1).filter((row) => row.some((value) => value !== ""));
qa.getRange(`H4:K${3 + mapMatrix.length}`).values = mapMatrix;
qa.getRange(`H4:K${3 + mapMatrix.length}`).format = {
  borders: { preset: "all", style: "thin", color: palette.border },
  font: { color: palette.ink, size: 9 },
};
qa.getRange("H:H").format.columnWidthPx = 130;
qa.getRange("I:I").format.columnWidthPx = 160;
qa.getRange("J:J").format.columnWidthPx = 140;
qa.getRange("K:K").format.columnWidthPx = 260;
qa.freezePanes.freezeRows(3);

await fs.mkdir(outputDir, { recursive: true });
await fs.mkdir(previewDir, { recursive: true });

const inspect = await workbook.inspect({
  kind: "table",
  range: "概览!A1:K18",
  include: "values,formulas",
  tableMaxRows: 20,
  tableMaxCols: 12,
  maxChars: 8000,
});
console.log(inspect.ndjson);

const formulaErrors = await workbook.inspect({
  kind: "match",
  searchTerm: "#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A",
  options: { useRegex: true, maxResults: 300 },
  summary: "final formula error scan",
});
console.log(formulaErrors.ndjson);

for (const sheetName of [
  "概览",
  "场景核心",
  "用户分层",
  "日趋势",
  "功能表现",
  "场景关联",
  "多场景组合",
  "单场景组合",
  "数量分布",
  "订阅来源",
  "口径与质检",
]) {
  const preview = await workbook.render({
    sheetName,
    range: sheetName === "概览" ? "A1:T30" : undefined,
    autoCrop: sheetName === "概览" ? undefined : "all",
    scale: 1,
    format: "png",
  });
  const bytes = new Uint8Array(await preview.arrayBuffer());
  await fs.writeFile(path.join(previewDir, `${sheetName}.png`), bytes);
}

const xlsx = await SpreadsheetFile.exportXlsx(workbook);
await xlsx.save(outputPath);
console.log(JSON.stringify({ outputPath, sheets: workbook.worksheets.items.map((sheet) => sheet.name) }));
