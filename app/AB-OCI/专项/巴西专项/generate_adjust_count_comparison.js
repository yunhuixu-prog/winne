const fs = require("fs");
const sharp = require("sharp");

const inputPath =
  "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/Adjust打勾同时使用子项数分布_巴西vs整体_202606.csv";
const svgPath =
  "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西Adjust同时调整子项数占比对比_202606.svg";
const pngPath =
  "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西Adjust同时调整子项数占比对比_202606.png";

const lines = fs.readFileSync(inputPath, "utf8").trim().split(/\r?\n/);
const rows = lines.slice(1).map((line) => {
  const [label, brazilCount, brazilShare, overallCount, overallShare, gap] =
    line.split(",");
  return {
    label,
    brazilCount: Number(brazilCount),
    brazilShare: Number(brazilShare),
    overallCount: Number(overallCount),
    overallShare: Number(overallShare),
    gap: Number(gap),
  };
});

const brazilTotal = rows.reduce((sum, row) => sum + row.brazilCount, 0);
const overallTotal = rows.reduce((sum, row) => sum + row.overallCount, 0);
const brazilMean = 2.71698939;
const overallMean = 2.67606321;

const width = 1600;
const height = 1160;
const cardX = 48;
const cardY = 180;
const cardW = 1504;
const headerH = 86;
const rowH = 88;
const labelX = 88;
const brazilBarX = 420;
const overallBarX = 870;
const barW = 300;
const gapX = 1440;
const maxShare = 0.42;

const esc = (value) =>
  String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
const pct = (value) => `${(value * 100).toFixed(2)}%`;
const signed = (value, suffix = "pp") =>
  `${value >= 0 ? "+" : "−"}${Math.abs(value).toFixed(2)}${suffix}`;
const fmt = (value) => value.toLocaleString("en-US");

let body = "";
rows.forEach((row, index) => {
  const y = cardY + headerH + index * rowH;
  const centerY = y + 44;
  const brazilLength = Math.max(2, (row.brazilShare / maxShare) * barW);
  const overallLength = Math.max(2, (row.overallShare / maxShare) * barW);
  const fill = index % 2 === 0 ? "#FFFFFF" : "#FAFBFD";
  const gapColor = row.gap >= 0 ? "#245FD6" : "#D86F2B";
  const label = row.label === "7+" ? "7个及以上" : `${row.label}个`;

  body += `
    <rect x="${cardX}" y="${y}" width="${cardW}" height="${rowH}" fill="${fill}"/>
    <line x1="${cardX + 24}" y1="${y + rowH}" x2="${cardX + cardW - 24}" y2="${y + rowH}" stroke="#E5EAF1"/>
    <text x="${labelX}" y="${centerY + 7}" class="rowLabel">${esc(label)}</text>

    <rect x="${brazilBarX}" y="${centerY - 8}" width="${barW}" height="16" rx="8" fill="#E9EEF7"/>
    <rect x="${brazilBarX}" y="${centerY - 8}" width="${brazilLength}" height="16" rx="8" fill="#2F6BFF"/>
    <text x="${brazilBarX + barW + 24}" y="${centerY + 7}" class="value brazil">${pct(row.brazilShare)}</text>

    <rect x="${overallBarX}" y="${centerY - 8}" width="${barW}" height="16" rx="8" fill="#E9EEF7"/>
    <rect x="${overallBarX}" y="${centerY - 8}" width="${overallLength}" height="16" rx="8" fill="#FF8A3D"/>
    <text x="${overallBarX + barW + 24}" y="${centerY + 7}" class="value overall">${pct(row.overallShare)}</text>

    <text x="${gapX}" y="${centerY + 7}" text-anchor="middle" class="gap" fill="${gapColor}">${signed(row.gap)}</text>`;
});

