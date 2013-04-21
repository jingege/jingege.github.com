module Jekyll
  class PagePathGenerator < Generator
    safe true
    ## See post.dir and post.base for directory information. 
    def generate(site)
      site.posts.each do |post|
        post.data['name'] = post.name[ post.name.rindex('/') + 12  ..-4]
      end
    end
  end
end
