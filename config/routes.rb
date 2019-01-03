Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'scrapper#show'
  get 'index' => 'timepass#index', as: 'index'
  get 'increment' => 'timepass#increment', as: 'increment'
  get 'timepass', to: 'timepass#index' # , :defaults => { :format => 'json' }
  get 'timepass/button_click', to: 'timepass#button_click' , :defaults => { :format => 'json' }

  # scrapper
  get 'scrapper/scrapWebPage' => 'scrapper#scrapWebPage', :defaults => { :format => 'json' }
  get 'scrapper/nextTenBlogs' => 'scrapper#nextTenBlogs', :defaults => { :format => 'json' }

  # blog
  get 'blog', to: 'blog#show', as: 'blog'

  get 'blog/scrapeArticle' => 'blog#scrapeArticle', :defaults => { :format => 'json' }
end
