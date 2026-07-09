// css_minifier.js
const fs = require('fs');
const readline = require('readline');

class CSSMinifier {
    constructor(options = {}) {
        this.removeComments = options.removeComments !== false;
        this.preserveSpaces = options.preserveSpaces || false;
        this.removeSemicolon = options.removeSemicolon !== false;
        this.shrinkColors = options.shrinkColors || false;
    }

    minify(css) {
        if (this.removeComments) {
            css = css.replace(/\/\*[\s\S]*?\*\//g, '');
        }

        const lines = css.split('\n').map(l => l.trim()).filter(l => l);
        css = lines.join('');

        if (!this.preserveSpaces) {
            // Remove spaces around special chars
            css = css.replace(/\s*([{}:;,>+~()])\s*/g, '$1');
            css = css.replace(/\s*,\s*/g, ',');
        }

        if (this.removeSemicolon) {
            css = css.replace(/;}/g, '}');
        }

        if (this.shrinkColors) {
            // #RRGGBB to #RGB
            css = css.replace(/#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3/g, '#$1$2$3');
            // 0px to 0
            css = css.replace(/\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)/g, '0');
            // leading zeros
            css = css.replace(/\b0+\.(\d+)/g, '.$1');
        }

        css = css.replace(/\n\s*\n/g, '\n');
        return css.trim();
    }
}

function readStdin() {
    return new Promise((resolve) => {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout,
            terminal: false
        });
        let data = '';
        rl.on('line', (line) => { data += line + '\n'; });
        rl.on('close', () => { resolve(data); });
    });
}

async function main() {
    const args = process.argv.slice(2);
    let inputFile = null;
    let outputFile = null;
    let noComments = false;
    let preserveSpaces = false;
    let noSemicolon = false;
    let shrinkColors = false;

    for (let i = 0; i < args.length; i++) {
        if (args[i] === '--no-comments') noComments = true;
        else if (args[i] === '--preserve-spaces') preserveSpaces = true;
        else if (args[i] === '--no-semicolon') noSemicolon = true;
        else if (args[i] === '--shrink-colors') shrinkColors = true;
        else if (args[i] === '-o') { outputFile = args[++i]; }
        else if (!inputFile) inputFile = args[i];
    }

    let content;
    if (inputFile) {
        content = fs.readFileSync(inputFile, 'utf8');
    } else {
        content = await readStdin();
    }

    const minifier = new CSSMinifier({
        removeComments: !noComments,
        preserveSpaces,
        removeSemicolon: !noSemicolon,
        shrinkColors
    });
    const minified = minifier.minify(content);

    if (outputFile) {
        fs.writeFileSync(outputFile, minified, 'utf8');
    } else {
        console.log(minified);
    }
}

main().catch(console.error);
