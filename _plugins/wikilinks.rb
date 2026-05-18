module Jekyll
  module Wikilinks
    BLOG_BASE = '/blog/'

    def self.slugify(s)
      s.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/^_|_$/, '')
    end

    def self.transform(content)
      return content unless content.is_a?(String)
      # ![[image|alt]] -> ![alt](image)
      content = content.gsub(/!\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/) do
        target = Regexp.last_match(1).strip
        alt = (Regexp.last_match(2) || target).strip
        src = target
        "![#{alt}](#{src})"
      end
      # [[target|display]] -> [display](/blog/<slug>/)
      content.gsub(/\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/) do
        target = Regexp.last_match(1).strip
        display = (Regexp.last_match(2) || target).strip
        "[#{display}](#{BLOG_BASE}#{slugify(target)}/)"
      end
    end
  end
end

Jekyll::Hooks.register [:posts, :pages, :documents], :pre_render do |doc|
  next unless doc.respond_to?(:content) && doc.content.is_a?(String)
  ext = (doc.extname || '').downcase
  next unless %w[.md .markdown].include?(ext)
  doc.content = Jekyll::Wikilinks.transform(doc.content)
end
