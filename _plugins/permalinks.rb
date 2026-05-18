# Preserve underscores in post URLs. Jekyll's :slug placeholder slugifies the
# basename via Utils.slugify(default mode), which converts underscores to dashes.
# This hook explicitly sets each post's permalink from its raw filename.
Jekyll::Hooks.register :posts, :post_init do |doc|
  next if doc.data['permalink']
  basename = doc.basename_without_ext.sub(/^\d{4}-\d{2}-\d{2}-/, '')
  doc.data['permalink'] = "/blog/#{basename}/"
end
