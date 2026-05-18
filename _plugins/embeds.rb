require 'cgi'

module Jekyll
  module Embeds
    YOUTUBE_RE = %r{^https?://(?:www\.|m\.)?(?:youtube\.com/(?:watch\?(?:.*&)?v=|shorts/|embed/|live/)|youtu\.be/)([\w-]{6,})}i
    TWITTER_RE = %r{^https?://(?:www\.|mobile\.)?(?:x|twitter)\.com/([^/?#]+/status/\d+)}i

    def self.escape(s)
      CGI.escapeHTML(s.to_s)
    end

    def self.render(url, alt)
      if (m = url.match(YOUTUBE_RE))
        id = m[1]
        title = alt.to_s.strip.empty? ? 'YouTube video' : alt
        return %(<div class="embed embed-youtube"><iframe src="https://www.youtube-nocookie.com/embed/#{CGI.escape(id)}" title="#{escape(title)}" loading="lazy" frameborder="0" allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></div>)
      end
      if (m = url.match(TWITTER_RE))
        canonical = "https://twitter.com/#{m[1]}"
        body = alt.to_s.strip.empty? ? 'Loading tweet...' : alt
        return %(<blockquote class="twitter-tweet" data-theme="dark" data-dnt="true"><p>#{escape(body)}</p><a href="#{escape(canonical)}">View on X</a></blockquote>)
      end
      nil
    end

    def self.transform(html)
      return html unless html.is_a?(String)
      html.gsub(/<img\b([^>]*?)\/?>/i) do |tag|
        attrs = $1.to_s
        src_match = attrs.match(/\bsrc=(["'])([^"']+)\1/i)
        next tag unless src_match
        src = src_match[2]
        alt_match = attrs.match(/\balt=(["'])([^"']*)\1/i)
        alt = alt_match ? alt_match[2] : ''
        Embeds.render(src, alt) || tag
      end
    end
  end
end

Jekyll::Hooks.register [:posts, :pages, :documents], :post_render do |doc|
  next unless doc.respond_to?(:output) && doc.output
  doc.output = Jekyll::Embeds.transform(doc.output)
end
