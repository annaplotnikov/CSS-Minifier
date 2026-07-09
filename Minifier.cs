// CssMinifier.cs
using System;
using System.IO;
using System.Text.RegularExpressions;

class CssMinifier
{
    private bool RemoveComments { get; set; }
    private bool PreserveSpaces { get; set; }
    private bool RemoveSemicolon { get; set; }
    private bool ShrinkColors { get; set; }

    public CssMinifier(bool removeComments = true, bool preserveSpaces = false,
                       bool removeSemicolon = true, bool shrinkColors = false)
    {
        RemoveComments = removeComments;
        PreserveSpaces = preserveSpaces;
        RemoveSemicolon = removeSemicolon;
        ShrinkColors = shrinkColors;
    }

    public string Minify(string css)
    {
        if (RemoveComments)
            css = Regex.Replace(css, @"/\*.*?\*/", "", RegexOptions.Singleline);

        var lines = css.Split('\n');
        var sb = new System.Text.StringBuilder();
        foreach (var line in lines)
        {
            string trimmed = line.Trim();
            if (!string.IsNullOrEmpty(trimmed))
                sb.Append(trimmed);
        }
        css = sb.ToString();

        if (!PreserveSpaces)
        {
            css = Regex.Replace(css, @"\s*([{}:;,>+~()])\s*", "$1");
            css = Regex.Replace(css, @"\s*,\s*", ",");
        }

        if (RemoveSemicolon)
            css = Regex.Replace(css, @";}", "}");

        if (ShrinkColors)
        {
            css = Regex.Replace(css, @"#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3", "#$1$2$3");
            css = Regex.Replace(css, @"\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)", "0");
            css = Regex.Replace(css, @"\b0+\.(\d+)", ".$1");
        }

        css = Regex.Replace(css, @"\n\s*\n", "\n");
        return css.Trim();
    }

    static void Main(string[] args)
    {
        string inputFile = null;
        string outputFile = null;
        bool noComments = false;
        bool preserveSpaces = false;
        bool noSemicolon = false;
        bool shrinkColors = false;

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--no-comments": noComments = true; break;
                case "--preserve-spaces": preserveSpaces = true; break;
                case "--no-semicolon": noSemicolon = true; break;
                case "--shrink-colors": shrinkColors = true; break;
                case "-o": outputFile = args[++i]; break;
                default: if (inputFile == null) inputFile = args[i]; break;
            }
        }

        string content;
        if (inputFile != null)
        {
            content = File.ReadAllText(inputFile);
        }
        else
        {
            using (var reader = new StreamReader(Console.OpenStandardInput()))
            {
                content = reader.ReadToEnd();
            }
        }

        var minifier = new CssMinifier(!noComments, preserveSpaces, !noSemicolon, shrinkColors);
        string minified = minifier.Minify(content);

        if (outputFile != null)
            File.WriteAllText(outputFile, minified);
        else
            Console.WriteLine(minified);
    }
}
