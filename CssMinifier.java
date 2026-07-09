// CssMinifier.java
import java.io.*;
import java.util.regex.*;

public class CssMinifier {
    private boolean removeComments;
    private boolean preserveSpaces;
    private boolean removeSemicolon;
    private boolean shrinkColors;

    public CssMinifier(boolean removeComments, boolean preserveSpaces,
                       boolean removeSemicolon, boolean shrinkColors) {
        this.removeComments = removeComments;
        this.preserveSpaces = preserveSpaces;
        this.removeSemicolon = removeSemicolon;
        this.shrinkColors = shrinkColors;
    }

    public String minify(String css) {
        if (removeComments) {
            css = css.replaceAll("/\\*.*?\\*/", "");
        }

        String[] lines = css.split("\n");
        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            String trimmed = line.trim();
            if (!trimmed.isEmpty()) {
                sb.append(trimmed);
            }
        }
        css = sb.toString();

        if (!preserveSpaces) {
            css = css.replaceAll("\\s*([{}:;,>+~()])\\s*", "$1");
            css = css.replaceAll("\\s*,\\s*", ",");
        }

        if (removeSemicolon) {
            css = css.replaceAll(";}", "}");
        }

        if (shrinkColors) {
            css = css.replaceAll("#([0-9a-fA-F])\\1([0-9a-fA-F])\\2([0-9a-fA-F])\\3", "#$1$2$3");
            css = css.replaceAll("\\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)", "0");
            css = css.replaceAll("\\b0+\\.(\\d+)", ".$1");
        }

        css = css.replaceAll("\n\\s*\n", "\n");
        return css.trim();
    }

    public static void main(String[] args) throws IOException {
        String inputFile = null;
        String outputFile = null;
        boolean noComments = false;
        boolean preserveSpaces = false;
        boolean noSemicolon = false;
        boolean shrinkColors = false;

        for (int i = 0; i < args.length; i++) {
            if ("--no-comments".equals(args[i])) noComments = true;
            else if ("--preserve-spaces".equals(args[i])) preserveSpaces = true;
            else if ("--no-semicolon".equals(args[i])) noSemicolon = true;
            else if ("--shrink-colors".equals(args[i])) shrinkColors = true;
            else if ("-o".equals(args[i]) && i+1 < args.length) outputFile = args[++i];
            else if (inputFile == null) inputFile = args[i];
        }

        String content;
        if (inputFile != null) {
            try (BufferedReader reader = new BufferedReader(new FileReader(inputFile))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                content = sb.toString();
            }
        } else {
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(System.in))) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                content = sb.toString();
            }
        }

        CssMinifier minifier = new CssMinifier(!noComments, preserveSpaces, !noSemicolon, shrinkColors);
        String minified = minifier.minify(content);

        if (outputFile != null) {
            try (FileWriter fw = new FileWriter(outputFile)) {
                fw.write(minified);
            }
        } else {
            System.out.println(minified);
        }
    }
}
