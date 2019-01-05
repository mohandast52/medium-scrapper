# Medium Blog Scrapper

Things you may want to cover:

* Ruby version: 2.5.3

* Rails version: 5.2.2

* Database: sqlite3


### Home
Picture of acutal home page

![home_pic](https://user-images.githubusercontent.com/22061815/50729326-ec8ff980-115d-11e9-8e31-7d2a2efee474.png)


### Search
When users types input and searches. Also has read more button
which gets the next blogs using AJAX request 

![search](https://user-images.githubusercontent.com/22061815/50729349-442e6500-115e-11e9-83df-fc8ce35bb454.gif)

### Blog
When the blog is clicked, it opens new tab and displays it

![blog](https://user-images.githubusercontent.com/22061815/50729403-1990dc00-115f-11e9-8ccd-85587cc63245.gif)

### History
All the history is stored in database

![history](https://user-images.githubusercontent.com/22061815/50729390-d5054080-115e-11e9-93a1-c005a85c1fc4.gif)

### History search
When the user clicks on History table, the search is triggered

![history_search](https://user-images.githubusercontent.com/22061815/50729375-8657a680-115e-11e9-8b6a-95f8c79a2aef.gif)

### Adding new entry (add onto history database)
Simulation of user typing in input feild and it is stored onto History database,
as soon as the search button is clicked

![adding_new_entry](https://user-images.githubusercontent.com/22061815/50729415-3a593180-115f-11e9-80cb-06e9026534ad.gif)

### Related tags
Related tags and their searches triggered

![related_tags](https://user-images.githubusercontent.com/22061815/50729394-e9493d80-115e-11e9-9b38-7a91beeba814.gif)

### On wrong input
On wrong input, error is displayed

![on_wrong_input](https://user-images.githubusercontent.com/22061815/50729400-08e06600-115f-11e9-94bf-a7ec316721e0.gif)

### On error

![on_error](https://user-images.githubusercontent.com/22061815/50729406-2ad9e880-115f-11e9-961f-231c3ef3273e.gif)

## Explanation: 
> In a nutshell, I have used an idea of headless chrome browser which is 
> automated using nokogiri gem (used for web scraping). It extracts data 
> from that headless chrome, parses it and responses with JSON, where 
> angularJS is used to display it. I mainly used this approach because 
> medium makes ajax request on a scroll, so I was not able to use 
> the traditional idea of paginations.

### I haven't 
* I gave a shot on scrapping every comments of each blog too, but if the comments are lengthy, the user has to click on read and ajax request was made. So for every comment, it would take a lot of time on automation.

* Also, i didn't understand storing every blog on the database.
