const fs = require("fs");
const sharp = require("sharp");

const inputPath =
  "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/Adjust打勾同时使用子项数分布_巴西vs整体_202606.csv";
const svgPath =
  "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西Adjust同时调整子项数占比对比_202606.svg";
const pngPath =
  "/Users/xuyunhui/Documents/项目/outputs/019f839e-6d3f-7a81-b0ac-450473a2e302/巴西Adjust同时调整子项数占比对比_202606.png";

const lines = fs.readFileSync(inputPath, "utf8").trim().split(/\r?\n/);
const data = lines.slice(1).map((line) => {
  const [label, brazilCount, brazilShare, overallCount, overallShare] =
    line.split(",");
  return {
    label,
    brazilCount: Number(brazilCount),
    brazilShare: Number(brazilShare),
    overallCount: Number(overallCount),
    overallShare: Number(overallShare),
  };
});

const brazilTotal = data.reduce((sum, row) => sum + row.brazilCount, 0);
const overallTotal = data.reduce((sum, row) => sum + row.overallCount, 0);
const brazilMean = 2.71698939;
const overallMean = 2.67606321;

const width = 1600;
const height = 1080;
const chartX = 112;
const chartY = 350;
const chartW = 1380;
const chartH = 520;
const baselineY = chartY + chartH;
const maxShare = 0.45;
const groupW = chartW / data.length;
const barW = 48;
const innerGap = 14;

const fmt = (value) => value.toLocaleString("en-US");
const pct = (value) => `${(value * 100).toFixed(2)}%`;

let grid = "";
for (let tick = 0; tick <= 40; tick += 10) {
  const y = baselineY - (tick / 45) * chartH;
  grid += `
    <line x1="${chartX}" y1="${y}" x2="${chartX + chartW}" y2="${y}" stroke="${tick === 0 ? "#AEB9C8" : "#E3E8F0"}" stroke-width="${tick === 0 ? 2 : 1}"/>
    <text x="${chartX - 20}" y="${y + 7}" text-anchor="end" class="tick">${tick}%</text>`;
}

let bars = "";
data.forEach((row, index) => {
  const centerX = chartX + groupW * index + groupW / 2;
  const brazilH = (row.brazilShare / maxShare) * chartH;
  const overallH = (row.overallShare / maxShare) * chartH;
  const brazilX = centerX - innerGap / 2 - barW;
  const overallX = centerX + innerGap / 2;
  const brazilY = baselineY - brazilH;
  const overallY = baselineY - overallH;
  const label = row.label === "7+" ? "7+" : row.label;

  bars += `
    <rect x="${brazilX}" y="${brazilY}" width="${barW}" height="${brazilH}" rx="8" fill="#2F6BFF"/>
    <rect x="${overallX}" y="${overallY}" width="${barW}" height="${overallH}" rx="8" fill="#FF8A3D"/>
    <text x="${brazilX + barW / 2}" y="${brazilY - 13}" text-anchor="middle" class="barValue brazil">${pct(row.brazilShare)}</text>
    <text x="${overallX + barW / 2}" y="${overallY - 13}" text-anchor="middle" class="barValue overall">${pct(row.overallShare)}</text>
    <text x="${centerX}" y="${baselineY + 42}" text-anchor="middle" class="category">${label}</text>`;
});

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
  <rect width="${width}" height="${height}" fill="#F6F8FC"/>
  <style>
    text { font-family: "PingFang SC", "Hiragino Sans GB", "Helvetica Neue", Arial, sans-serif; fill:#172033; }
    .title { font-size:42px; font-weight:700; }
    .subtitle { font-size:20px; fill:#718096; }
    .cardTitle { font-size:18px; font-weight:650; fill:#526176; }
    .cardValue { font-size:32px; font-weight:750; }
    .cardGap { font-size:18px; font-weight:650; fill:#526176; }
    .legend { font-size:18px; font-weight:650; fill:#45546A; }
    .tick { font-size:17px; fill:#7B8799; }
    .axisTitle { font-size:18px; font-weight:650; fill:#526176; }
    .category { font-size:20px; font-weight:650; fill:#334155; }
    .barValue { font-size:17px; font-weight:700; }
    .brazil { fill:#245FD6; }
    .overall { fill:#D86F2B; }
    .foot { font-size:16px; fill:#7B8799; }
  </style>

  <text x="64" y="68" class="title">Adjust 同时调整子项数分布｜巴西 vs 整体</text>
  <text x="64" y="108" class="subtitle">2026年6月 · 每条 Adjust 打勾事件为一次观察 · 纵轴为事件占比</text>

  <rect x="64" y="142" width="560" height="126" rx="18" fill="#FFFFFF" stroke="#DCE3ED" stroke-width="2"/>
  <text x="92" y="178" class="cardTitle">平均调整子项数</text>
  <circle cx="103" cy="217" r="8" fill="#2F6BFF"/>
  <text x="122" y="228" class="cardValue brazil">巴西 ${brazilMean.toFixed(2)}个</text>
  <circle cx="326" cy="217" r="8" fill="#FF8A3D"/>
  <text x="345" y="228" class="cardValue overall">整体 ${overallMean.toFixed(2)}个</text>
  <text x="92" y="253" class="cardGap">巴西较整体 +${(brazilMean - overallMean).toFixed(2)}个</text>

  <circle cx="1110" cy="183" r="9" fill="#2F6BFF"/>
  <text x="1131" y="190" class="legend">巴西</text>
  <circle cx="1222" cy="183" r="9" fill="#FF8A3D"/>
  <text x="1243" y="190" class="legend">整体</text>
  <text x="1490" y="228" text-anchor="end" class="subtitle">巴西 n=${fmt(brazilTotal)} ｜ 整体 n=${fmt(overallTotal)}</text>
  <text x="1490" y="257" text-anchor="end" class="subtitle">整体包含巴西</text>

  <rect x="48" y="304" width="1504" height="650" rx="22" fill="#FFFFFF" stroke="#DDE4EE" stroke-width="2"/>
  <text x="${chartX}" y="333" class="axisTitle">事件占比</text>
  ${grid}
  ${bars}
  <text x="${chartX + chartW / 2}" y="${baselineY + 84}" text-anchor="middle" class="axisTitle">同时调整的子项数量</text>

  <text x="64" y="1013" class="foot">注：滑杆值≠0，或 ai_auto=1，记为使用1个子项；“0个”可能包含参数最终回到默认值的事件。</text>
  <text x="1536" y="1013" text-anchor="end" class="foot">数据源：AirBrush 神舟事件表</text>
</svg>`;

fs.writeFileSync(svgPath, svg, "utf8");
sharp(Buffer.from(svg))
  .resize({ width: 2400 })
  .png({ compressionLevel: 9 })
  .toFile(pngPath)
  .then(() => console.log(pngPath));
