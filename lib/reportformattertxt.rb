class ReportFormatterTXT

  def initialize(options)
    @privacy_for_reporters = options[:privacy_for_reporters]
    @privacy_for_offenders = options[:privacy_for_offenders]
    @output_file = File.open(options[:output_file], "w")
    puts "New TXT formatter. Options: #{options}'"
  end

  def escape_characters(str)
    str
  end

  def print_global_header
  end

  def print_global_footer
    @output_file.close
  end

  def print_summary_header
    @output_file.puts("# Report Summary")
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
    @output_file.puts(" * Total reports: #{reported_posts + reported_comments}")
    @output_file.puts("   * Reported posts: #{reported_posts} (#{get_percentage(part: reported_posts, total: reported_posts + reported_comments)}% of all reports)")
    @output_file.puts("   * Reported comments: #{reported_comments} (#{get_percentage(part: reported_comments, total: reported_posts + reported_comments)}% of all reports)")
    @output_file.puts(" * Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)")
    @output_file.puts(" * First reports: #{first_reports} (#{get_percentage(part: first_reports, total: reported_posts + reported_comments)}% of all reports)")
    @output_file.puts("   * Permanent bans: #{permanent_bans}")
    @output_file.puts("   * Temporary bans: #{temporary_bans}")
    @output_file.puts("   * Warnings: #{warnings}")
  end

  def print_violation_breakdown_header
    @output_file.puts("# Violation Breakdown")
  end

  def print_violation_breakdown
  end

  def print_violation_breakdown_footer
  end

  def print_subreddit_header
    @output_file.puts("# Subreddit Breakdown");
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
    @output_file.puts("## Subreddit r/#{escape_characters(name)}")
    @output_file.puts(" * Reported posts: #{reported_posts}")
    @output_file.puts(" * Reported comments: #{reported_comments}")
    @output_file.puts(" * First reports: #{first_reports}")
    @output_file.puts(" * Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)")
    @output_file.puts(" * Permanent bans: #{permanent_bans.length}")
    if (!(@privacy_for_offenders))
      i = 1
      permanent_bans.each do |ban|
        @output_file.puts("    #{i}. #{escape_characters(ban)}")
        i = i + 1
      end
    end

    @output_file.puts(" * Temporary bans: #{temporary_bans.length}")
    if (!(@privacy_for_offenders))
      i = 1
      temporary_bans.each do |ban|
        @output_file.puts("    #{i}. #{escape_characters(ban)}")
        i = i + 1
      end
    end

    @output_file.puts(" * Warnings: #{warnings.length}")
    if (!(@privacy_for_offenders))
      i = 1
      warnings.each do |warn|
        @output_file.puts("    #{i}. #{escape_characters(warn)}")
        i = i + 1
      end
    end
  end

  def get_percentage(part: 0, total: 0)
    total == 0 ? 0 : ((part.to_f / total.to_f) * 100).round(1)
  end
end