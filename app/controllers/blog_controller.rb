class BlogController < ApplicationController
    def show
    end

    def scrapeArticle

        # using headless browser running in background (eats more RAM and SLOW)
        # -------------------------------------
        # @@URL = "https://towardsdatascience.com/get-smarter-with-data-science-tackling-real-enterprise-challenges-67ee001f6097"
        @BLOG_BROWSER = Watir::Browser.new :chrome #, headless: true
        @BLOG_BROWSER.goto(@@URL)
        @doc = Nokogiri::HTML.parse(@BLOG_BROWSER.html)
        @BLOG_BROWSER.quit()
        article = @doc.css('.postArticle-content')
        # -------------------------------------


        # using Httparty, less RAM and less time required to parse!
        # -------------------------------------
        # @@URL = "https://towardsdatascience.com/get-smarter-with-data-science-tackling-real-enterprise-challenges-67ee001f6097"
        # unparsed_page = HTTParty.get(@@URL)
        # @doc = Nokogiri::HTML.parse(unparsed_page)
        # article = @doc.css('.postArticle-content')
        # -------------------------------------
        
        articleJSON = []
        article[0].css(' .section--body .section-inner').each do |sections|
            # each sections contains: paragraph (p), images (f),
            # blockquote (b), blockquote-highlights (bh)
            sectionJSON = []
        
            # there are multiple .section-inner
            sections.children.each do |sectionInformation|

                # 1. figure
                # 2. p
                # 3. pre
                # 4. blockquote
                # 5. h4, h3, h2, h1
                # 6. ul ol
                
                if sectionInformation.name == "figure"
                    if sectionInformation.css('.progressiveMedia-image.js-progressiveMedia-image').empty?
                        # something has been emebeded!
                        sectionJSON.push({
                            :type => "if", 
                            :value => sectionInformation.css('.iframeContainer').to_html,
                            :class=> sectionInformation.attr('class') +" iframe-NA"
                        })
                    else
                        img_link = sectionInformation.css('.progressiveMedia-image.js-progressiveMedia-image').attribute('data-src').value
                        imageCaptions = [] 
                        sectionInformation.css('.imageCaption a').each do |imageCaption|
                            imageCaptions.push({
                                :caption => imageCaption.to_html,
                            })
                        end

                        sectionJSON.push({
                            :type => "f", 
                            :value => img_link,
                            :class => sectionInformation.attr('class'),
                            :imageCaptions => imageCaptions
                        })
                    end                    
                elsif sectionInformation.name == "p"
                    sectionJSON.push({
                        :type => "p", 
                        :value => sectionInformation.inner_html,
                        :class=> sectionInformation.attr('class')
                    })
                elsif sectionInformation.name == "pre"
                    if sectionJSON.size > 0 and sectionJSON.last[:type] == "c"
                        if sectionJSON.last[:class].to_s.include? "graf--pre"
                            # sectionJSON.last[:class].to_s + " graf-after--pre-div"
                            sectionJSON.push({
                                :type => "c", 
                                :value => sectionInformation.inner_html,
                                :class=> sectionInformation.attr('class').to_s + " graf-after--pre-div"
                            })
                        end
                    else
                        sectionJSON.push({
                            :type => "c", 
                            :value => sectionInformation.inner_html,
                            :class=> sectionInformation.attr('class')
                        })
                    end
                elsif sectionInformation.name == "blockquote"
                    if sectionInformation.at_css('.markup--quote')
                        sectionJSON.push({
                            :type => "bh", 
                            :value => sectionInformation.inner_html,
                            :class => sectionInformation.attr('class')
                        })
                    else
                        sectionJSON.push({
                            :type => "b", 
                            :value => sectionInformation.text,
                            :class => sectionInformation.attr('class')
                        })
                    end
                elsif sectionInformation.name == "h4"
                    sectionJSON.push({
                        :type => "h4", 
                        :value => sectionInformation.text,
                        :class=> sectionInformation.attr('class')
                    })
                elsif sectionInformation.name == "h3"
                    sectionJSON.push({
                        :type => "h3", 
                        :value => sectionInformation.text,
                        :class=> sectionInformation.attr('class')
                    })
                elsif sectionInformation.name == "h2"
                    sectionJSON.push({
                        :type => "h2", 
                        :value => sectionInformation.text,
                        :class=> sectionInformation.attr('class')
                    })
                elsif sectionInformation.name == "h1"
                    sectionJSON.push({
                        :type => "h1", 
                        :value => sectionInformation.text,
                        :class=> sectionInformation.attr('class')
                    })
                
                elsif sectionInformation.name == "ul"
                    listItems = []
                    sectionInformation.css('li').each do |listItem|
                        listItems.push({
                            :item => listItem.to_html,
                            :class=> sectionInformation.attr('class')
                        })
                    end
                    sectionJSON.push({
                        :type => "ul", 
                        :items => listItems
                    })
                elsif sectionInformation.name == "ol"
                    listItems = []
                    sectionInformation.css('li').each do |listItem|
                        listItems.push({
                            :item => listItem.to_html,
                            :class=> sectionInformation.attr('class')
                        })
                    end
                    sectionJSON.push({
                        :type => "ul", 
                        :items => listItems
                    })
                end
            end
            # puts sectionJSON
            articleJSON.push(sectionJSON)
        end

        respond_to do |format|
            format.json{
              render json: {
                "article": articleJSON
              }.to_json
            }
        end
    end
end


# config.consider_all_requests_local = false
# it is set to false when unmatching route is passed 
# eg Youtube video embedding GET requests to invalid route 