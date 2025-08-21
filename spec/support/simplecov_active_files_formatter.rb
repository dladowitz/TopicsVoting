# Custom SimpleCov formatter that only shows coverage for files that were actually run
# This formatter is used to provide a cleaner output when running individual spec files
# by hiding files that weren't loaded or tested in the current run.
class SimpleCovActiveFilesFormatter
  def format(result)
    return if result.files.empty?

    # Only show files that were actually run
    files = result.files.reject { |f| f.covered_percent.zero? }
    return if files.empty?

    output = []
    output << "\nCoverage report for files that were run (#{files.length} files):"
    files.each do |file|
      output << "  #{file.filename}: #{file.covered_percent.round(2)}%"
    end

    output << "\nIgnoring #{result.files.count - files.count} files with 0% coverage (not loaded in this test run)"
    output << "Full coverage report available in coverage/index.html"
    output.join("\n") + "\n"
  end
end
