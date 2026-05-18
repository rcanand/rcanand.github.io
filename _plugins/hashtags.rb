module Jekyll
  module Hashtags
    BLOG_BASE = '/blog/'
    INLINE_TAG_RE = /(^|[\s(\[{,;:.!?"'>])#([A-Za-z][\w-]*)/
    FENCE_RE = /\A\s*(?:```|~~~)/
    HEADING_RE = /\A\s*\#{1,6}\s+/

    def self.extract(content)
      tags = []
      in_fence = false
      content.to_s.each_line do |line|
        if line =~ FENCE_RE
          in_fence = !in_fence
          next
        end
        next if in_fence
        next if line =~ HEADING_RE
        line_no_code = line.gsub(/`[^`]*`/, '')
        line_no_code.scan(INLINE_TAG_RE) do |_, tag|
          t = tag.downcase
          tags << t unless tags.include?(t)
        end
      end
      tags
    end

    def self.transform(content)
      return content unless content.is_a?(String)
      out = []
      in_fence = false
      content.each_line do |line|
        if line =~ FENCE_RE
          in_fence = !in_fence
          out << line
          next
        end
        if in_fence || line =~ HEADING_RE
          out << line
          next
        end
        parts = line.split(/(`[^`]*`)/)
        parts.each_with_index do |p, i|
          next if i.odd?
          parts[i] = p.gsub(INLINE_TAG_RE) do
            lead = Regexp.last_match(1)
            tag  = Regexp.last_match(2)
            "#{lead}[##{tag}](#{BLOG_BASE}tag/#{tag.downcase}/)"
          end
        end
        out << parts.join
      end
      out.join
    end
  end
end

# Aggregate inline #hashtags into doc.data['tags'] before site.tags is materialized.
Jekyll::Hooks.register :site, :post_read do |site|
  site.posts.docs.each do |doc|
    inline = Jekyll::Hashtags.extract(doc.content)
    doc.data['tags'] = Array(doc.data['tags']).map(&:to_s)
    existing = doc.data['tags'].map(&:downcase)
    inline.each do |t|
      doc.data['tags'] << t unless existing.include?(t.downcase)
    end
  end
end

# Transform inline #hashtags into markdown links in source.
Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
  next unless doc.respond_to?(:content) && doc.content.is_a?(String)
  ext = (doc.extname || '').downcase
  next unless %w[.md .markdown].include?(ext)
  doc.content = Jekyll::Hashtags.transform(doc.content)
end
