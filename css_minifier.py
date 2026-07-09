
---

# 💻 Code Implementations

## 1. Python (`css_minifier.py`)

```python
# css_minifier.py
import re
import sys
import argparse

class CSSMinifier:
    def __init__(self, remove_comments=True, preserve_spaces=False, remove_semicolon=True, shrink_colors=False):
        self.remove_comments = remove_comments
        self.preserve_spaces = preserve_spaces
        self.remove_semicolon = remove_semicolon
        self.shrink_colors = shrink_colors

    def minify(self, css):
        # Remove comments
        if self.remove_comments:
            css = re.sub(r'/\*.*?\*/', '', css, flags=re.DOTALL)

        # Remove leading/trailing whitespace from lines and join
        lines = css.splitlines()
        css = ''.join(line.strip() for line in lines)

        # Remove spaces between tokens (but keep required ones)
        if not self.preserve_spaces:
            # Remove spaces after { , ; > + ~ ] ( ) etc., but keep before/after values if needed
            # Basic: remove all whitespace between selectors, braces, etc.
            # We'll use a more careful approach: remove whitespace that is not necessary
            # For simplicity, we'll remove all spaces except inside strings and between two identifiers? 
            # Better: use a regex that removes spaces around certain characters
            css = re.sub(r'\s*([{}:;,>+~()])\s*', r'\1', css)
            # Remove spaces before/after commas? But need to keep space after comma in font-family?
            # We'll keep spaces after commas for readability, but minify removes them
            # Actually, for CSS minification, it's safe to remove spaces after commas
            css = re.sub(r'\s*,\s*', ',', css)

        # Remove trailing semicolon before closing brace
        if self.remove_semicolon:
            css = re.sub(r';}', '}', css)

        # Shrink colors (simple version)
        if self.shrink_colors:
            # Convert #RRGGBB to #RGB
            css = re.sub(r'#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3', r'#\1\2\3', css)
            # Convert 0px, 0em, etc. to 0 (but careful with 0.5px)
            css = re.sub(r'\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)', '0', css)
            # Remove leading zeros from decimals
            css = re.sub(r'\b0+\.(\d+)', r'.\1', css)

        # Remove multiple newlines
        css = re.sub(r'\n\s*\n', '\n', css)
        return css.strip()

def main():
    parser = argparse.ArgumentParser(description='CSS Minifier')
    parser.add_argument('input', nargs='?', help='Input CSS file (or stdin)')
    parser.add_argument('-o', '--output', help='Output file (or stdout)')
    parser.add_argument('--no-comments', action='store_true', help='Keep comments')
    parser.add_argument('--preserve-spaces', action='store_true', help='Preserve whitespace')
    parser.add_argument('--no-semicolon', action='store_true', help='Keep trailing semicolons')
    parser.add_argument('--shrink-colors', action='store_true', help='Shrink hex colors')
    args = parser.parse_args()

    if args.input:
        with open(args.input, 'r', encoding='utf-8') as f:
            content = f.read()
    else:
        content = sys.stdin.read()

    minifier = CSSMinifier(
        remove_comments=not args.no_comments,
        preserve_spaces=args.preserve_spaces,
        remove_semicolon=not args.no_semicolon,
        shrink_colors=args.shrink_colors
    )
    minified = minifier.minify(content)

    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(minified)
    else:
        print(minified)

if __name__ == '__main__':
    main()
