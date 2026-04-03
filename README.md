# myToolbox

適用於 AI CLI 助手（GitHub Copilot CLI、Claude Code 或任何支援 skills 協定的工具）的技能集合。

## 技能清單

### 🎨 [excalidraw](skills/excalidraw/)

從程式碼庫分析自動產生 `.excalidraw` 架構圖，並支援匯出為 PNG/SVG。

- 分析任意程式碼庫（Node.js、Python、Java、Go 等），自動識別元件、服務與資料流
- 產生符合規格的 `.excalidraw` JSON，包含正確的直角箭頭、色彩分類元素與文字綁定
- 透過 Node.js CLI（`export.cjs`）匯出 PNG/SVG，Playwright 作為備用方案
- 附帶參考文件：JSON 格式、色彩配置、範例、驗證規則、匯出流程

### 📈 [mermaid](skills/mermaid/)

將 Mermaid 文字圖（`.mmd`）轉換為 PNG/SVG 圖片，適合文件、簡報與流程說明。

- 使用 Node.js CLI（`render.cjs`）進行跨平台無頭渲染（Windows/macOS/Linux）
- 支援多種圖表類型：flowchart、sequence、class、ER、gantt、mindmap、gitGraph 等
- 可調整輸出參數：`--theme`、`--scale`、`--background-color`、`--width`、`--height`
- 附帶 README 與參考文件，包含語法速查、樣式設定與圖表範例

### 📊 [pptx](skills/pptx/)

產生可在 Microsoft Office 中直接開啟、不出現修復警告的 `.pptx` 簡報檔。

- 純 PowerShell 實作，無需外部套件（不需要 python-pptx 或 npm）
- 嚴格遵守 OOXML 規範（sldMasterId 範圍、sldId 範圍、命名空間規則等）
- 支援多種投影片版型：標題、內容、章節分隔、圖片、表格
- 附帶 `lib/validate-pptx.ps1`：跨平台驗證與自動修復腳本
- 附帶參考文件：套件結構、XML 範本、投影片版型、驗證規則

## 目錄結構

```
skills/
├── excalidraw/
│   ├── SKILL.md          # AI 指令
│   ├── lib/
│   │   ├── export.cjs
│   │   └── package.json
│   └── references/       # json-format、colors、examples、validation、export
├── mermaid/
│   ├── SKILL.md          # AI 指令
│   ├── README.md         # 使用者說明文件
│   ├── lib/
│   │   ├── render.cjs
│   │   └── package.json
│   └── references/       # diagram-types、syntax-cheatsheet、theming
└── pptx/
    ├── SKILL.md          # AI 指令
    ├── lib/
    │   └── validate-pptx.ps1   # 跨平台驗證與自動修復腳本
    └── references/       # package-structure、xml-templates、slide-types、validation
```
