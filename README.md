# 🗜️ CSS Minifier – Multi‑Language Edition

A fast and robust **CSS minifier** that strips unnecessary whitespace, comments, and redundant characters from CSS files, reducing their size for production use.  
Built in **7 programming languages** – perfect for build pipelines, learning, or integration.

## ✨ Features
- **Remove comments** – strips `/* ... */` blocks.
- **Condense whitespace** – collapses multiple spaces, tabs, and newlines into single spaces (or removes entirely between tokens).
- **Remove trailing semicolons** – deletes the last semicolon inside a rule block (optional).
- **Shrink values** – converts `0px`, `0em`, etc. to `0`; and `#RRGGBB` to `#RGB` when possible (optional).
- **Preserve required spaces** – keeps spaces where necessary (e.g., `font-family: Arial, sans-serif`).
- **Batch mode** – process multiple files from the command line.
- **Interactive CLI** – choose input source and options.

## 🗂 Languages & Files
| Language          | File                |
|-------------------|---------------------|
| Python            | `css_minifier.py`   |
| Go                | `css_minifier.go`   |
| JavaScript        | `css_minifier.js`   |
| C#                | `CssMinifier.cs`    |
| Java              | `CssMinifier.java`  |
| Ruby              | `css_minifier.rb`   |
| Swift             | `css_minifier.swift`|

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python css_minifier.py [input.css] [-o output.css]` |
| Go       | `go run css_minifier.go [input.css] [output.css]` |
| JavaScript | `node css_minifier.js [input.css] [output.css]` |
| C#       | `dotnet run` (or `csc CssMinifier.cs && CssMinifier.exe input.css output.css`) |
| Java     | `javac CssMinifier.java && java CssMinifier input.css output.css` |
| Ruby     | `ruby css_minifier.rb input.css [output.css]` |
| Swift    | `swift css_minifier.swift input.css [output.css]` |

If no input file is given, the program reads from standard input.  
If output is omitted, the result is printed to stdout.

## 📊 Example
**Input CSS:**
```css
/* This is a comment */
body {
  margin: 0;
  padding: 0;
  background-color: #ffffff;
}
h1 {
  color: #ff0000;
  font-size: 16px;
}
Minified output:

css
body{margin:0;padding:0;background-color:#fff}h1{color:red;font-size:16px}
🔧 Options
--no-comments – keep comments (default: remove).

--preserve-spaces – do not collapse whitespace inside values.

--no-semicolon – do not remove trailing semicolons.

--shrink-colors – shorten hex colors (e.g., #ff0000 → #f00) and names (e.g., red → #f00 – optional, advanced).

🤝 Contributing
Add support for inline CSS minification, more color optimizations, or streaming – PRs welcome!

📜 License
MIT – use freely.
