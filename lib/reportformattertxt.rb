class ReportFormatterTXT

  def initialize(privacy: 0, output_file: "output.txt")
    @privacy = privacy
    @output_file = File.open(output_file, "w")
    puts "New txt formatter. Privacy: #{@privacy}, Output file: '#{output_file}'"
  end

  def print_global_header
  end

  def print_global_footer
    @output_file.close
  end

  def print_summary_stats
  
  end

  def print_stats_for_sub(name: nil,
                          reported_posts: 0,
                          reported_comments: 0,
                          violations: 0,
                          no_violations: 0,
                          permanent_bans: [],
                          temporary_bans: [],
                          warnings: [])
    @output_file.puts("Subreddit r/#{name}")
    @output_file.puts("  Reported posts: #{reported_posts}")
    @output_file.puts("  Reported comments: #{reported_comments}")
    @output_file.puts("  Confirmed violations: #{violations} (#{get_percentage(part: violations, total: violations + no_violations)}%)")
    @output_file.puts("  Permanent bans: #{permanent_bans.length}")
    if (@privacy < 2)
      permanent_bans.each do |ban|
        @output_file.puts("    #{ban}")
      end
    end

    @output_file.puts("  Temporary bans: #{temporary_bans.length}")
    if (@privacy < 2)
      temporary_bans.each do |ban|
        @output_file.puts("    #{ban}")
      end
    end

    @output_file.puts("  Warnings: #{warnings.length}")
    if (@privacy < 2)
      warnings.each do |warn|
        @output_file.puts("    #{warn}")
      end
    end
  end

  def get_percentage(part: 0, total: 0)
    total == 0 ? 0 : ((part.to_f / total.to_f) * 100).round(1)
  end
end