const meanY = cardY + headerH + rows.length * rowH;
const meanCenterY = meanY + 50;
const brazilMeanLength = (brazilMean / 3.0) * barW;
const overallMeanLength = (overallMean / 3.0) * barW;
body += `
  <rect x="${cardX}" y="${meanY}" width="${cardW}" height="100" fill="#EEF4FF"/>
  <text x="${labelX}" y="${meanCenterY + 7}" class="meanLabel">平均调整子项数</text>
  <rect x="${brazilBarX}" y="${meanCenterY - 8}" width="${barW}" height="16" rx="8" fill="#DCE6F7"/>
  <rect x="${brazilBarX}" y="${meanCenterY - 8}" width="${brazilMeanLength}" height="16" rx="8" fill="#2F6BFF"/>
  <text x="${brazilBarX + barW + 24}" y="${meanCenterY + 7}" class="meanValue brazil">${brazilMean.toFixed(2)}个</text>
  <rect x="${overallBarX}" y="${meanCenterY - 8}" width="${barW}" height="16" rx="8" fill="#DCE6F7"/>
  <rect x="${overallBarX}" y="${meanCenterY - 8}" width="${overallMeanLength}" height="16" rx="8" fill="#FF8A3D"/>
  <text x="${overallBarX + barW + 24}" y="${meanCenterY + 7}" class="meanValue overall">${overallMean.toFixed(2)}个</text>
  <text x="${gapX}" y="${meanCenterY + 7}" text-anchor="middle" class="meanGap" fill="#245FD6">+${(brazilMean - overallMean).toFixed(2)}个</text>`;

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
  <rect width="${width}" height="${height}" fill="#F6F8FC"/>
  <style>
    text { font-family: "PingFang SC", "Hiragino Sans GB", "Helvetica Neue", Arial, sans-serif; fill:#172033; }
    .title { font-size:42px; font-weight:700; }
    .subtitle { font-size:20px; fill:#718096; }
    .legend { font-size:18px; font-weight:600; fill:#45546A; }
    .head { font-size:20px; font-weight:700; fill:#334155; }
    .headNote { font-size:15px; fill:#8491A5; }
    .rowLabel { font-size:22px; font-weight:600; fill:#334155; }
    .value { font-size:21px; font-weight:700; }
    .brazil { fill:#245FD6; }
    .overall { fill:#D86F2B; }
    .gap { font-size:21px; font-weight:700; }
    .meanLabel { font-size:23px; font-weight:700; fill:#1F3F77; }
    .meanValue { font-size:23px; font-weight:750; }
    .meanGap { font-size:23px; font-weight:750; }
    .foot { font-size:16px; fill:#7B8799; }
  </style>

  <text x="64" y="68" class="title">Adjust 同时调整子项数占比｜巴西 vs 整体</text>
  <text x="64" y="108" class="subtitle">2026年6月 · 每条 Adjust 打勾事件为一次观察 · 非默认值子项数</text>
  <circle cx="1120" cy="64" r="8" fill="#2F6BFF"/>
  <text x="1138" y="71" class="legend">巴西</text>
  <circle cx="1245" cy="64" r="8" fill="#FF8A3D"/>
  <text x="1263" y="71" class="legend">整体</text>
  <text x="64" y="146" class="subtitle">巴西 n=${fmt(brazilTotal)} ｜ 整体 n=${fmt(overallTotal)}（整体包含巴西）</text>

  <rect x="${cardX}" y="${cardY}" width="${cardW}" height="${headerH + rows.length * rowH + 100}" rx="20" fill="#FFFFFF" stroke="#DDE4EE" stroke-width="2"/>
  <rect x="${cardX}" y="${cardY}" width="${cardW}" height="${headerH}" rx="20" fill="#F1F4F9"/>
  <rect x="${cardX}" y="${cardY + headerH - 20}" width="${cardW}" height="20" fill="#F1F4F9"/>
  <text x="${labelX}" y="${cardY + 39}" class="head">同时调整子项数</text>
  <text x="${labelX}" y="${cardY + 65}" class="headNote">最终值非默认值</text>
  <text x="${brazilBarX}" y="${cardY + 39}" class="head">巴西占比</text>
  <text x="${brazilBarX}" y="${cardY + 65}" class="headNote">事件数 / 巴西 Adjust 打勾事件</text>
  <text x="${overallBarX}" y="${cardY + 39}" class="head">整体占比</text>
  <text x="${overallBarX}" y="${cardY + 65}" class="headNote">事件数 / 整体 Adjust 打勾事件</text>
  <text x="${gapX}" y="${cardY + 39}" text-anchor="middle" class="head">Gap</text>
  <text x="${gapX}" y="${cardY + 65}" text-anchor="middle" class="headNote">巴西 − 整体</text>

  ${body}

  <text x="64" y="1112" class="foot">注：滑杆值≠0，或 ai_auto=1，记为使用1个子项；“0个”可能包含参数最终回到默认值的事件。</text>
  <text x="1536" y="1112" text-anchor="end" class="foot">数据源：AirBrush 神舟事件表</text>
</svg>`;

fs.writeFileSync(svgPath, svg, "utf8");
sharp(Buffer.from(svg))
  .resize({ width: 2400 })
  .png({ compressionLevel: 9 })
  .toFile(pngPath)
  .then(() => console.log(pngPath));
