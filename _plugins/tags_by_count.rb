module Jekyll
  module TagsByCount
    # Sort a site.tags hash by post count (descending),
    # then tag name (case-insensitive ascending) for ties.
    def tags_by_count(tags)
      tags.sort_by { |name, posts| [-posts.size, name.to_s.downcase] }
    end
  end
end

Liquid::Template.register_filter(Jekyll::TagsByCount)
