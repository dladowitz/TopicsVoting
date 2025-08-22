# frozen_string_literal: true

# Helper methods for sections views
module SectionsHelper
  def section_delete_warning(section)
    topic_count = section.topics.count
    return "Are you sure you want to delete this section?" if topic_count.zero?

    "Are you sure you want to delete this section? This will delete #{pluralize(topic_count, 'topic')} as well."
  end
end
