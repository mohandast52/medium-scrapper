Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'scrapper#show'

  # scrapper
  get 'scrapper/scrapWebPage' => 'scrapper#scrapWebPage', :defaults => { :format => 'json' }
  get 'scrapper/nextTenBlogs' => 'scrapper#nextTenBlogs', :defaults => { :format => 'json' }
  get 'scrapper/get_all_history_json' => 'scrapper#get_all_history_json', :defaults => { :format => 'json' }
  post 'scrapper/insert_histroy' => 'scrapper#insert_histroy', :defaults => { :format => 'json' }
  post 'scrapper/bloglink' => 'scrapper#bloglink'
  post 'scrapper/tag_name' => 'scrapper#tag_name'

  # blog
  get 'blog', to: 'blog#show', as: 'blog'
  get 'blog/scrapeArticle' => 'blog#scrapeArticle', :defaults => { :format => 'json' }
end
