class ScrapperController < ApplicationController

    
    def show 
    end

    # @@BROWSER is a global variable declared in application_controller
    
    # scrapping pages
    def scrapWebPage
        @website = "https://medium.com/tag/"
        @tag_name = "machine-learning"
        @url = @website + "" + @tag_name

        @@BROWSER = Watir::Browser.new :chrome #, headless: true
        @@BROWSER.goto(@url)
        readPage()
        
    end

    def nextTenBlogs
        @@BROWSER.scroll.to :bottom
        sleep 5 # wait for 5 seconds to load the page and extract it!
        readPage()
    end

    # return JSON containing list of blogs
    def readPage 
        @doc = Nokogiri::HTML.parse(@@BROWSER.html)

        # related TAGS
        @tags = []
        @doc.css('.tags.tags--postTags li a').each do |related_tag|
            @tags.push({
                :tag_name => related_tag.children.text,
                :tag_link => related_tag.attribute('href').value
            })
        end

        # BLOGS
        @blogs = []
        @doc.css('.streamItem').each do |blog|
            # author details: name, link to medium
            author_details = blog.css('.postMetaInline-authorLockup a').css('[data-action="show-user-card"]')
            author_name = author_details.text
            author_link = author_details.map { |link| link['href'] }

            # blog_archieve details
            blog_archieve_details = blog.css('.postMetaInline-authorLockup a').css('[data-action="show-collection-card"]')
            blog_archieve_name = blog_archieve_details.text
            blog_archieve_link = blog_archieve_details.map { |link| link['href'] }

            # blog title image
            img_link = ""
            if blog.css('.progressiveMedia-image.js-progressiveMedia-image').empty?
            else
                img_link = blog.css('.progressiveMedia-image.js-progressiveMedia-image').attribute('data-src').value
            end

            # blog_link
            blog_link = blog.css('.postArticle-readMore .button--smaller').attribute('href').value

            @blogs.push({
                :title => blog.css('.graf--title').text, 
                :sub_title => blog.css('.graf--subtitle').text,
                :trailing => blog.css('.graf--trailing').text,
                :author_name => author_name,
                :author_link => author_link[0],
                :blog_archieve_name => blog_archieve_name,
                :blog_archieve_link => blog_archieve_link[0],
                :blog_link => blog_link,
                :reading_time => blog.css('.readingTime').attr('title').value,
                :upvotes => blog.css('.js-actionMultirecommendCount').text,
                :img_link => img_link
            })
        end
        #puts @blogs
        # closing browser after srapping
        # @@browser.close
        
        respond_to do |format|
            format.json{
              render json: {
                "tags": @tags,
                "blogs": @blogs
              }.to_json
            }
        end
    end
end
