# css_minifier.rb
class CSSMinifier
  def initialize(remove_comments: true, preserve_spaces: false, remove_semicolon: true, shrink_colors: false)
    @remove_comments = remove_comments
    @preserve_spaces = preserve_spaces
    @remove_semicolon = remove_semicolon
    @shrink_colors = shrink_colors
  end

  def minify(css)
    css = css.gsub(/\/\*.*?\*\//m, '') if @remove_comments

    lines = css.lines.map(&:strip).reject(&:empty?)
    css = lines.join

    unless @preserve_spaces
      css.gsub!(/\s*([{}:;,>+~()])\s*/, '\1')
      css.gsub!(/\s*,\s*/, ',')
    end

    css.gsub!(/;}/, '}') if @remove_semicolon

    if @shrink_colors
      css.gsub!(/#([0-9a-fA-F])\1([0-9a-fA-F])\2([0-9a-fA-F])\3/, '#\1\2\3')
      css.gsub!(/\b0(px|em|rem|ex|ch|vw|vh|vmin|vmax|%)/, '0')
      css.gsub!(/\b0+\.(\d+)/, '.\1')
    end

    css.gsub!(/\n\s*\n/, "\n")
    css.strip
  end
end

def main
  input_file = nil
  output_file = nil
  no_comments = false
  preserve_spaces = false
  no_semicolon = false
  shrink_colors = false

  args = ARGV
  until args.empty?
    arg = args.shift
    case arg
    when '--no-comments' then no_comments = true
    when '--preserve-spaces' then preserve_spaces = true
    when '--no-semicolon' then no_semicolon = true
    when '--shrink-colors' then shrink_colors = true
    when '-o' then output_file = args.shift
    else input_file = arg
    end
  end

  if input_file
    content = File.read(input_file)
  else
    content = $stdin.read
  end

  minifier = CSSMinifier.new(
    remove_comments: !no_comments,
    preserve_spaces: preserve_spaces,
    remove_semicolon: !no_semicolon,
    shrink_colors: shrink_colors
  )
  minified = minifier.minify(content)

  if output_file
    File.write(output_file, minified)
  else
    puts minified
  end
end

main if __FILE__ == $0
