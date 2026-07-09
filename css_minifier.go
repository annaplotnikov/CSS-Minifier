// css_minifier.go
package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"regexp"
	"strings"
)

type CSSMinifier struct {
	RemoveComments bool
	PreserveSpaces bool
	RemoveSemicolon bool
	ShrinkColors   bool
}

func NewCSSMinifier(removeComments, preserveSpaces, removeSemicolon, shrinkColors bool) *CSSMinifier {
	return &CSSMinifier{
		RemoveComments: removeComments,
		PreserveSpaces: preserveSpaces,
		RemoveSemicolon: removeSemicolon,
		ShrinkColors:   shrinkColors,
	}
}

func (m *CSSMinifier) Minify(css string) string {
	// Remove comments
	if m.RemoveComments {
		re := regexp.MustCompile(`/\*.*?\*/`)
		css = re.ReplaceAllString(css, "")
	}

	// Strip lines and join
	lines := strings.Split(css, "\n")
	var cleaned []string
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed != "" {
			cleaned = append(cleaned, trimmed)
		}
	}
	css = strings.Join(cleaned, "")

	if !m.PreserveSpaces {
		// Remove spaces around special characters
		re := regexp.MustCompile(`\s*([{}:;,>+~()])\s*`)
		css = re.ReplaceAllString(css, "$1")
		// Remove spaces after commas (but keep one if needed? we remove all)
		re = regexp.MustCompile(`\s*,\s*`)
		css = re.ReplaceAllString(css, ",")
	}

	if m.RemoveSemicolon {
		re := regexp.MustCompile(`;}`)
		css = re.ReplaceAllString(css, "}")
	}

	if m.ShrinkColors {
		// #RRGGBB to #RGB
		re := regexp.MustCompile(`#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3`)
		css = re.ReplaceAllString(css, "#$1$2$3")
		// 0px etc to 0
		re = regexp.MustCompile(`\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)`)
		css = re.ReplaceAllString(css, "0")
		// leading zeros
		re = regexp.MustCompile(`\b0+\.(\d+)`)
		css = re.ReplaceAllString(css, ".$1")
	}

	// Remove extra newlines
	re := regexp.MustCompile(`\n\s*\n`)
	css = re.ReplaceAllString(css, "\n")
	return strings.TrimSpace(css)
}

func main() {
	var inputFile, outputFile string
	var noComments, preserveSpaces, noSemicolon, shrinkColors bool
	flag.StringVar(&inputFile, "i", "", "Input CSS file (or stdin)")
	flag.StringVar(&outputFile, "o", "", "Output file (or stdout)")
	flag.BoolVar(&noComments, "no-comments", false, "Keep comments")
	flag.BoolVar(&preserveSpaces, "preserve-spaces", false, "Preserve whitespace")
	flag.BoolVar(&noSemicolon, "no-semicolon", false, "Keep trailing semicolons")
	flag.BoolVar(&shrinkColors, "shrink-colors", false, "Shrink hex colors")
	flag.Parse()

	var content string
	if inputFile != "" {
		data, err := ioutil.ReadFile(inputFile)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		content = string(data)
	} else {
		stat, _ := os.Stdin.Stat()
		if (stat.Mode() & os.ModeCharDevice) == 0 {
			scanner := bufio.NewScanner(os.Stdin)
			var sb strings.Builder
			for scanner.Scan() {
				sb.WriteString(scanner.Text())
				sb.WriteString("\n")
			}
			content = sb.String()
		} else {
			fmt.Fprintln(os.Stderr, "No input provided.")
			os.Exit(1)
		}
	}

	minifier := NewCSSMinifier(!noComments, preserveSpaces, !noSemicolon, shrinkColors)
	minified := minifier.Minify(content)

	if outputFile != "" {
		err := ioutil.WriteFile(outputFile, []byte(minified), 0644)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
	} else {
		fmt.Println(minified)
	}
}
