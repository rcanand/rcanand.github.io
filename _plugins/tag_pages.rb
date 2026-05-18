module Jekyll
  class TagPage < Page
    def initialize(site, base, tag)
      @site = site
      @base = base
      @dir  = File.join('blog', 'tag', tag.to_s)
      @name = 'index.html'
      self.process(@name)
      self.data = {
        'layout'    => 'tag',
        'tag'       => tag.to_s,
        'title'     => "##{tag}",
        'permalink' => "/blog/tag/#{tag}/"
      }
      self.content = ''
    end
  end

  class TagPageGenerator < Generator
    safe true
    priority :low

    def generate(site)
      return unless site.layouts.key?('tag')
      site.tags.each_key do |tag|
        site.pages << TagPage.new(site, site.source, tag.to_s)
      end
    end
  end
end
