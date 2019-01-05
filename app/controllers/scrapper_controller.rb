class ScrapperController < ApplicationController

    # @@BROWSER is a global variable 
    @@BROWSER = Watir::Browser.new :chrome #, headless: true
    @@TAG_NAME = ""

    def show 
    end
    
    # accessing global variable and setting it as URL,
    # to be used by blog_controller to parse that URL
    def bloglink
        @@URL = params[:blog_url]
    end

    def tag_name
        @@TAG_NAME = params[:tag_name]
        puts @@TAG_NAME
    end

    # scrapping pages
    def scrapWebPage
        @website = "https://medium.com/tag/"
        @url = @website + "" + @@TAG_NAME

        @@BROWSER.goto(@url)
        readPage()
        
    end

    def nextTenBlogs
        @@BROWSER.scroll.to :bottom # on scrolling, medium makes the ajax request for new blogs!
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
            author_name = author_details.text.strip
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
        
        respond_to do |format|
            format.json{
              render json: {
                "tags": @tags,
                "blogs": @blogs
              }.to_json
            }
        end
    end

    
    # databases

    # def new_history
    #     @history = History.new
    # end

    def insert_histroy
        tag_name = params[:tag_name]
        @history = History.find_by(title: tag_name)
        if @history.nil?
            create_history(tag_name)
        else
            @history.update_attribute(:repeat, @history.repeat + 1)
            # update_history(tag_name)
        end

        get_all_history_json()
    end

    def create_history(tag_name)
        @history = History.create(:title => tag_name, :repeat => 1)
        if @history.save
            # successfully created!
        else
            # catch exception
        end
    end

    def get_all_history_json
        respond_to do |format|
            format.json{
                render json: {
                    "history": get_all_history()
                }.to_json 
            }
        end
    end

    def get_all_history
        @histories = History.all
    end

    def update_history(tag_name)
        # 1. get the row and store it
        @history_local = History.find_by(title: tag_name)

        # 2. delete the row
        History.find_by(title: tag_name).destroy

        # 3. update the local_variable storing the row
        @history_local.repeat = @history_local.repeat + 1
        
        History.create(title: @history_local.title, repeat: @history_local.repeat)
        # 4. insert it into the table
    end

end
