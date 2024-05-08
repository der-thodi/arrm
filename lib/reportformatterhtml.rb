class ReportFormatterHTML

  def initialize(privacy: 0, output_file: "output.html")
    @privacy = privacy
    @output_file = File.open(output_file, "w")
    puts "New html formatter. Privacy: #{@privacy}, Output file: '#{output_file}'"
  end

  def print_global_header
    @output_file.puts("<!DOCTYPE html>")
    @output_file.puts("<html lang=\"en\">")
    @output_file.puts("<head>")
    @output_file.puts("  <title>Reddit Report Analyzer</title>")
    @output_file.puts("  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">")
    @output_file.puts("</head>")
    @output_file.puts("<body>")
  end

  def print_global_footer
    @output_file.puts("</body>")
    @output_file.close
  end

  def print_summary_header
    @output_file.puts("<h1>Report Summary</h1>")
  end

  def print_summary_footer
  end

  def print_summary_stats(reported_posts: 0,
                          reported_comments: 0,
                          violations: 0,
                          no_violations: 0,
                          permanent_bans: [],
                          temporary_bans: [],
                          warnings: [])
    @output_file.puts("<ul>")
    @output_file.puts("  <li>Reported posts: #{reported_posts}</li>")
    @output_file.puts("  <li>Reported comments: #{reported_comments}</li>")
    @output_file.puts("  <li>Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)</li>")
    @output_file.puts("  <li>Permanent bans: #{permanent_bans.length}</li>")
    @output_file.puts("  <li>Temporary bans: #{temporary_bans.length}</li>")
    @output_file.puts("  <li>Warnings: #{warnings.length}</li>")
    @output_file.puts("</ul>")
  end

  def print_subreddit_header
    @output_file.puts("<h1>Subreddit breakdown</h1>");
  end

  def print_subreddit_footer
  end

  def print_stats_for_sub(name: nil,
                          reported_posts: 0,
                          reported_comments: 0,
                          violations: 0,
                          no_violations: 0,
                          permanent_bans: [],
                          temporary_bans: [],
                          warnings: [])
    @output_file.puts("<h2>Subreddit r/#{name}</h2>")
    @output_file.puts("<ul>")
    @output_file.puts("  <li>Reported posts: #{reported_posts}</li>")
    @output_file.puts("  <li>Reported comments: #{reported_comments}</li>")
    @output_file.puts("  <li>Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)</li>")
    @output_file.puts("  <li>Permanent bans: #{permanent_bans.length}</li>")
    if (@privacy < 2 and permanent_bans.length > 0)
      @output_file.puts("  <li><ul>")
      permanent_bans.each do |ban|
        @output_file.puts("    <li>#{ban}</li>")
      end
      @output_file.puts("  </ul></li>")
    end

    @output_file.puts("  <li>Temporary bans: #{temporary_bans.length}</li>")
    if (@privacy < 2 and temporary_bans.length > 0)
      @output_file.puts("  <li><ul>")
      temporary_bans.each do |ban|
        @output_file.puts("    <li>#{ban}</li>")
      end
      @output_file.puts("  </ul></li>")
    end

    @output_file.puts("  <li>Warnings: #{warnings.length}</li>")
    if (@privacy < 2 and warnings.length > 0)
      @output_file.puts("  <li><ul>")
      warnings.each do |warn|
        @output_file.puts("    <li>#{warn}</li>")
      end
      @output_file.puts("  </ul></li>")
    end
    @output_file.puts("</ul>")
  end

  def get_percentage(part: 0, total: 0)
    total == 0 ? 0 : ((part.to_f / total.to_f) * 100).round(1)
  end
end