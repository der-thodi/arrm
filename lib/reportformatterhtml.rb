class ReportFormatterHTML

  def initialize(options)
    @privacy_for_reporters = options[:privacy_for_reporters]
    @privacy_for_offenders = options[:privacy_for_offenders]    
    @output_file = File.open(options[:output_file], "w")
    puts "New html formatter. Options: #{options}"
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
                          first_reports: 0,
                          permanent_bans: 0,
                          temporary_bans: 0,
                          warnings: 0)
    @output_file.puts("<ul>")
    @output_file.puts("  <li>Reported posts: #{reported_posts}</li>")
    @output_file.puts("  <li>Reported comments: #{reported_comments}</li>")
    @output_file.puts("  <li>Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)</li>")
    @output_file.puts("  <li>Permanent bans: #{permanent_bans}</li>")
    @output_file.puts("  <li>Temporary bans: #{temporary_bans}</li>")
    @output_file.puts("  <li>Warnings: #{warnings}</li>")
    @output_file.puts("</ul>")
  end

  def print_violation_breakdown_header
    @output_file.puts("<h1>Violation Breakdown</h1>")
  end

  def print_violation_breakdown
  end

  def print_violation_breakdown_footer
  end


  def print_subreddit_header
    @output_file.puts("<h1>Subreddit Breakdown</h1>");
  end

  def print_subreddit_footer
  end

  def print_stats_for_sub(name: nil,
                          reported_posts: 0,
                          reported_comments: 0,
                          violations: 0,
                          no_violations: 0,
                          first_reports: 0,
                          permanent_bans: [],
                          temporary_bans: [],
                          warnings: [])
    @output_file.puts("<h2>Subreddit r/#{name}</h2>")
    @output_file.puts("<ul>")
    @output_file.puts("  <li>Reported posts: #{reported_posts}</li>")
    @output_file.puts("  <li>Reported comments: #{reported_comments}</li>")
    @output_file.puts("  <li>First reports: #{first_reports}</li>")
    @output_file.puts("  <li>Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)</li>")
    @output_file.puts("  <li>Permanent bans: #{permanent_bans.length}</li>")
    if (!(@privacy_for_offenders) and permanent_bans.length > 0)
      @output_file.puts("  <li><ul>")
      permanent_bans.each do |ban|
        @output_file.puts("    <li>#{ban}</li>")
      end
      @output_file.puts("  </ul></li>")
    end

    @output_file.puts("  <li>Temporary bans: #{temporary_bans.length}</li>")
    if (!(@privacy_for_offenders) and temporary_bans.length > 0)
      @output_file.puts("  <li><ul>")
      temporary_bans.each do |ban|
        @output_file.puts("    <li>#{ban}</li>")
      end
      @output_file.puts("  </ul></li>")
    end

    @output_file.puts("  <li>Warnings: #{warnings.length}</li>")
    if (!(@privacy_for_offenders) and warnings.length > 0)
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