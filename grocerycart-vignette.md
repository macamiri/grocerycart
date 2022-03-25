---
title: "Introduction to grocerycart"
author: "mo"
output: 
  html_document:  
    keep_md: true  
---



The goal of the **grocerycart** package is to provide:  

1. [A suite of collection functions](#collect-data-from-elgrocer) that scrape 
data from 2 online grocery services: 
[elGrocer](https://www.elgrocer.com) & [Ocado](https://www.ocado.com).  

2. [Clean the collected data](#cleaning-functions) from the 2 websites.  
    
3. [Datasets containing details from real grocery stores](#collected-datasets) 
(e.g., products, prices, reviews).  

4. [Ready to use grocery data](#available-grocery-store-data): customer, 
order and basket datasets generated using real products. See more info 
in this vignette on how to quickly generate more grocery store data.  

This package was born, by chance, as a way to organize the 
functions that were created for the Grocery Cart project. You can view the 
R Shiny App for this project here: Grocery Cart.  

To see a full example of how the data included in this package 
was collected, cleaned and analyzed, see the 
files **raw_eg_data.R** and **raw_oc_data.R**.  

## Initiate Selenium Server

```r
library(grocerycart)
library(RSelenium)
library(robotstxt)
```


```r
remDr <- RSelenium::rsDriver(port = netstat::free_port(), 
                             browser = "firefox", 
                             verbose = FALSE)$client
```

## Check robots.txt files

```r
# Check which webpages are not bot friendly
eg_url <- "https://www.elgrocer.com"
# oc_url <- "https://www.ocado.com"

eg_rtxt <- robotstxt(domain = eg_url)
eg_rtxt$comments
eg_rtxt$crawl_delay
eg_rtxt$permissions

# oc_rtxt <- robotstxt(domain = oc_url)

# Can we collect data from the specific webpages that we are interested in?
paths_allowed(domain = eg_url, paths = c("/store", "/stores"))
# paths_allowed(domain = oc_url, paths = c("/browse"))

# Navigate to website
remDr$navigate(eg_url)
# remDr$navigate(oc_url)
```

*Note*: In order to play nice with the 2 websites, the scraper functions have
a built in 'sleep functionality'. This means that the functions will 
suspend execution (i.e., go to sleep) for a random time interval, usually 
between 5 and 10 seconds whenever the sleep function, `nytnyt`, is 
called within the scraper functions. Also, you can tell the function to 
sleep for longer after each iteration by overriding the default 
arguments `sleep_min` (default 0) and `sleep_max` (default 1). An iteration 
is defined depending on what the function is doing.  

For example, setting sleep_min = 4 and sleep_max = 8 
in `oc_collect_product_reviews` will trigger the function to 
suspend execution for an additional 4 to 8 seconds (time is chosen randomly 
by the `runif` function) after collecting reviews from a product's webpage.   

## Collect Data from elGrocer
The 5 functions that are used to scrape different parts of 
the [elGrocer](https://www.elgrocer.com) website all have the same 
pre-fix **eg_collect_***. Use them in the chronological order presented 
below. The name of the function indicates the type of data that is scraped 
and returned (e.g., eg_collect_categories scrapes/returns category data). 
These functions are verbose, allowing the user to get a sense of 
the progress being made.  

First, let's grab the links for the locations/areas that contain a store 
that delivers via elGrocer.


```r
eg_location <- eg_collect_location_links(remDr = remDr, url = "https://www.elgrocer.com")
```

```r
eg_location[1:3,]
```

```
##            location                                           location_link
## 1          Abu Hail          https://www.elgrocer.com/stores/dubai/abu-hail
## 2         Al Bada'a         https://www.elgrocer.com/stores/dubai/al-bada-a
## 3 Al Baraha Muteena https://www.elgrocer.com/stores/dubai/al-baraha-muteena
```

Next, let's collect the store details from 5 locations. The store details 
data is only visible after clicking on the 'i' icon for a store. To see an 
example of this, visit 
the [JLT grocery stores webpage](https://elgrocer.com/stores/dubai/jlt) and 
then click on the 'i' icon next to the store card. This will reveal the data 
that the function below collects (i.e., minimum order amount).  

Notice that one of the arguments used is the 
*column of location links that was collected above*. 
To scrape the store details from all locations, simply drop '[1:5]' from the 
code below.  


```r
eg_store <- eg_collect_stores_details(remDr, eg_location$location_link[1:5])
```

```r
eg_store[1:3,]
```

```
##    location  city            store_name min_order_amount delivery_within
## 1  Abu Hail Dubai    Al Douri Abu Baker               50         2 hours
## 2  Abu Hail Dubai Union Coop - Abu Hail               50         2 hours
## 3 Al Bada A Dubai  Union Coop - Al Wasl               50         2 hours
##   delivery_start delivery_end delivery_timezone
## 1     28800 secs   75600 secs        Asia/Dubai
## 2     32400 secs   79200 secs        Asia/Dubai
## 3     36000 secs   75600 secs        Asia/Dubai
##                                            payment_method
## 1                                          Online Payment
## 2 Online Payment Credit Card on delivery Cash on delivery
## 3 Online Payment Credit Card on delivery Cash on delivery
##                                           store_link
## 1  https://www.elgrocer.com/store/al-douri-abu-baker
## 2 https://www.elgrocer.com/store/union-coop-abu-hail
## 3  https://www.elgrocer.com/store/union-coop-al-wasl
##                                     location_link
## 1  https://www.elgrocer.com/stores/dubai/abu-hail
## 2  https://www.elgrocer.com/stores/dubai/abu-hail
## 3 https://www.elgrocer.com/stores/dubai/al-bada-a
```


Next, let's collect the product categories available in 3 stores. Notice that 
one of the arguments used is the 
*column of store links that was collected above*. It is important 
that you keep the object name as 'eg_category' as 'eg_category' is used 
internally in the `eg_collect_subcategories` function mentioned next.  


```r
eg_category <- eg_collect_categories(remDr, eg_store$store_link[1:3])
```

```r
eg_category[1:3,]
```

```
##           store_name                  category
## 1 Al Douri Abu Baker Beverages & Confectionary
## 2 Al Douri Abu Baker                      Nuts
## 3 Al Douri Abu Baker                      Deli
##                                                               category_link
## 1 https://www.elgrocer.com/store/al-douri-abu-baker/beverages-confectionary
## 2               https://www.elgrocer.com/store/al-douri-abu-baker/nuts-1914
## 3               https://www.elgrocer.com/store/al-douri-abu-baker/deli-1904
##                                                                                                               category_image_link
## 1 https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/001/851/medium/Beverages___Confectionary.jpg?1586947695
## 2  https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/001/914/medium/CatBan_300x180_0421_nuts.jpg?1587497663
## 3  https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/001/904/medium/CatBan_300x180_0421_Deli.jpg?1587500044
##                                                     store_link
## 1 https://www.elgrocer.com/store/al-douri-abu-baker/categories
## 2 https://www.elgrocer.com/store/al-douri-abu-baker/categories
## 3 https://www.elgrocer.com/store/al-douri-abu-baker/categories
```

Next, let's grab 3 subcategories from the categories that were returned from 
the function above.  


```r
# Randomly choose 3 categories to collect the subcategories from
random_category_links <- sample(x = 1:length(eg_category$category_link), 
                                size = 3, 
                                replace = FALSE)

eg_subcategory <- eg_collect_subcategories(remDr, 
                                           eg_category$category_link[random_category_links])
```

```r
eg_subcategory[1:3,]
```

```
##        subcategory
## 1     Fresh Fruits
## 2 Fresh Vegetables
## 3    Confectionery
##                                                                                  subcategory_link
## 1                 https://www.elgrocer.com/store/talha-supermarket/fruits-vegetables/fresh-fruits
## 2             https://www.elgrocer.com/store/talha-supermarket/fruits-vegetables/fresh-vegetables
## 3 https://www.elgrocer.com/store/al-rifai-roastery-fujairah-city-center/snacks-2225/confectionery
##                                                                       category_link
## 1                https://www.elgrocer.com/store/talha-supermarket/fruits-vegetables
## 2                https://www.elgrocer.com/store/talha-supermarket/fruits-vegetables
## 3 https://www.elgrocer.com/store/al-rifai-roastery-fujairah-city-center/snacks-2225
```

Finally, let's collect product data from 2 subcategories. The function uses 
Javascript in order to actively scroll to the bottom of each subcategory page 
to check for (and potentially load) more products. It stops scrolling when 
all the products have loaded.  


```r
# Randomly choose 2 subcategories to collect the product data from
random_subcategory_links <- sample(x = 1:length(eg_subcategory$subcategory_link), 
                                   size = 2, 
                                   replace = FALSE)

eg_item <- eg_collect_items(remDr, 
                            eg_subcategory$subcategory_link[random_subcategory_links])
```

```r
eg_product[1:3,]
```

```
##                                                                 subcategory_link
## 1 https://www.elgrocer.com/store/test-darkstore-inventory-limit/beverages/juices
## 2 https://www.elgrocer.com/store/test-darkstore-inventory-limit/beverages/juices
## 3 https://www.elgrocer.com/store/test-darkstore-inventory-limit/beverages/juices
##                                    item  weight    price
## 1 Al Rawabi Fresh & Natural Lemon Juice   200ml 1.846750
## 2               Lacnor 100% Apple Juice 8x180ml 2.386250
## 3           Lacnor 100% Pineapple Juice 8x180ml 6.007125
##                                                                                                                                item_image_link
## 1                                 https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/007/279/medium/0086077.png?1439924938
## 2     https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/005/277/medium/8x180ml_100_Leaf_Apple_Juice_Shrink.png?1635817653
## 3 https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/005/275/medium/8x180ml_100_Leaf_Pineapple_Juice_Shrink.png?1635817707
```


## Collect Data from Ocado
The 5 functions that are used to scrape different parts of 
the [Ocado](https://www.ocado.com) website all have the same 
pre-fix `oc_collect_`. Use them in the chronological order presented 
below. The name of the function indicates the type of data that is scraped 
and returned (e.g., oc_collect_product_reviews scrapes/returns product 
reviews). These functions are verbose, allowing the user to get a sense of 
the progress being made.  

First, let's grab the category links from the dropdown menu.  


```r
oc_category <- oc_collect_categories(remDr = remDr)
```

```r
oc_category[1:3,]
```

```
##               category
## 1 Fresh & Chilled Food
## 2        Food Cupboard
## 3               Bakery
##                                                        category_link
## 1 https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true
## 2      https://www.ocado.com/browse/food-cupboard-20424?hideOOS=true
## 3             https://www.ocado.com/browse/bakery-25189?hideOOS=true
```

Now we can collect general product details (i.e., name, price, image). This 
function interacts with the javascript elements on the webpage (i.e., 
click on 'show more' until there's no more 'show more') and 
slowly scrolls down and up the webpage in order to ensure that all products 
are loaded before scraping begins.    

Here, we will collect the data from 1 category.  


```r
chosen_category_links <- 7

oc_product_general <- oc_collect_product_general(oc_category$link[chosen_category_links])
```

```r
oc_product_general[1:3,]
```

```
##                           product            weight price shelf_life
## 1          Ocado Shredded Shrooms              150g  2.30   LIFE 2d+
## 2 Ocado British Whole Leg of Lamb Typically: 2.25kg 22.78   LIFE 4d+
## 3        Ocado Diced Sweet Potato              350g  1.20   LIFE 3d+
##                                                                                                    image_link
## 1 https://www.ocado.com/productImages/570/570612011_0_150x150.jpg?identifier=c423f73ca91b6070cc38ce3e2318589b
## 2  https://www.ocado.com/productImages/589/58996011_0_150x150.jpg?identifier=47a8e8d31eaada9f4d9339626c77783a
## 3 https://www.ocado.com/productImages/572/572270011_0_150x150.jpg?identifier=f994b4bbfb3e83ec46deae4d7fa1edc5
##                                                              product_link
## 1         https://www.ocado.com/products/ocado-shredded-shrooms-570612011
## 2 https://www.ocado.com/products/ocado-british-whole-leg-of-lamb-58996011
## 3       https://www.ocado.com/products/ocado-diced-sweet-potato-572270011
##                                                        category_link
## 1 https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true
## 2 https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true
## 3 https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true
```

We can also collect extra product data such as the country of origin and 
rating. We will do that for 3 random products in the code below.  


```r
random_product_links <- sample(x = 1:length(oc_product_general$product_link), 
                               size = 3, 
                               replace = FALSE)

oc_product_extra <- oc_collect_product_extra(-oc_product_general$product_link[random_product_links[1:3]])
```

```r
oc_product_extra[1:3,]
```

```
##                                                                                                        product_link
## 1                              https://www.ocado.com/products/innocent-kids-apples-blackcurrants-smoothies-29362011
## 2 https://www.ocado.com/products/daylesford-organic-10-hour-chicken-bone-broth-with-lemongrass-red-chilli-502753011
## 3                                                             https://www.ocado.com/products/m-s-celeriac-518566011
##                      badge
## 1 Suitable for vegetarians
## 2                  Organic
## 3 Suitable for vegetarians
##                                                                                                                           ingredient
## 1 1 Pressed Apple (70%), 1/3 of a Mashed Banana**, 4 Pressed Grapes, 8 Squashed Blackcurrants (4%), **Rainforest Alliance Certified™
## 2                                                                                                                               <NA>
## 3                                                                                                                               <NA>
##                brand country rating num_of_reviews recommend
## 1           Innocent      UK    4.6             21        96
## 2 DAYLESFORD ORGANIC      UK    4.2             60        77
## 3                M&S    <NA>    3.7             41        69
```

If a product has reviews, then we can collect those too. The function will 
check how many times it needs to click on the next arrow ('>') in order to 
collect all the reviews associated with a product. If no reiews exist, then 
it will return NA and move on to the next product. The verbose output will 
print to the console how many reviews the function has found.  


```r
oc_product_review <- oc_collect_product_reviews(oc_product_general$product_link[random_product_links[1:3]])
```

```r
oc_product_review[1:3,]
```

```
##                                                                                                        product_link
## 1                              https://www.ocado.com/products/innocent-kids-apples-blackcurrants-smoothies-29362011
## 2 https://www.ocado.com/products/daylesford-organic-10-hour-chicken-bone-broth-with-lemongrass-red-chilli-502753011
## 3                                                             https://www.ocado.com/products/m-s-celeriac-518566011
##                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         reviews
## 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         My five year old really likes these., Innocent smoothies are a firm favourite in our house, with apple and blackcurrant the most popular. We're also fans of the environment and like paper straws, unfortunately they're not strong enough to get through the packaging making this useless as a kids lunch snack. I hope the packaging design is rectified soon to get these drinks back to 5 stars., Really like buying these especially when on offer. They taste great. perfect for lunches etc.., I get these as a treat sometimes for the kids. They get very excited! So I guess that says it all., This is his favourite flavour. Great little packaging. Perfect for lunch boxes., These go down a treat and theyre a brilliant way to get fruit!, My daughter absolutely loves this! So do I, adults enjoy this too, Bit pricey if not on offer but you do get what you pay for. Fresh tasting, High in sugar but plenty of goodness in there. I actually bought them for my husband as he has to have blood taken regularly, and these give him a boost before the drive home. I tried one myself and they're very tasty, nice smooth texture and appealing colour. The packaging is attractive and convenient and has different games and puzzles on the back of each one for kids to play with., Great way to get vitamins into a child who doesnt like fruit.  Still working on getting the fibre in!, I like the fact that there is no added sugar or artificial ingredients in the innocent smoothies and my kids love them, a good way to get extra fruit into them, Not my kind of thing, but a regular buy in my house for the children and they love them. Only criticism is the tricky packaging - hard to get the straw out of the cellophane, then into the little hole at the top., my children love innocent smoothies and the tip on the packaging to freeze them was perfect last summer keep it in mind it will be here sooner than you think - time flies when your having innocent fun!, A great way of giving your kids one of their 5-a-day - especiallyas they come in many different flavours and have no additives or added sugar
## 2 I like this broth and I like garden peas, but I really dont think they go together. Edamame beans are a much better flavour fit for the Thai-style spicing. More edamame beans and ditch the peas, please!, Lots of chicken but way too spicy to enjoy., So many peas, actually more than broth! Maybe got a third of a mug of broth. Slightly too sweet. Not balanced at all. Not spicy. Wouldnt but again. Happy to try others. Bailey and Sage is incredible, I buy several of these a week and my family love them, however I have noticed the amount of chicken has been reduced drastically. It used to be a filling soup with chunks of chicken, now just a few shreds., Very tasty chicken soup. It helped me to recover from a nasty flu and get my energies back very quickly. Yum yum yum!, A wholesome super delicious fragrant soup with just the right amount of chicken and vegetables. This is all about the broth. I can eat this everyday., I bought this soup based on the number of good reviews.  Oh, it also helped that it was on offer.\nI was unimpressed. The quantity is stingy. Based on the nutrition info it looks as though this is meant for 2 people. There is not nearly enough for 2 people.\nWe added noodles to bulk it out into a decent lunch. \nThe soup itself is pleasantly flavoured but quite unpleasant to look at. It has the appearance of a cheap tinned soup, dull and murky looking veg.\nDisappointed!, Absolutely love this soup. Definite chilli kick but just right. Lots of veg and chicken, although the amounts of these can vary a bit between packs.  Easy to add some noodles to it if wanted, but portion size is just fine for me. . Its a bit pricey, but Ive bought lots when on offer and froze them. I probably have 3 packs a week. Do agree packaging could be looked at, as currently not recyclable., Makes a lovely healthy lunch. Warming and delicious and packed with veggies, I was hesitant about trying this as sometimes broths are a bit bland and the veg just bulls it out, wrong! Its so delicious just the right amount of heat and the chicken and veg was very generous. Thoroughly enjoyed it., Great for a light meal. Feels nutritious and has a well balanced flavour., It is a nice spice, you can feel it when you eat it.\nReally good broth, crunchy veg. Lovely chicken. Excellent!, not worth creating waste that lasts hundreds of years, just for a convenient lunch. daylesford know about this as they print that the plastic is not recyclable on their packaging., This is a very spicy soup, it has lots  flavour very filling and nourishing.  You can eat it straight up or make it a base for home-made soup.  I served it with some hot buttered toast, My husband said it was delicious and he loved the spiciness.  It was very filling and satisfying. Lots of uses for this bone broth. Can also be frozen., Very much enjoyed this, a bit like hot and sour soup. Tasty chicken within, overall delicious and will buy again, This soup is just wonderful, you really feel it doing you good. It is clear and nutritious and surprisingly filling with lovely flavours and aromas. I will certainly stock up when on offer, as it is so useful to have on hand in the freezer for when illness strikes., Deliciously comforting chicken broth., A LOVELY SOUP. LIGHT, CLEAR AND A INTERESTING TASTE.  LOST ONE STAR BECAUSE I ONLY HAD THREE VERY VERY SMALL PIECES OF CHICKEN, WHICH I FIND A BIT MEAN CONSIDERING THE PRICE, This is beautiful! The chilli is like a mild white pepper taste. The lemongrass is ever so subtle it's like it's barely there. A lot of 'ruffage' in there to make it a substantial soup for lunch. I am looking forward to it popping up on a flash sale again but I will probably buy it as a treat as well. Thus review is from someone who eats vegetarian 90% of the time too!, An amazing nourishing soup that was all the family could manage when sick with the virus.... A life saver !!, I bought this in a flash sale and Im so glad I did! It is so tasty and has a depth of flavour I could never achieve making my own bone broth at home. The spice level is very minimal and just right for my tastes. Feel like its quite expensive to buy full price but would buy it again if on offer - lovely treat with some added noodles!, Fab flavour, Full of flavour, texture, earthy., Would seriously live of these if I could. Perfect meal for one, just on its own. For two it can be boosted with some noodles and even a half tin of coconut milk. \n\nI make a lot of my own soups and asian-style broths but there is no way I could get this flavour without a serious kitchen team. The list of ingredients is exquisite and the taste really is beautiful. \n\nHave recommended this to so many people. Try and get it when it's on special. It freezes really well., Bought this in a flash sale and husband proclaimed it the best soup ever! Delicious spicy broth lots of depth of flavour and good chunks of chicken. With noodles added would make a good meal., This really is a quite marvellous soup with a fresh and unique flavour. A lovely beefy, slightly sour flavour with small pieces of chicken and lots of interesting herbs and spices. The only thing is it doesnt have much nutritional value for the money, it really is a broth rather than a meal., This is wholesome and filling., So satisfying and healthy! My favourite quick dinner, This is so tasty. Spicy  but great to have something handy in the fridge for when I don't have time to make lunch. It has no nasties or horrid preservatives it and the packaging is minimal., I don't like too much spice but I do like a little bit of heat. This was perfect for me. The nicest bone broth I have eaten-  I just wish it wasn't so expensive., Absolutely love this - even more when on offer!\nLovely and spicy - not plain and boring spicy - this is for proper chilli lovers.  Not too hot it'll burn for ages,  but a proper chilli kick.  Hope they keep doing this one., I really enjoy this soup for lunch. Not too spicy for me, but my 5-year old didnt enjoy the chilli. I added one whole squeezed lime, salt and quinoa as I had some leftover (not necessary though) and it was delicious. Very pleasantly surprised and will buy this every week., Broth for the soul, Recommended. Although one packet not really enough for two people! x, This is essentially a really spicy broth with not much other filling.  We found the chilli overpowering, and the soup just too watery., Full of flavours. Delicious., I regularly buy the chicken & gjnger broth thought we could give this a go. Yum! Loved the flavours! Warming and tasty. On this week's list!, Plenty of chicken and veg with beautiful flavours, I've put off buying any of these for ages because they're so expensive compared to other soup options. But now we're home so much I just wanted a treat. I got it! This is such a nice lunch. Flavours are well-balanced, loads of shredded chicken that actually looks like meat rather than weird lumps. Love them and will try more on the 3 for £12 deal., We buy this most weeks. Adding rice noodles makes it a light, healthy and tasty meal for two.  The mix of vegetables varies, as does the amount of chicken, but the chicken is always nice (no ucky bits). There have been more peas than soya beans in the last couple of batches but it is fresh so guess it varies with seasonal availability., I love Thai soup and I was thrilled when I bought this one ... taste is quite nice, not very Thai though ... and there is just too much peas .. would not buy again. Sorry Ocado., Ordinary chicken broth with no kick whatsoever -, A delicious soup ruined by a nasty heap of mealy, grey, revolting peas., We added some rice noodles to toss and it made for a delicious lunch. Great flavour!, Soup was full of flavour and lots of chicken and veg. Will definitely buy again. Bit expensive - so better with an offer!, This is delicious, I have a cold and feel it did me the world of good. However about 90% of the solid content were peas, a very cheap filler in an expensive soup so deducted a star, I really wanted to like the soup as I like the other Daylesford chicken soup but I was not keen in the flavours of this soup., This is so good, really tasty.It does have a little spicy kick to it, mostly ginger though not heat., Mine had nowhere near the amount of veg as in the picture hence the loss of a star, however tasted nice and will buy again hopefully the next one will have more vegetables then it will be perfect., Delicious fragrant broth!  Worthy of five stars!, This is so good and very low calorie. Slight kick and love the lemongrass and ginger. Will be in my weekly shop., This soup has just the right amount of heat for me. I thought that it was very tasty., It was very tasty, right amount of salt for a hot and sour soup which is supposed to be fairly salty. Good veg and chicken and just the right hint of spice which really helped me breathe being as I was suffering from a cold. Will be buying it again, specially if I'm poorly.
## 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   All I did was wash it, placed on foil with several whole and unpeeled garlic cloves and a few sprigs of rosemary and thyme, rubbed with olive oil then added salt and pepper. I tighy wrapped it all in the foil and  roasted for 2.5 hours at 180 c fan. When everything else was ready, I cut the top and mashed in butter, salt and pepper, put the lid back on, wrapped it back up in the foil and took to the table. Everyone just spooned out what they wanted. It has a wow factor, was delicious and so easy to cook!!, Why??? Totally unnecessary, typical from M&S to plastic wrap, awful!, Why the need for plastic wrap?? M&S really need to get their act together on this issue, I order celeriac regularly and it usually arrives with a date shorter than the 3 days advertised., Celeriac itself was fine but tiny! Not much bigger than your average grapefruit so had to go and buy another in order to make the meal I had planned., Like everyone else, I'm annoyed and frustrated by the wholly unnecessary plastic wrapping... the celeriac itself, however, is excellent, and a decent size which is a relief when buying food online., The first celeriac I bought was fresh enough but for the price paid it was unacceptably small - about the size of a grapefruit. Tried again this month and it was slightly bigger but still only 760g in weight. In all the main supermarkets including Waitrose the celeriac is priced per Kg and I wish Ocado would do the same or at least guarantee a minimum weight as Morrisons do online (900g). The latest purchase does not look very fresh either - wrapped in plastic but already overly brown on the cut faces on day of delivery.  Due to the small size I had to go out to purchase a 2nd celeriac locally and it's far better in size and quality than the M&S offering. Tried M&S celeriac on Ocado twice now and there will not be a third time!, Fresh, crunchy, makes great low carb chips, even the teenager liked them.  However, after several weeks of buying this item it suddenly halved in size so I have re-written the review and deducted a star.  Like one of the other reviewers said, there really ought to be a minimum weight!, A VEGETABLE THAT CAN BE INCLUDED IN A NUMBER OF DISHES., What can I say it is fresh crunchy and perfect, Always fresh and crunchy.  Good size., Good size, and made a delicious soup. Will buy again., This is just like back home. Essential for a good chicken soup., My 7 year old, husband and myself really enjoyed this celeriac as an alternative to potoato in our stew and also roasted.  Absolutely delighted and cannot wait to order some more.  Lovely sweet and nutty flavour., As per all the m&s veg, the quality is amazing - beautiful celeriac with which I created a great soup!, Made lovely celeriac soup will be buying again, I’ve bought this three times now and each time I’ve received a large, fresh celeriac. Season ends next month so will see how it goes., Not worth it, extremely small and old, Great quality celeriac, well trimmed and easy to prepare. Love that it's usually from British farms., The size is good. Its a celeriac. Minus points for plastic shrink wrap., perfect size - not too small, not too big. The flavour was good and very fresh when I made remoulade., Ocado's previous celeriac was often very small, but this lovely veg was a much better size. Perfect for roasting, soup, and a bubble and squeak ham hock hash!, Personally I love my celeriac roasted so I chopped this up in some olive oil salt and pepper and then in the oven for half an hour also until soft. I find you get quite a lot for one celeriac so I have any leftovers heated up and added to my lunchtime salad, which also works very well., Agree these are quite expensive for what they are but they do last well.  Use mainly in mash and thai currys., Wish the weight of these could be stated. Pretty expensive given its small size., We bought two because of the other reviews which has left us with way more celeriac than we need. Both were the same size, around 750g, and very good quality, Unlike other reviewers, the one we received was a good size, fresh and tasty. Will buy again!, Very tasty celeriac - we had it mashed with swede and carrots- delicious., I was astonished to find there is no minimum weight specified here. If you wonder why this is, it's tiny, about the size of a medium sized apple., Absolutely delicious mashed! Wonderful flavour. Perfect for those on diets. Versatile side dish for almost anything., Anybody else ever seen a celeriac for sale that is the size of a small person's palm?  Me neither! Difficult to imagine what will be left after peeling.  What's happened to M&S?, Inferior to the other MS products. The Waitrose Celeriac was much better.
```

Finally, it is also possible to grab the nutrition table, if it exists, 
associated with the products. If it does not exist, then the function returns 
NA and moves on to the next product.  


```r
oc_nutrition_table <- oc_collect_nutrition_table(oc_product_general$product_link[random_product_links[1:3]])
```

```r
oc_nutrition_table[1:3,]
```

```
##                                                                                                        product_link
## 1                              https://www.ocado.com/products/innocent-kids-apples-blackcurrants-smoothies-29362011
## 2 https://www.ocado.com/products/daylesford-organic-10-hour-chicken-bone-broth-with-lemongrass-red-chilli-502753011
## 3                                                             https://www.ocado.com/products/m-s-celeriac-518566011
##                                                                                                                                                                                                                                                                                                                                            nutrition
## 1 Energy, , Fat, (of which saturates), Carbohydrate, (of which sugars), Fibre, Protein, Salt, Vitamin C (%RI), 150ml = 1 serving = 1 of your 5-a-day, 4 servings in this pack, *% Reference Intake of adults, 241kJ, 57kcal, 0g, 0g, 13g, 10g, 0.6g, 0.4g, 0g, 36mg (44%*), , , , 362kJ, 85kcal, 0g, 0g, 20g, 15g, 0.8g, 0.6g, 0g, 53mg (67%*), , , 
## 2                                                                                                                                                                        Energy kJ, Energy kcal, Fat (g), of which saturates (g), Carbohydrates (g), of which sugars (g), Fibre (g), Protein (g), Salt (g), 122, 27, 0.5, 0.1, 3, 0.6, NA, 2.5, 0.32
## 3                                                                                                                                                                                                       Energy, Fat, of which saturates, Carbohydrate, of which sugars, Fibre, Protein, Salt, 75kJ/20kcal, 0.4g, 0.0g, 2.3g, 1.8g, 3.7g, 1.2g, 0.23g
```

## Close Selenium Server

```r
remDr$close()
gc(remDr)
rm(remDr)
```

## Cleaning Functions
A lot of the data cleaning process can be handled with the 
[dplyr](https://dplyr.tidyverse.org) package. 
However, some data wrangling functions were created specifically to clean the 
data that is scraped from the 2 websites above. 

For example, the 2 functions `extract_energy` and `extract_kcal` can be 
used sequentially to extract the number of kcals in a product from its 
nutrition table (even if the calories are in kJ).  

```r
# Extract product kcals frm nutrition table
data("oc_data")
calories <- extract_energy(oc_data, item = "product", nutrition = "nutrition")
kcal <- extract_kcal(calories)
```

## Collected Datasets
The elGrocer and Ocado websites were partially scraped and the data collected 
was put into different tibbles that can be further analyzed 
(e.g., joined and plotted).  

Datasets collected from elGrocer have the pre-fix `eg_`, while Ocados' have 
the pre-fix `oc_`. View the help page for each dataset for more 
info (e.g., ?oc_data). Listed below are the available datasets in this 
package.  


```r
# Run the following command to load any of the datasets (in the global environment)
# data("name of dataset from below")
data(eg_location)
```


#### elGrocer Data
1. `eg_location`: names and links of 131 locations that have grocery stores 
that provide online delivery services.  
2. `eg_store`: details for 184 grocery stores that provide online 
delivery services.  
3. `eg_category`: 3,278 product categories in different grocery stores.  
4. `eg_subcategory`: 1,156 product subcategories chosen randomly from 300 
categories in different grocery stores.  
5. `eg_product`: name, weight, price and image link of more than 
15,000 grocery products.  
6. `eg_data`: names and other attributes of over 15,000 grocery products. 
This table was built by 
joining *eg_product*, *eg_subcategory* and *eg_category*.  


```r
eg_data[c(5, 10, 1000, 2000, 2005),] %>% str()
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	5 obs. of  9 variables:
##  $ store_name         : chr  "8 Supermarket Jvt" "8 Supermarket Jvt" "Ajman Coop  - Jurf" "Al Ain Coop Al Wagan" ...
##  $ category           : chr  "Condiments" "Condiments" "Snacks" "Pasta & Rice" ...
##  $ subcategory        : chr  "Salt" "Spices, Pulses & Grains" "Biscuits" "Rice" ...
##  $ item               : chr  "Ina Parman Coarse Sea Salt" "Barrio Fiesta Beef Broth Cubes" "Ulker Rulokat" "Kfmb Pizza Mix" ...
##  $ weight             : chr  "100ml" "60g" "24G" "1kg" ...
##  $ price              : num  2.633 0.654 0.249 1.857 13.176
##  $ category_image_link: chr  "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/000/103/medium/Condiments.jpg?1562617658" "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/000/103/medium/Condiments.jpg?1562617658" "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/000/097/medium/CC_300x180.png?1595785041" "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/categories/logos/000/000/094/medium/Pasta-_-Rice2.png?1531410405" ...
##  $ item_image_link    : chr  "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/013/607/medium/6009678810830.JPG?1474491673" "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/218/516/medium/4800119238655.jpg?1607868963" "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/016/082/medium/8690504019091.png?1474100648" "https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos/000/249/698/medium/6271003011155.jpg?1616259908" ...
##  $ store_link         : chr  "https://www.elgrocer.com/store/8-supermarket-jvt/categories" "https://www.elgrocer.com/store/8-supermarket-jvt/categories" "https://www.elgrocer.com/store/ajman-coop-jurf-329/categories" "https://www.elgrocer.com/store/al-ain-coop-al-wagan/categories" ...
```


#### Ocado Data
1. `oc_category`: 13 category names and links.  
2. `oc_product_general`: general info for almost 9,000 grocery products.  
3. `oc_product_extra`: extra info (e.g., rating, brand) for almost 
1,000 grocery products.  
4. `oc_product_review`: reviews for almost 1,000 grocery products.  
5. `oc_nutrition_table`: nutrition tables for almost 1,000 grocery products.  
6. `oc_data`: names and other attributes of almost 9,000 grocery products. 
This table was built by joining *oc_product_general*, *oc_product_extra*, 
*oc_category*, and *oc_product_review* and *oc_nutrition_table*.  


```r
oc_data[5006:5010,] %>% str()
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	5 obs. of  17 variables:
##  $ category      : Factor w/ 13 levels "Fresh & Chilled Food",..: 1 1 1 1 1
##  $ brand         : chr  NA NA NA "WUNDA" ...
##  $ product       : chr  "Scandi Kitchen Dill & Mustard Sauce" "M&S 24 Sticky Asian Style Chicken Lollipops" "Ramona's Jalapeno Houmous" "WUNDA Original Plant Based Not Milk" ...
##  $ price         : num  2.7 14.7 3 1.9 2.85
##  $ weight        : chr  "200g" "640g" "500g" "950ml" ...
##  $ badge         : chr  NA NA NA "Suitable for vegetarians" ...
##  $ shelf_life    : Factor w/ 19 levels "LIFE 2d+","LIFE 4d+",..: NA 5 4 NA 11
##  $ country       : chr  NA NA NA NA ...
##  $ rating        : num  NA NA NA 3.6 NA
##  $ num_of_reviews: num  NA NA NA 8 NA
##  $ recommend     : num  NA NA NA 63 NA
##  $ ingredient    : chr  NA NA NA "Water, Pea Protein (2.6%), Chicory Root Fibre, Sugar, Sunflower Oil, Acidity Regulator (Potassium Phosphates), "| __truncated__ ...
##  $ reviews       :List of 5
##   ..$ : NULL
##   ..$ : NULL
##   ..$ : NULL
##   ..$ :Classes 'tbl_df', 'tbl' and 'data.frame':	8 obs. of  1 variable:
##   .. ..$ reviews: chr  "Mildly sweet / vanilla taste. Slightly sweeter than cows milk but similar taste. Great with hot drinks and cere"| __truncated__ "Yes, as a low carb non milk thing this is absolutely great.  I could drink on it's own or have over cereal (tha"| __truncated__ "I havent tried the milk alone, normally coconut milk is the only milk I drink alone or in cereal but this milk "| __truncated__ "I use both this and the unsweetened version interchangeablly for my morning cappucino as it froths up like a dr"| __truncated__ ...
##   ..$ : NULL
##  $ nutrition     :List of 5
##   ..$ : NULL
##   ..$ : NULL
##   ..$ : NULL
##   ..$ :Classes 'tbl_df', 'tbl' and 'data.frame':	14 obs. of  2 variables:
##   .. ..$ Typical Values: chr  "Energy" "" "Fat" "of which: saturates" ...
##   .. ..$ per 100mL     : chr  "146kJ /" "35kcal" "1.4g" "0.1g" ...
##   ..$ : NULL
##  $ image_link    : chr  "https://www.ocado.com/productImages/337/337055011_0_150x150.jpg?identifier=53909b7ec7345048f670d1f9e36ff7c2" "https://www.ocado.com/productImages/524/524931011_0_150x150.jpg?identifier=9eb33ba91a53d7c4fd95d0cde4b2321e" "https://www.ocado.com/productImages/548/548991011_0_150x150.jpg?identifier=0a7bddf44d405d6e24ddc49d5226fa4b" "https://www.ocado.com/productImages/568/568197011_0_150x150.jpg?identifier=2508af746a5a93e7125f8d8a03bf1b5c" ...
##  $ product_link  : chr  "https://www.ocado.com/products/scandi-kitchen-dill-mustard-sauce-337055011" "https://www.ocado.com/products/m-s-24-sticky-asian-style-chicken-lollipops-524931011" "https://www.ocado.com/products/ramona-s-jalapeno-houmous-548991011" "https://www.ocado.com/products/wunda-original-plant-based-not-milk-568197011" ...
##  $ category_link : chr  "https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true" "https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true" "https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true" "https://www.ocado.com/browse/fresh-chilled-food-20002?hideOOS=true" ...
```


## Available Grocery Store Data  
These datasets were generated to mimic 3 simple databases of a fake 
grocery store, which we will call 'funmart':  
1. `customer_db_funmart`: customer id, name, age, household size and 
location (4,996 customers).  
2. `order_db_funmart`: order id, customer id, order date, payment method 
and order time (12,000 orders).  
3. `basket_db_funmart`: basket id, order id, products purchased in each 
basket and price of products. There were 200 products, 
with different probabilities for each, to select from in the fake grocery 
store, 'funmart'. Over 140,000 products were bought in all baskets combined.  

#### Generate Your Own Grocery Store Data   
While the 3 datasets above are available in the package, you are able to 
generate more grocery store data to use in your anlysis using the R shiny app 
associated with this project: ...  

## Analyze Package Data
A myriad of analysis can be conducted on the data in this package. Here are 
some ideas (and 2 examples) of what you can do:  
1. Analyze text from the product reviews and/or ingredients.  
2. Build interactive tables.  
3. Create all kinds of graphs to summarize data.   
4. Deploy a recommendation system using the data from 
'Generate Grocery Store Data' app.  
5. Employ a market basket analysis algorithm 
(e.g., Apriori or FP-Growth algorithms).  

#### Top 5 Most Reviewed Products

```r
library(tidyverse)
library(ggimage)
library(ggrepel)

blue_palette <- c("#99D8EB", "#81C3D7", "#62A7C1", "#3A7CA5", 
                  "#285F80", "#16425B", "#0C2C3E", "#051E2C")

# Grab the top 5 most reviewed products from Ocado data
oc_top5_rev <- 
  oc_data %>% 
    select(product, rating, num_of_reviews, recommend, image_link) %>% 
    slice_max(n = 5, order_by = num_of_reviews) %>% 
    mutate(product = product %>% fct_reorder(num_of_reviews) %>% fct_rev()) %>% 
    bind_cols(palette = c("#DFBF61", blue_palette[7], "#BFB394", "#D85252", "#D87B3D"))

# Graph the images of the products and add labels
oc_top5_rev %>% 
  ggplot(aes(x = product, y = num_of_reviews)) + 
  geom_image(aes(image = image_link), size = .2) + 
  geom_label_repel(aes(label = glue::glue("{num_of_reviews} reviews\n{recommend}% recommend"), 
                       fill = product), 
                   colour = "white", 
                   segment.colour = oc_top5_rev$palette, 
                   segment.curvature = -0.5, 
                   segment.ncp = 3,
                   segment.angle = 20, 
                   fontface = "bold", 
                   box.padding = unit(2, "cm"),
                   point.padding = unit(2, "cm")) + 
  labs(x = "Product", y = "Reviews", 
       title = ("5 Most Reviewed Products"), 
       subtitle = "Customer recommendation rate (%)") + 
  hrbrthemes::theme_ipsum(grid = FALSE) + 
  coord_cartesian(ylim = c(0, 1000)) + 
  scale_x_discrete(labels = function(x) str_wrap(x, width = 15)) + 
  scale_fill_manual(values = setNames(oc_top5_rev$palette, levels(oc_top5_rev$product))) + 
  theme(legend.position = "none")
```

![](grocerycart-vignette_files/figure-html/oc-top-5-1.png)<!-- -->


#### Interactive Table

```r
library(reactable)
data(oc_data)

# Create palette
oc_palette <- c("#D3CAEC", "#B3A2E7", "#9F8BDC", "#7D67BD",
                "#664EAB", "#513C90", "#36246C", "#281956")

# Number of products per brand
oc_pro <- 
  oc_data %>% 
    select(brand, product) %>% 
    filter(!is.na(brand)) %>% 
    count(brand, name = "products") %>% 
    arrange(desc(products))

# Create interactive table that highlights average price for each brand
oc_top_pro <- 
  oc_data %>% 
    inner_join(oc_pro, by = "brand") %>% 
    group_by(brand) %>% 
    summarise(products = n(), 
              avg_price = round(mean(price, na.rm = TRUE), 2), 
              median_price = round(median(price, na.rm = TRUE), 2), 
              max_price = round(max(price, na.rm = TRUE), 2), 
              min_price = round(min(price, na.rm = TRUE), 2))

oc_pal <- function(x) rgb(colorRamp(c(oc_palette[1], oc_palette[6]))(x), 
                          maxColorValue = 255)

oc_top_pro %>% 
  reactable(
    defaultSortOrder = "desc", 
    defaultSorted = c("products", "avg_price"), 
    columns = list(
      avg_price = colDef(style = function(.x) {
        norm_avg_price <- 
          (.x - min(oc_top_pro$avg_price)) / (max(oc_top_pro$avg_price) - min(oc_top_pro$avg_price))
        
        color <- oc_pal(norm_avg_price)
        
        list(background = color)
      })
    ), 
    defaultColDef = colDef(
      header = function(.x) {str_replace(.x, "_", " ") %>% str_to_title()},
      cell = function(.x) format(.x, nsmall = 1),
      align = "center",
      minWidth = 70, 
      headerStyle = list(background = "light grey")
    ), 
    defaultPageSize = 20, 
    bordered = TRUE, striped = TRUE, highlight = TRUE
  )
```

```{=html}
<div id="htmlwidget-a983d0d699963dcbcc25" class="reactable html-widget" style="width:auto;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-a983d0d699963dcbcc25">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"brand":["Abba Seafood","Acqua Panna","Actimel","ACTIPH","Activia","Allinson's","Almond Breeze","Alpro","Alvalle","Amisa","Anchor","Aqua Carpatica","Arla","Auga","Azera","Babybel","Baker Street","Balaggan","Barebells","Barr","Bastides","Baxters","Beanies","Belvoir","Benecol","Bertagni","Bertinet","Bertolli","Big & Welsh","Bio & Me","Biona","Biotiful","Birchall Tea","BOL","BONSAN","BOROUGH BROTH CO","Bottleshot Brew","Boursin","Brew Tea Co","Brindisa","Brioche Pasquier","Brynmor","BumbleZest","Buxton","Cadbury","Cafedirect","Caffe Nero","CALON WEN","Capri Sun","Capri-Sun","Carbzone","Carte Noire","Cathedral City","Cawston Press","Celtic Bakers","ChariTea","Charlie Bigham's","Chavroux","Chicago's Best","ChicP","Clamato","Clarence Court","Clearspring","Clipper","Clive's","Coca-Cola","Cocio","Coconut Collab","COCOS","Coldpress","Cool Chile","Copella","Costa","Cote","Country Life","CPRESS","Cravendale","Crazy Jack","Creative Nature","Cru Kafe","Curious","Cypressa","Dairylea","Daylesford","DAYLESFORD ORGANIC","Delicato","Dell' Ugo","Divine","Dolce Gusto","Double Dutch","Douwe Egberts","Dr Pepper","Dragonfly","Dragonfly Tea","Drink Me Chai","East India Company","Ekstroms","Elsinore","Epiros","Evian","EXALT","Fanta","Feel Good","Fentimans","Fever-Tree","Finnebrogue","Fitzgeralds","Florette","Folkington's","Forest Feast","Four Sigmatic","Frubes","FRUIT SHOOT","GAIL's","Galaxy","Galbani","Genius","Giffard","Giovanni Rana","Glenilen Farm","Good Grain","Gosh","Gradz Bakery","Graze","GREEN COLA","Gusto","H. Forman & Son","Hampshire Game","Hampstead Tea","Happy Eggs","Happy Monkey","Harrods","Harry & Percy","Harvey Nichols","Hawksmoor","Heartsease Farm","Heath & Heather","Heinz","Higgidy","HIGH5","Highland Spring","Holy Moly","Hoogly Tea","Hook, Line and Sinker","Horlicks","Houghton","Hovis","Ilchester","Illy","Innocent","Irn Bru","Irn-Bru","Irwins","Itsu","Jack Link","Joe's Tea","John West","Jolly Hog","Jon Thorners","Jucee","Jude's","Karaway","Karma Cola","Kenco","Kib Tea","Kim Kong Kimchi","Kokoa Collection","Kuka","L'OR","La Boulangère","Lactofree","Lavazza","Laverstoke Park","Leerdammer","Liberte","Liberto","Light & Free","Little Dish","Little Freddie","Living Seedful","Living Tenderleaves","Lo Bros","Loch Fyne","London Essence Co.","Love Me Tender","Lovemore","Lucozade","Lurpak","Lye Cross Farm","M&S","Mattessons","Maximuscle","Mcvitie's","Melrose & Morgan","Merchant's Heart","Minor Figures","Modern Baker","Moju","Monin","Mowi","Moy Park","Mr Freed's","Mr Kipling","Mrs Crimble's","Munch Bunch","Murgella","Naked","Natoora","Nature Valley","Naturelly","Natures Aid","Naturya","Nescafe","Nesquik","Nestle","New York Bagel","New York Bakery","Newby Teas","Nexba","Nipper&Co","Nishaan","Nix & Kix","Nocco","Nurishment","O.R.S","Oatly","Ocado","Ocean Spray","Onken","Optimum Nutrition","Orchardworld","Original Beans","Oteas","Oxo","Oykos","Pack'd","Packington","Pagen","Parmareggio","Pasta Evangelists","Pataks","Patteson's","Pellini","Peperami","Pepsi","Petits Filous","PG Tips","Philadelphia","Pieminister","Pip Organic","Pizza Pilgrims","PLENISH","Pomegreat","Potts","President","PretAManger","Promise Gluten Free","Provamel","PUKKA","Pukka Pies","Pukka Teas","Pulsin","Punchy","Purely Organic","Purition","R Whites","Rachel's","Radnor","Ramona's Kitchen","Re Nourish","Rebel Kitchen","Red Bull","Remedy","Ribena","Richmond","Roastworks","Robinsons","Rogers Estate Coffee","Rokit Pods","Rose's","Ruby","Rude Health","Russell's","Sabra","Samosa Co","San Pellegrino","Schar","Schweppes","Seafood & Eat It","Seriously Strong","Sharwood's","Shloer","Slim Fast","Slim-Fast","Soda Folk","SodaStream","Soli","Solo Coffee","Soreen","Soulful","Sound Seafood","Soupologie","Specialite","St Helens Farm","St Michel","St. Ivel","Steve's Leaves","Stonegate","Storm Tea","Sweet Freedom","T2","Taifun","TaikiTea","Tango","Tanpopo","Tassimo","Taylors Of Harrogate","Tea Plus","Teapigs","Teisseire","Tenzing","Tetley","The Black Farmer","The Collective","The Collective Dairy","The Cultured Collective","The Fish Market","The Fresh Pasta Co.","The Heart of Nature","The Polish Bakery","The Spice Tailor","The Vegetarian Butcher","This is not","Thorncroft","Tiana","Tick Tock","Tickler","Tideford","Tims Dairy","Tofoo","Tortuga","Total Greek","Tropicana","Tropicana Plus","Trucillo","Twinings","Ueshima","UFC","UFit","Unearthed","Union Hand-Roasted","Unrooted","Up&Go","Valsoia","Vbites","Vimto","VIOLIFE","Vita Coco","Volcano Coffee Works","Voss","Warburtons","Watts Farm","Whittard","Whitworths","Wholegood","Wild Hibiscus","Willy Chase's","WUNDA","Wunder Workshop","XITE","Yakult","Yarden","Yeo Valley","Yogi Tea","Yorkshire Provender","Yorkshire Tea"],"products":[1,1,4,3,2,1,1,6,1,1,2,1,1,1,1,1,1,1,2,1,1,1,4,3,2,1,1,1,1,1,6,1,5,5,1,3,1,3,4,2,1,1,1,1,5,1,1,1,1,1,1,3,1,1,1,1,3,1,1,1,1,1,1,3,1,3,1,1,1,3,1,1,3,1,2,1,2,1,1,5,1,1,5,7,30,1,3,1,4,1,2,1,1,1,1,3,1,1,2,1,1,1,1,1,6,1,1,3,2,1,1,1,3,2,1,2,3,1,1,1,2,2,1,1,2,2,1,1,2,1,1,1,1,5,2,1,2,2,3,2,1,1,1,1,1,1,1,1,2,5,1,1,2,3,1,1,1,2,3,1,2,1,1,6,1,1,1,1,4,1,1,1,1,1,1,1,3,1,1,1,1,3,2,2,1,2,4,6,5,234,1,1,1,1,2,1,1,3,1,1,4,1,4,1,1,1,3,18,1,1,1,1,1,3,1,1,1,2,1,1,1,1,2,2,1,4,43,1,1,1,1,1,2,1,1,1,2,1,1,1,3,1,1,2,4,2,2,1,1,4,1,6,1,1,3,1,1,1,1,1,2,1,1,1,2,2,5,1,1,2,1,1,1,2,1,7,5,1,1,1,1,1,2,1,3,1,1,3,1,2,1,1,1,3,2,2,2,1,2,2,3,3,1,1,1,1,1,1,1,2,3,2,1,2,4,3,4,1,4,1,1,4,1,5,2,1,1,3,1,1,1,2,1,1,2,1,1,1,1,1,1,2,5,1,1,17,2,1,3,5,2,2,1,1,1,1,1,2,2,1,5,1,1,1,4,1,1,1,1,1,1,1,5,1,1,1],"avg_price":[3.5,1.2,2.66,3,2.2,1.4,1.5,1.63,4.1,4,1.7,6.3,2.8,4.9,3,2.05,1.75,6,2.5,1.35,5,1.75,2.5,3.22,3.4,4.5,3.95,3.65,1.61,1.35,4.27,1.85,4.5,2.52,2.9,5.5,2.3,2.02,5.65,4.48,1.25,0.8,2.49,3,1.76,4,4.45,2,1.49,2.1,2.8,2.79,2.25,4.3,3.35,1.55,7.08,2,5,3.7,3.6,2.8,4.68,3.13,3.25,7.08,1.65,2.75,5,2.8,3.2,3,3.03,3.95,2.8,2,1.62,3.05,7,4.03,1.5,2.8,1.55,8.33,7.06,3.2,3.07,2.85,3.62,3.6,7.82,8.25,2.3,2.5,3.3,17.67,2.9,6,5.25,8,4.95,4.4,1.2,1.4,8.21,3.1,1.4,1.62,1.3,3,24,1,4.33,3.85,3.8,2.95,1.88,8,2.1,1,4.78,2.45,4.5,2.7,4.25,1.77,16.5,20,2.6,3.2,2.3,4.5,2,8.55,1.8,1.5,2.75,2,3.4,9.37,3.25,3,5,6.99,3.5,3.5,1.65,2.1,6.3,3.35,5,3,1.4,3.5,1.5,3,2.5,2.75,6.25,2,1.7,4.5,4.5,3.53,3.99,4.32,6,3,3.99,1.3,2.5,14,2.7,2,2.2,15,1.6,2.5,3.2,2.5,1.5,2,10,9.25,3.05,2.22,1.69,3.54,3.63,3.52,2.85,2.5,1.4,8,1.1,2.4,5,4.32,3,7,3.03,5.95,1.82,1.2,1.65,2.99,3.58,3.67,2,0.9,8,16,7.5,2.32,3,1.2,1.3,6,1.4,6.5,1.1,2.85,2.2,1,5,1.55,2.4,5.6,1.6,2,3.2,3.95,3.55,2.6,2.5,4.25,8.78,1.85,3.15,11,1.25,3.45,3.65,1.65,4.55,2,3.02,3,6.5,3.95,14.5,3.05,3.5,2.5,1.86,4,3,2,16,1.8,3.45,3,1.35,2.65,13,2.5,1.34,3.5,3,2.17,1.99,1.3,5,2.33,2.5,4.5,1.87,4.75,5,2.4,0.9,3,5,2.2,3,3,2,1.22,3,2.17,2,2.4,6.49,6.71,3,6,3.5,12,1.75,2.5,4.43,3,1.6,1.85,1.5,1.2,1.5,2.8,9.5,2.97,3.55,4.25,25,3.65,8,3.8,7.74,4,5.51,3.8,1.45,2.71,2.65,1.42,3.9,5.45,7,2.93,3.25,1.25,2.2,2.62,2.95,3.25,9.99,1.61,4,2.8,2.1,2,12,1.12,3.31,3,3.5,2.79,3.62,2,2.33,3.52,5.5,2,2.75,1.75,2.5,2.8,2.5,2.1,24.3,1.25,1.03,2.75,12,1.9,3.21,5,2,1.9,6.3,1.5,6,2.2,1.76,2.4,3,5.6],"median_price":[3.5,1.2,3,2,2.2,1.4,1.5,1.73,4.1,4,1.7,6.3,2.8,4.9,3,2.05,1.75,6,2.5,1.35,5,1.75,2.5,2.95,3.4,4.5,3.95,3.65,1.61,1.35,4.74,1.85,4.5,2.4,2.9,5.5,2.3,2,5.25,4.48,1.25,0.8,2.49,3,1.5,4,4.45,2,1.49,2.1,2.8,2.79,2.25,4.3,3.35,1.55,8.25,2,5,3.7,3.6,2.8,4.68,3,3.25,4.9,1.65,2.75,5,2.8,3.2,3,3.7,3.95,2.8,2,1.62,3.05,7,3.75,1.5,2.8,1.45,6.2,4.4,3.2,3,2.85,3.5,3.6,7.82,8.25,2.3,2.5,3.3,8,2.9,6,5.25,8,4.95,4.4,1.2,1.4,4.42,3.1,1.4,1.6,1.3,3,24,1,3,3.85,3.8,2.95,2.05,8,2.1,1,4.78,2.45,4.5,2.7,4.25,1.77,16.5,20,2.6,3.2,2.3,4.5,2,7.95,1.8,1.5,2.75,2,3.5,9.37,3.25,3,5,6.99,3.5,3.5,1.65,2.1,6.3,3.3,5,3,1.4,3.5,1.5,3,2.5,2.75,6.5,2,1.7,4.5,4.5,3.7,3.99,4.32,6,3,3.22,1.3,2.5,14,2.7,2,2.2,15,1.87,2.5,3.2,2.5,1.5,2,10,9.25,3.05,2.22,1.25,3.25,3.53,2.65,2.85,2.5,1.4,8,1.1,2.4,5,4.66,3,7,3.1,5.95,1.73,1.2,1.65,2.99,4,3.5,2,0.9,8,16,7.5,2.6,3,1.2,1.3,6,1.4,6.5,1.1,2.85,2.2,1,5,1.6,2,5.6,1.6,2,3.2,3.95,3.55,2.6,2.5,4.25,8.78,1.85,3.15,11,1.25,3.45,3.65,1.65,3.3,2,3.02,3,6.5,3.95,14.5,3.14,3.5,2.5,1.87,4,3,2,16,1.8,3.45,3,1.35,2.65,13,2.5,1.5,3.5,3,2.17,1.99,1.3,5,2.33,2.5,4.5,1.85,4.75,5,2.4,0.9,3,5,2.2,3,3,2,1.55,3,2.17,2,2.4,6.49,9.01,3,6,3.5,12,1.75,2.5,4.42,3,1.6,1.85,1.5,1.2,1.5,2.8,9.5,2.97,3.5,4.25,25,3.65,6.6,3.7,7.68,4,4.07,3.8,1.45,2.35,2.65,1.7,3.9,5.45,7,3,3.25,1.25,2.2,2.62,2.95,3.25,9.99,1.61,4,2.8,2.1,2,12,1.12,2.75,3,3.5,2.7,3.62,2,2,3.65,5.5,2,2.75,1.75,2.5,2.8,2.5,2.1,24.3,1.25,1.05,2.75,12,1.9,3.15,5,2,1.9,6.3,1.5,6,2.2,1.8,2.4,3,5.6],"max_price":[3.5,1.2,3,5.5,2.2,1.4,1.5,2,4.1,4,1.7,6.3,2.8,4.9,3,2.05,1.75,6,2.5,1.35,5,1.75,2.5,3.75,3.95,4.5,3.95,3.65,1.61,1.35,5.7,1.85,5,3,2.9,5.5,2.3,2.1,7.5,5,1.25,0.8,2.49,3,3.55,4,4.45,2,1.49,2.1,2.8,2.79,2.25,4.3,3.35,1.55,8.5,2,5,3.7,3.6,2.8,4.68,4.6,3.25,13.45,1.65,2.75,5,2.8,3.2,3,3.7,3.95,3.6,2,2,3.05,7,5.75,1.5,2.8,2.25,20,30,3.2,3.5,2.85,4,3.6,10.99,8.25,2.3,2.5,3.3,40,2.9,6,6,8,4.95,4.4,1.2,1.4,18.25,3.1,1.4,1.75,1.3,3,24,1,7,4.2,3.8,3.9,2.1,8,2.1,1,5,2.5,4.5,2.7,4.25,1.8,16.5,20,2.6,3.2,2.3,4.5,2,9.95,1.8,1.5,3,2,4,17.49,3.25,3,5,6.99,3.5,3.5,1.65,2.1,6.5,3.8,5,3,1.45,3.5,1.5,3,2.5,2.75,8.75,2,1.7,4.5,4.5,5,3.99,4.32,6,3,6.35,1.3,2.5,14,2.7,2,2.2,15,1.87,2.5,3.2,2.5,1.5,2,13,15,3.05,2.25,3,7,5.25,25,2.85,2.5,1.4,8,1.1,2.4,5,4.66,3,7,4,5.95,2.35,1.2,1.65,2.99,4,5,2,0.9,8,16,7.5,3.35,3,1.2,1.3,6,1.4,6.5,1.1,2.85,2.2,1,5,1.8,8.99,5.6,1.6,2,3.2,3.95,3.55,2.6,2.5,4.25,12.96,1.85,3.15,11,1.25,3.45,3.65,2,9.5,2,3.3,3,6.5,4,14.5,3.75,3.5,2.5,2.1,4,3,2,16,1.8,3.45,3,1.35,2.65,13,3.65,2,3.5,3,2.17,1.99,1.3,5,2.65,2.5,4.5,2.5,4.75,5,2.4,0.9,3,5,2.2,3,3,2,1.6,3,2.75,2,2.4,6.49,9.01,3,8,3.5,12,2,2.5,4.53,3,1.6,1.85,1.5,1.2,1.5,2.8,9.5,2.97,3.65,5,25,3.65,15.5,4,11.5,4,12,3.8,1.45,4,2.65,2.2,3.9,5.45,7,3,3.25,1.25,2.2,2.75,2.95,3.25,17.99,1.61,4,2.8,2.1,2,12,1.15,4.4,3,3.5,4,4,2,3,3.8,5.5,2,2.75,1.75,2.5,2.8,2.5,2.5,27,1.25,1.1,2.75,12,1.9,4.5,5,2,1.9,6.3,1.5,6,2.2,2.75,2.4,3,5.6],"min_price":[3.5,1.2,1.65,1.5,2.2,1.4,1.5,0.85,4.1,4,1.7,6.3,2.8,4.9,3,2.05,1.75,6,2.5,1.35,5,1.75,2.5,2.95,2.85,4.5,3.95,3.65,1.61,1.35,2.35,1.85,4,2.4,2.9,5.5,2.3,1.95,4.6,3.96,1.25,0.8,2.49,3,0.25,4,4.45,2,1.49,2.1,2.8,2.79,2.25,4.3,3.35,1.55,4.5,2,5,3.7,3.6,2.8,4.68,1.8,3.25,2.9,1.65,2.75,5,2.8,3.2,3,1.7,3.95,2,2,1.25,3.05,7,3.45,1.5,2.8,1.25,3.5,1.2,3.2,2.7,2.85,3.5,3.6,4.65,8.25,2.3,2.5,3.3,5,2.9,6,4.5,8,4.95,4.4,1.2,1.4,1.95,3.1,1.4,1.5,1.3,3,24,1,3,3.5,3.8,2,1.5,8,2.1,1,4.55,2.4,4.5,2.7,4.25,1.75,16.5,20,2.6,3.2,2.3,4.5,2,7.95,1.8,1.5,2.5,2,2.7,1.25,3.25,3,5,6.99,3.5,3.5,1.65,2.1,6.1,2.75,5,3,1.35,3.5,1.5,3,2.5,2.75,3.5,2,1.7,4.5,4.5,1,3.99,4.32,6,3,3.15,1.3,2.5,14,2.7,2,2.2,15,1.05,2.5,3.2,2.5,1.5,2,7,3.5,3.05,2.2,1.25,2.25,2.6,0.6,2.85,2.5,1.4,8,1.1,2.4,5,3.63,3,7,1.93,5.95,1.5,1.2,1.65,2.99,2.75,0.86,2,0.9,8,16,7.5,1,3,1.2,1.3,6,1.4,6.5,1.1,2.85,2.2,1,5,1.2,0.69,5.6,1.6,2,3.2,3.95,3.55,2.6,2.5,4.25,4.6,1.85,3.15,11,1.25,3.45,3.65,1.3,2.1,2,2.75,3,6.5,3.9,14.5,2,3.5,2.5,1.6,4,3,2,16,1.8,3.45,3,1.35,2.65,13,1.35,0.75,3.5,3,2.17,1.99,1.3,5,2,2.5,4.5,1.25,4.75,5,2.4,0.9,3,5,2.2,3,3,2,0.5,3,1.6,2,2.4,6.49,2.1,3,4,3.5,12,1.5,2.5,4.35,3,1.6,1.85,1.5,1.2,1.5,2.8,9.5,2.97,3.5,3.5,25,3.65,3.3,3.7,4.1,4,1.9,3.8,1.45,2.15,2.65,0.75,3.9,5.45,7,2.8,3.25,1.25,2.2,2.5,2.95,3.25,2,1.61,4,2.8,2.1,2,12,1.1,2.5,3,3.5,1.7,3.25,2,2,3.25,5.5,2,2.75,1.75,2.5,2.8,2.5,1.7,21.6,1.25,0.95,2.75,12,1.9,2.05,5,2,1.9,6.3,1.5,6,2.2,0.6,2.4,3,5.6]},"columns":[{"accessor":"brand","name":"brand","type":"character","cell":["Abba Seafood","Acqua Panna","Actimel","ACTIPH","Activia","Allinson's","Almond Breeze","Alpro","Alvalle","Amisa","Anchor","Aqua Carpatica","Arla","Auga","Azera","Babybel","Baker Street","Balaggan","Barebells","Barr","Bastides","Baxters","Beanies","Belvoir","Benecol","Bertagni","Bertinet","Bertolli","Big & Welsh","Bio & Me","Biona","Biotiful","Birchall Tea","BOL","BONSAN","BOROUGH BROTH CO","Bottleshot Brew","Boursin","Brew Tea Co","Brindisa","Brioche Pasquier","Brynmor","BumbleZest","Buxton","Cadbury","Cafedirect","Caffe Nero","CALON WEN","Capri Sun","Capri-Sun","Carbzone","Carte Noire","Cathedral City","Cawston Press","Celtic Bakers","ChariTea","Charlie Bigham's","Chavroux","Chicago's Best","ChicP","Clamato","Clarence Court","Clearspring","Clipper","Clive's","Coca-Cola","Cocio","Coconut Collab","COCOS","Coldpress","Cool Chile","Copella","Costa","Cote","Country Life","CPRESS","Cravendale","Crazy Jack","Creative Nature","Cru Kafe","Curious","Cypressa","Dairylea","Daylesford","DAYLESFORD ORGANIC","Delicato","Dell' Ugo","Divine","Dolce Gusto","Double Dutch","Douwe Egberts","Dr Pepper","Dragonfly","Dragonfly Tea","Drink Me Chai","East India Company","Ekstroms","Elsinore","Epiros","Evian","EXALT","Fanta","Feel Good","Fentimans","Fever-Tree","Finnebrogue","Fitzgeralds","Florette","Folkington's","Forest Feast","Four Sigmatic","Frubes","FRUIT SHOOT","GAIL's","Galaxy","Galbani","Genius","Giffard","Giovanni Rana","Glenilen Farm","Good Grain","Gosh","Gradz Bakery","Graze","GREEN COLA","Gusto","H. Forman & Son","Hampshire Game","Hampstead Tea","Happy Eggs","Happy Monkey","Harrods","Harry & Percy","Harvey Nichols","Hawksmoor","Heartsease Farm","Heath & Heather","Heinz","Higgidy","HIGH5","Highland Spring","Holy Moly","Hoogly Tea","Hook, Line and Sinker","Horlicks","Houghton","Hovis","Ilchester","Illy","Innocent","Irn Bru","Irn-Bru","Irwins","Itsu","Jack Link","Joe's Tea","John West","Jolly Hog","Jon Thorners","Jucee","Jude's","Karaway","Karma Cola","Kenco","Kib Tea","Kim Kong Kimchi","Kokoa Collection","Kuka","L'OR","La Boulangère","Lactofree","Lavazza","Laverstoke Park","Leerdammer","Liberte","Liberto","Light & Free","Little Dish","Little Freddie","Living Seedful","Living Tenderleaves","Lo Bros","Loch Fyne","London Essence Co.","Love Me Tender","Lovemore","Lucozade","Lurpak","Lye Cross Farm","M&S","Mattessons","Maximuscle","Mcvitie's","Melrose & Morgan","Merchant's Heart","Minor Figures","Modern Baker","Moju","Monin","Mowi","Moy Park","Mr Freed's","Mr Kipling","Mrs Crimble's","Munch Bunch","Murgella","Naked","Natoora","Nature Valley","Naturelly","Natures Aid","Naturya","Nescafe","Nesquik","Nestle","New York Bagel","New York Bakery","Newby Teas","Nexba","Nipper&Co","Nishaan","Nix & Kix","Nocco","Nurishment","O.R.S","Oatly","Ocado","Ocean Spray","Onken","Optimum Nutrition","Orchardworld","Original Beans","Oteas","Oxo","Oykos","Pack'd","Packington","Pagen","Parmareggio","Pasta Evangelists","Pataks","Patteson's","Pellini","Peperami","Pepsi","Petits Filous","PG Tips","Philadelphia","Pieminister","Pip Organic","Pizza Pilgrims","PLENISH","Pomegreat","Potts","President","PretAManger","Promise Gluten Free","Provamel","PUKKA","Pukka Pies","Pukka Teas","Pulsin","Punchy","Purely Organic","Purition","R Whites","Rachel's","Radnor","Ramona's Kitchen","Re Nourish","Rebel Kitchen","Red Bull","Remedy","Ribena","Richmond","Roastworks","Robinsons","Rogers Estate Coffee","Rokit Pods","Rose's","Ruby","Rude Health","Russell's","Sabra","Samosa Co","San Pellegrino","Schar","Schweppes","Seafood & Eat It","Seriously Strong","Sharwood's","Shloer","Slim Fast","Slim-Fast","Soda Folk","SodaStream","Soli","Solo Coffee","Soreen","Soulful","Sound Seafood","Soupologie","Specialite","St Helens Farm","St Michel","St. Ivel","Steve's Leaves","Stonegate","Storm Tea","Sweet Freedom","T2","Taifun","TaikiTea","Tango","Tanpopo","Tassimo","Taylors Of Harrogate","Tea Plus","Teapigs","Teisseire","Tenzing","Tetley","The Black Farmer","The Collective","The Collective Dairy","The Cultured Collective","The Fish Market","The Fresh Pasta Co.","The Heart of Nature","The Polish Bakery","The Spice Tailor","The Vegetarian Butcher","This is not","Thorncroft","Tiana","Tick Tock","Tickler","Tideford","Tims Dairy","Tofoo","Tortuga","Total Greek","Tropicana","Tropicana Plus","Trucillo","Twinings","Ueshima","UFC","UFit","Unearthed","Union Hand-Roasted","Unrooted","Up&Go","Valsoia","Vbites","Vimto","VIOLIFE","Vita Coco","Volcano Coffee Works","Voss","Warburtons","Watts Farm","Whittard","Whitworths","Wholegood","Wild Hibiscus","Willy Chase's","WUNDA","Wunder Workshop","XITE","Yakult","Yarden","Yeo Valley","Yogi Tea","Yorkshire Provender","Yorkshire Tea"],"header":"Brand","minWidth":70,"align":"center","headerStyle":{"background":"light grey"}},{"accessor":"products","name":"products","type":"numeric","cell":["1","1","4","3","2","1","1","6","1","1","2","1","1","1","1","1","1","1","2","1","1","1","4","3","2","1","1","1","1","1","6","1","5","5","1","3","1","3","4","2","1","1","1","1","5","1","1","1","1","1","1","3","1","1","1","1","3","1","1","1","1","1","1","3","1","3","1","1","1","3","1","1","3","1","2","1","2","1","1","5","1","1","5","7","30","1","3","1","4","1","2","1","1","1","1","3","1","1","2","1","1","1","1","1","6","1","1","3","2","1","1","1","3","2","1","2","3","1","1","1","2","2","1","1","2","2","1","1","2","1","1","1","1","5","2","1","2","2","3","2","1","1","1","1","1","1","1","1","2","5","1","1","2","3","1","1","1","2","3","1","2","1","1","6","1","1","1","1","4","1","1","1","1","1","1","1","3","1","1","1","1","3","2","2","1","2","4","6","5","234","1","1","1","1","2","1","1","3","1","1","4","1","4","1","1","1","3","18","1","1","1","1","1","3","1","1","1","2","1","1","1","1","2","2","1","4","43","1","1","1","1","1","2","1","1","1","2","1","1","1","3","1","1","2","4","2","2","1","1","4","1","6","1","1","3","1","1","1","1","1","2","1","1","1","2","2","5","1","1","2","1","1","1","2","1","7","5","1","1","1","1","1","2","1","3","1","1","3","1","2","1","1","1","3","2","2","2","1","2","2","3","3","1","1","1","1","1","1","1","2","3","2","1","2","4","3","4","1","4","1","1","4","1","5","2","1","1","3","1","1","1","2","1","1","2","1","1","1","1","1","1","2","5","1","1","17","2","1","3","5","2","2","1","1","1","1","1","2","2","1","5","1","1","1","4","1","1","1","1","1","1","1","5","1","1","1"],"header":"Products","minWidth":70,"align":"center","headerStyle":{"background":"light grey"}},{"accessor":"avg_price","name":"avg_price","type":"numeric","cell":["3.5","1.2","2.66","3.0","2.2","1.4","1.5","1.63","4.1","4.0","1.7","6.3","2.8","4.9","3.0","2.05","1.75","6.0","2.5","1.35","5.0","1.75","2.5","3.22","3.4","4.5","3.95","3.65","1.61","1.35","4.27","1.85","4.5","2.52","2.9","5.5","2.3","2.02","5.65","4.48","1.25","0.8","2.49","3.0","1.76","4.0","4.45","2.0","1.49","2.1","2.8","2.79","2.25","4.3","3.35","1.55","7.08","2.0","5.0","3.7","3.6","2.8","4.68","3.13","3.25","7.08","1.65","2.75","5.0","2.8","3.2","3.0","3.03","3.95","2.8","2.0","1.62","3.05","7.0","4.03","1.5","2.8","1.55","8.33","7.06","3.2","3.07","2.85","3.62","3.6","7.82","8.25","2.3","2.5","3.3","17.67","2.9","6.0","5.25","8.0","4.95","4.4","1.2","1.4","8.21","3.1","1.4","1.62","1.3","3.0","24.0","1.0","4.33","3.85","3.8","2.95","1.88","8.0","2.1","1.0","4.78","2.45","4.5","2.7","4.25","1.77","16.5","20.0","2.6","3.2","2.3","4.5","2.0","8.55","1.8","1.5","2.75","2.0","3.4","9.37","3.25","3.0","5.0","6.99","3.5","3.5","1.65","2.1","6.3","3.35","5.0","3.0","1.4","3.5","1.5","3.0","2.5","2.75","6.25","2.0","1.7","4.5","4.5","3.53","3.99","4.32","6.0","3.0","3.99","1.3","2.5","14.0","2.7","2.0","2.2","15.0","1.6","2.5","3.2","2.5","1.5","2.0","10.0","9.25","3.05","2.22","1.69","3.54","3.63","3.52","2.85","2.5","1.4","8.0","1.1","2.4","5.0","4.32","3.0","7.0","3.03","5.95","1.82","1.2","1.65","2.99","3.58","3.67","2.0","0.9","8.0","16.0","7.5","2.32","3.0","1.2","1.3","6.0","1.4","6.5","1.1","2.85","2.2","1.0","5.0","1.55","2.4","5.6","1.6","2.0","3.2","3.95","3.55","2.6","2.5","4.25","8.78","1.85","3.15","11.0","1.25","3.45","3.65","1.65","4.55","2.0","3.02","3.0","6.5","3.95","14.5","3.05","3.5","2.5","1.86","4.0","3.0","2.0","16.0","1.8","3.45","3.0","1.35","2.65","13.0","2.5","1.34","3.5","3.0","2.17","1.99","1.3","5.0","2.33","2.5","4.5","1.87","4.75","5.0","2.4","0.9","3.0","5.0","2.2","3.0","3.0","2.0","1.22","3.0","2.17","2.0","2.4","6.49","6.71","3.0","6.0","3.5","12.0","1.75","2.5","4.43","3.0","1.6","1.85","1.5","1.2","1.5","2.8","9.5","2.97","3.55","4.25","25.0","3.65","8.0","3.8","7.74","4.0","5.51","3.8","1.45","2.71","2.65","1.42","3.9","5.45","7.0","2.93","3.25","1.25","2.2","2.62","2.95","3.25","9.99","1.61","4.0","2.8","2.1","2.0","12.0","1.12","3.31","3.0","3.5","2.79","3.62","2.0","2.33","3.52","5.5","2.0","2.75","1.75","2.5","2.8","2.5","2.1","24.3","1.25","1.03","2.75","12.0","1.9","3.21","5.0","2.0","1.9","6.3","1.5","6.0","2.2","1.76","2.4","3.0","5.6"],"header":"Avg Price","minWidth":70,"align":"center","headerStyle":{"background":"light grey"},"style":[{"background":"#C4BAE1"},{"background":"#D0C7EA"},{"background":"#C9BFE4"},{"background":"#C7BDE3"},{"background":"#CBC1E6"},{"background":"#CFC6E9"},{"background":"#CFC5E9"},{"background":"#CEC5E8"},{"background":"#C1B6DF"},{"background":"#C1B7DF"},{"background":"#CEC4E8"},{"background":"#B5A9D7"},{"background":"#C8BEE4"},{"background":"#BCB1DC"},{"background":"#C7BDE3"},{"background":"#CCC2E7"},{"background":"#CDC4E8"},{"background":"#B7ABD8"},{"background":"#C9C0E5"},{"background":"#D0C6E9"},{"background":"#BCB1DC"},{"background":"#CDC4E8"},{"background":"#C9C0E5"},{"background":"#C5BBE2"},{"background":"#C5BAE2"},{"background":"#BFB4DD"},{"background":"#C2B7E0"},{"background":"#C3B9E1"},{"background":"#CEC5E8"},{"background":"#D0C6E9"},{"background":"#C0B5DE"},{"background":"#CDC3E8"},{"background":"#BFB4DD"},{"background":"#C9BFE5"},{"background":"#C7BDE4"},{"background":"#B9AEDA"},{"background":"#CAC1E6"},{"background":"#CCC2E7"},{"background":"#B8ADD9"},{"background":"#BFB4DE"},{"background":"#D0C7EA"},{"background":"#D3CAEC"},{"background":"#C9C0E5"},{"background":"#C7BDE3"},{"background":"#CDC4E8"},{"background":"#C1B7DF"},{"background":"#BFB4DE"},{"background":"#CCC2E7"},{"background":"#CFC5E9"},{"background":"#CCC2E7"},{"background":"#C8BEE4"},{"background":"#C8BEE4"},{"background":"#CBC1E6"},{"background":"#C0B5DE"},{"background":"#C5BBE2"},{"background":"#CEC5E9"},{"background":"#B1A5D4"},{"background":"#CCC2E7"},{"background":"#BCB1DC"},{"background":"#C3B8E0"},{"background":"#C3B9E1"},{"background":"#C8BEE4"},{"background":"#BEB3DD"},{"background":"#C6BCE3"},{"background":"#C5BBE2"},{"background":"#B1A5D4"},{"background":"#CEC5E8"},{"background":"#C8BEE4"},{"background":"#BCB1DC"},{"background":"#C8BEE4"},{"background":"#C6BBE2"},{"background":"#C7BDE3"},{"background":"#C7BCE3"},{"background":"#C2B7E0"},{"background":"#C8BEE4"},{"background":"#CCC2E7"},{"background":"#CEC5E8"},{"background":"#C6BCE3"},{"background":"#B1A5D4"},{"background":"#C1B7DF"},{"background":"#CFC5E9"},{"background":"#C8BEE4"},{"background":"#CEC5E9"},{"background":"#AA9DCF"},{"background":"#B1A5D4"},{"background":"#C6BBE2"},{"background":"#C6BCE3"},{"background":"#C7BDE4"},{"background":"#C3B9E1"},{"background":"#C3B9E1"},{"background":"#ADA0D1"},{"background":"#AA9ECF"},{"background":"#CAC1E6"},{"background":"#C9C0E5"},{"background":"#C5BBE2"},{"background":"#7867AB"},{"background":"#C7BDE4"},{"background":"#B7ABD8"},{"background":"#BBAFDB"},{"background":"#AC9FD0"},{"background":"#BCB1DC"},{"background":"#BFB4DE"},{"background":"#D0C7EA"},{"background":"#CFC6E9"},{"background":"#AB9ECF"},{"background":"#C6BCE3"},{"background":"#CFC6E9"},{"background":"#CEC5E8"},{"background":"#D0C7EA"},{"background":"#C7BDE3"},{"background":"#564193"},{"background":"#D1C8EB"},{"background":"#C0B5DE"},{"background":"#C2B8E0"},{"background":"#C2B8E0"},{"background":"#C7BDE3"},{"background":"#CDC3E7"},{"background":"#AC9FD0"},{"background":"#CCC2E7"},{"background":"#D1C8EB"},{"background":"#BDB2DC"},{"background":"#CAC0E5"},{"background":"#BFB4DD"},{"background":"#C8BEE4"},{"background":"#C0B5DE"},{"background":"#CDC4E8"},{"background":"#7E6DB0"},{"background":"#6B59A3"},{"background":"#C9BFE5"},{"background":"#C6BBE2"},{"background":"#CAC1E6"},{"background":"#BFB4DD"},{"background":"#CCC2E7"},{"background":"#A99CCE"},{"background":"#CDC4E8"},{"background":"#CFC5E9"},{"background":"#C8BEE4"},{"background":"#CCC2E7"},{"background":"#C5BAE2"},{"background":"#A497CB"},{"background":"#C5BBE2"},{"background":"#C7BDE3"},{"background":"#BCB1DC"},{"background":"#B1A5D4"},{"background":"#C4BAE1"},{"background":"#C4BAE1"},{"background":"#CEC5E8"},{"background":"#CCC2E7"},{"background":"#B5A9D7"},{"background":"#C5BBE2"},{"background":"#BCB1DC"},{"background":"#C7BDE3"},{"background":"#CFC6E9"},{"background":"#C4BAE1"},{"background":"#CFC5E9"},{"background":"#C7BDE3"},{"background":"#C9C0E5"},{"background":"#C8BEE4"},{"background":"#B5AAD7"},{"background":"#CCC2E7"},{"background":"#CEC4E8"},{"background":"#BFB4DD"},{"background":"#BFB4DD"},{"background":"#C4B9E1"},{"background":"#C1B7DF"},{"background":"#C0B5DE"},{"background":"#B7ABD8"},{"background":"#C7BDE3"},{"background":"#C1B7DF"},{"background":"#D0C7EA"},{"background":"#C9C0E5"},{"background":"#8C7CB9"},{"background":"#C8BEE4"},{"background":"#CCC2E7"},{"background":"#CBC1E6"},{"background":"#8676B6"},{"background":"#CEC5E8"},{"background":"#C9C0E5"},{"background":"#C6BBE2"},{"background":"#C9C0E5"},{"background":"#CFC5E9"},{"background":"#CCC2E7"},{"background":"#A194C9"},{"background":"#A598CB"},{"background":"#C6BCE3"},{"background":"#CBC1E6"},{"background":"#CEC4E8"},{"background":"#C4B9E1"},{"background":"#C3B9E1"},{"background":"#C4BAE1"},{"background":"#C7BDE4"},{"background":"#C9C0E5"},{"background":"#CFC6E9"},{"background":"#AC9FD0"},{"background":"#D1C8EA"},{"background":"#CAC0E5"},{"background":"#BCB1DC"},{"background":"#C0B5DE"},{"background":"#C7BDE3"},{"background":"#B1A5D4"},{"background":"#C7BCE3"},{"background":"#B7ABD8"},{"background":"#CDC4E8"},{"background":"#D0C7EA"},{"background":"#CEC5E8"},{"background":"#C7BDE3"},{"background":"#C4B9E1"},{"background":"#C3B9E1"},{"background":"#CCC2E7"},{"background":"#D2C9EB"},{"background":"#AC9FD0"},{"background":"#8170B2"},{"background":"#AFA2D2"},{"background":"#CAC1E6"},{"background":"#C7BDE3"},{"background":"#D0C7EA"},{"background":"#D0C7EA"},{"background":"#B7ABD8"},{"background":"#CFC6E9"},{"background":"#B4A8D6"},{"background":"#D1C8EA"},{"background":"#C7BDE4"},{"background":"#CBC1E6"},{"background":"#D1C8EB"},{"background":"#BCB1DC"},{"background":"#CEC5E9"},{"background":"#CAC0E5"},{"background":"#B9ADD9"},{"background":"#CEC5E8"},{"background":"#CCC2E7"},{"background":"#C6BBE2"},{"background":"#C2B7E0"},{"background":"#C4B9E1"},{"background":"#C9BFE5"},{"background":"#C9C0E5"},{"background":"#C0B5DE"},{"background":"#A89BCD"},{"background":"#CDC3E8"},{"background":"#C6BCE3"},{"background":"#9C8EC5"},{"background":"#D0C7EA"},{"background":"#C4BAE1"},{"background":"#C3B9E1"},{"background":"#CEC5E8"},{"background":"#BEB3DD"},{"background":"#CCC2E7"},{"background":"#C7BCE3"},{"background":"#C7BDE3"},{"background":"#B4A8D6"},{"background":"#C2B7E0"},{"background":"#8979B7"},{"background":"#C6BCE3"},{"background":"#C4BAE1"},{"background":"#C9C0E5"},{"background":"#CDC3E7"},{"background":"#C1B7DF"},{"background":"#C7BDE3"},{"background":"#CCC2E7"},{"background":"#8170B2"},{"background":"#CDC4E8"},{"background":"#C4BAE1"},{"background":"#C7BDE3"},{"background":"#D0C6E9"},{"background":"#C9BFE4"},{"background":"#9182BD"},{"background":"#C9C0E5"},{"background":"#D0C6E9"},{"background":"#C4BAE1"},{"background":"#C7BDE3"},{"background":"#CBC1E6"},{"background":"#CCC3E7"},{"background":"#D0C7EA"},{"background":"#BCB1DC"},{"background":"#CAC1E6"},{"background":"#C9C0E5"},{"background":"#BFB4DD"},{"background":"#CDC3E7"},{"background":"#BDB2DC"},{"background":"#BCB1DC"},{"background":"#CAC0E5"},{"background":"#D2C9EB"},{"background":"#C7BDE3"},{"background":"#BCB1DC"},{"background":"#CBC1E6"},{"background":"#C7BDE3"},{"background":"#C7BDE3"},{"background":"#CCC2E7"},{"background":"#D0C7EA"},{"background":"#C7BDE3"},{"background":"#CBC1E6"},{"background":"#CCC2E7"},{"background":"#CAC0E5"},{"background":"#B4A8D6"},{"background":"#B3A7D5"},{"background":"#C7BDE3"},{"background":"#B7ABD8"},{"background":"#C4BAE1"},{"background":"#9688C1"},{"background":"#CDC4E8"},{"background":"#C9C0E5"},{"background":"#BFB4DE"},{"background":"#C7BDE3"},{"background":"#CEC5E8"},{"background":"#CDC3E8"},{"background":"#CFC5E9"},{"background":"#D0C7EA"},{"background":"#CFC5E9"},{"background":"#C8BEE4"},{"background":"#A496CA"},{"background":"#C7BDE3"},{"background":"#C4B9E1"},{"background":"#C0B5DE"},{"background":"#513C90"},{"background":"#C3B9E1"},{"background":"#AC9FD0"},{"background":"#C2B8E0"},{"background":"#ADA1D1"},{"background":"#C1B7DF"},{"background":"#B9AEDA"},{"background":"#C2B8E0"},{"background":"#CFC6E9"},{"background":"#C8BEE4"},{"background":"#C9BFE4"},{"background":"#CFC6E9"},{"background":"#C2B7E0"},{"background":"#BAAEDA"},{"background":"#B1A5D4"},{"background":"#C7BDE3"},{"background":"#C5BBE2"},{"background":"#D0C7EA"},{"background":"#CBC1E6"},{"background":"#C9BFE5"},{"background":"#C7BDE3"},{"background":"#C5BBE2"},{"background":"#A194C9"},{"background":"#CEC5E8"},{"background":"#C1B7DF"},{"background":"#C8BEE4"},{"background":"#CCC2E7"},{"background":"#CCC2E7"},{"background":"#9688C1"},{"background":"#D1C8EA"},{"background":"#C5BBE2"},{"background":"#C7BDE3"},{"background":"#C4BAE1"},{"background":"#C8BEE4"},{"background":"#C3B9E1"},{"background":"#CCC2E7"},{"background":"#CAC1E6"},{"background":"#C4BAE1"},{"background":"#B9AEDA"},{"background":"#CCC2E7"},{"background":"#C8BEE4"},{"background":"#CDC4E8"},{"background":"#C9C0E5"},{"background":"#C8BEE4"},{"background":"#C9C0E5"},{"background":"#CCC2E7"},{"background":"#544092"},{"background":"#D0C7EA"},{"background":"#D1C8EB"},{"background":"#C8BEE4"},{"background":"#9688C1"},{"background":"#CDC3E7"},{"background":"#C6BBE2"},{"background":"#BCB1DC"},{"background":"#CCC2E7"},{"background":"#CDC3E7"},{"background":"#B5A9D7"},{"background":"#CFC5E9"},{"background":"#B7ABD8"},{"background":"#CBC1E6"},{"background":"#CDC4E8"},{"background":"#CAC0E5"},{"background":"#C7BDE3"},{"background":"#B9ADD9"}]},{"accessor":"median_price","name":"median_price","type":"numeric","cell":["3.5","1.2","3.0","2.0","2.2","1.4","1.5","1.73","4.1","4.0","1.7","6.3","2.8","4.9","3.0","2.05","1.75","6.0","2.5","1.35","5.0","1.75","2.5","2.95","3.4","4.5","3.95","3.65","1.61","1.35","4.74","1.85","4.5","2.4","2.9","5.5","2.3","2.0","5.25","4.48","1.25","0.8","2.49","3.0","1.5","4.0","4.45","2.0","1.49","2.1","2.8","2.79","2.25","4.3","3.35","1.55","8.25","2.0","5.0","3.7","3.6","2.8","4.68","3.0","3.25","4.9","1.65","2.75","5.0","2.8","3.2","3.0","3.7","3.95","2.8","2.0","1.62","3.05","7.0","3.75","1.5","2.8","1.45","6.2","4.4","3.2","3.0","2.85","3.5","3.6","7.82","8.25","2.3","2.5","3.3","8.0","2.9","6.0","5.25","8.0","4.95","4.4","1.2","1.4","4.42","3.1","1.4","1.6","1.3","3.0","24.0","1.0","3.0","3.85","3.8","2.95","2.05","8.0","2.1","1.0","4.78","2.45","4.5","2.7","4.25","1.77","16.5","20.0","2.6","3.2","2.3","4.5","2.0","7.95","1.8","1.5","2.75","2.0","3.5","9.37","3.25","3.0","5.0","6.99","3.5","3.5","1.65","2.1","6.3","3.3","5.0","3.0","1.4","3.5","1.5","3.0","2.5","2.75","6.5","2.0","1.7","4.5","4.5","3.7","3.99","4.32","6.0","3.0","3.22","1.3","2.5","14.0","2.7","2.0","2.2","15.0","1.87","2.5","3.2","2.5","1.5","2.0","10.0","9.25","3.05","2.22","1.25","3.25","3.53","2.65","2.85","2.5","1.4","8.0","1.1","2.4","5.0","4.66","3.0","7.0","3.1","5.95","1.73","1.2","1.65","2.99","4.0","3.5","2.0","0.9","8.0","16.0","7.5","2.6","3.0","1.2","1.3","6.0","1.4","6.5","1.1","2.85","2.2","1.0","5.0","1.6","2.0","5.6","1.6","2.0","3.2","3.95","3.55","2.6","2.5","4.25","8.78","1.85","3.15","11.0","1.25","3.45","3.65","1.65","3.3","2.0","3.02","3.0","6.5","3.95","14.5","3.14","3.5","2.5","1.87","4.0","3.0","2.0","16.0","1.8","3.45","3.0","1.35","2.65","13.0","2.5","1.5","3.5","3.0","2.17","1.99","1.3","5.0","2.33","2.5","4.5","1.85","4.75","5.0","2.4","0.9","3.0","5.0","2.2","3.0","3.0","2.0","1.55","3.0","2.17","2.0","2.4","6.49","9.01","3.0","6.0","3.5","12.0","1.75","2.5","4.42","3.0","1.6","1.85","1.5","1.2","1.5","2.8","9.5","2.97","3.5","4.25","25.0","3.65","6.6","3.7","7.68","4.0","4.07","3.8","1.45","2.35","2.65","1.7","3.9","5.45","7.0","3.0","3.25","1.25","2.2","2.62","2.95","3.25","9.99","1.61","4.0","2.8","2.1","2.0","12.0","1.12","2.75","3.0","3.5","2.7","3.62","2.0","2.0","3.65","5.5","2.0","2.75","1.75","2.5","2.8","2.5","2.1","24.3","1.25","1.05","2.75","12.0","1.9","3.15","5.0","2.0","1.9","6.3","1.5","6.0","2.2","1.8","2.4","3.0","5.6"],"header":"Median Price","minWidth":70,"align":"center","headerStyle":{"background":"light grey"}},{"accessor":"max_price","name":"max_price","type":"numeric","cell":["3.5","1.2","3.0","5.5","2.2","1.4","1.5","2.0","4.1","4.0","1.7","6.3","2.8","4.9","3.0","2.05","1.75","6.0","2.5","1.35","5.0","1.75","2.5","3.75","3.95","4.5","3.95","3.65","1.61","1.35","5.7","1.85","5.0","3.0","2.9","5.5","2.3","2.1","7.5","5.0","1.25","0.8","2.49","3.0","3.55","4.0","4.45","2.0","1.49","2.1","2.8","2.79","2.25","4.3","3.35","1.55","8.5","2.0","5.0","3.7","3.6","2.8","4.68","4.6","3.25","13.45","1.65","2.75","5.0","2.8","3.2","3.0","3.7","3.95","3.6","2.0","2.0","3.05","7.0","5.75","1.5","2.8","2.25","20.0","30.0","3.2","3.5","2.85","4.0","3.6","10.99","8.25","2.3","2.5","3.3","40.0","2.9","6.0","6.0","8.0","4.95","4.4","1.2","1.4","18.25","3.1","1.4","1.75","1.3","3.0","24.0","1.0","7.0","4.2","3.8","3.9","2.1","8.0","2.1","1.0","5.0","2.5","4.5","2.7","4.25","1.8","16.5","20.0","2.6","3.2","2.3","4.5","2.0","9.95","1.8","1.5","3.0","2.0","4.0","17.49","3.25","3.0","5.0","6.99","3.5","3.5","1.65","2.1","6.5","3.8","5.0","3.0","1.45","3.5","1.5","3.0","2.5","2.75","8.75","2.0","1.7","4.5","4.5","5.0","3.99","4.32","6.0","3.0","6.35","1.3","2.5","14.0","2.7","2.0","2.2","15.0","1.87","2.5","3.2","2.5","1.5","2.0","13.0","15.0","3.05","2.25","3.0","7.0","5.25","25.0","2.85","2.5","1.4","8.0","1.1","2.4","5.0","4.66","3.0","7.0","4.0","5.95","2.35","1.2","1.65","2.99","4.0","5.0","2.0","0.9","8.0","16.0","7.5","3.35","3.0","1.2","1.3","6.0","1.4","6.5","1.1","2.85","2.2","1.0","5.0","1.8","8.99","5.6","1.6","2.0","3.2","3.95","3.55","2.6","2.5","4.25","12.96","1.85","3.15","11.0","1.25","3.45","3.65","2.0","9.5","2.0","3.3","3.0","6.5","4.0","14.5","3.75","3.5","2.5","2.1","4.0","3.0","2.0","16.0","1.8","3.45","3.0","1.35","2.65","13.0","3.65","2.0","3.5","3.0","2.17","1.99","1.3","5.0","2.65","2.5","4.5","2.5","4.75","5.0","2.4","0.9","3.0","5.0","2.2","3.0","3.0","2.0","1.6","3.0","2.75","2.0","2.4","6.49","9.01","3.0","8.0","3.5","12.0","2.0","2.5","4.53","3.0","1.6","1.85","1.5","1.2","1.5","2.8","9.5","2.97","3.65","5.0","25.0","3.65","15.5","4.0","11.5","4.0","12.0","3.8","1.45","4.0","2.65","2.2","3.9","5.45","7.0","3.0","3.25","1.25","2.2","2.75","2.95","3.25","17.99","1.61","4.0","2.8","2.1","2.0","12.0","1.15","4.4","3.0","3.5","4.0","4.0","2.0","3.0","3.8","5.5","2.0","2.75","1.75","2.5","2.8","2.5","2.5","27.0","1.25","1.1","2.75","12.0","1.9","4.5","5.0","2.0","1.9","6.3","1.5","6.0","2.2","2.75","2.4","3.0","5.6"],"header":"Max Price","minWidth":70,"align":"center","headerStyle":{"background":"light grey"}},{"accessor":"min_price","name":"min_price","type":"numeric","cell":["3.5","1.2","1.65","1.5","2.2","1.4","1.5","0.85","4.1","4.0","1.7","6.3","2.8","4.9","3.0","2.05","1.75","6.0","2.5","1.35","5.0","1.75","2.5","2.95","2.85","4.5","3.95","3.65","1.61","1.35","2.35","1.85","4.0","2.4","2.9","5.5","2.3","1.95","4.6","3.96","1.25","0.8","2.49","3.0","0.25","4.0","4.45","2.0","1.49","2.1","2.8","2.79","2.25","4.3","3.35","1.55","4.5","2.0","5.0","3.7","3.6","2.8","4.68","1.8","3.25","2.9","1.65","2.75","5.0","2.8","3.2","3.0","1.7","3.95","2.0","2.0","1.25","3.05","7.0","3.45","1.5","2.8","1.25","3.5","1.2","3.2","2.7","2.85","3.5","3.6","4.65","8.25","2.3","2.5","3.3","5.0","2.9","6.0","4.5","8.0","4.95","4.4","1.2","1.4","1.95","3.1","1.4","1.5","1.3","3.0","24.0","1.0","3.0","3.5","3.8","2.0","1.5","8.0","2.1","1.0","4.55","2.4","4.5","2.7","4.25","1.75","16.5","20.0","2.6","3.2","2.3","4.5","2.0","7.95","1.8","1.5","2.5","2.0","2.7","1.25","3.25","3.0","5.0","6.99","3.5","3.5","1.65","2.1","6.1","2.75","5.0","3.0","1.35","3.5","1.5","3.0","2.5","2.75","3.5","2.0","1.7","4.5","4.5","1.0","3.99","4.32","6.0","3.0","3.15","1.3","2.5","14.0","2.7","2.0","2.2","15.0","1.05","2.5","3.2","2.5","1.5","2.0","7.0","3.5","3.05","2.2","1.25","2.25","2.6","0.6","2.85","2.5","1.4","8.0","1.1","2.4","5.0","3.63","3.0","7.0","1.93","5.95","1.5","1.2","1.65","2.99","2.75","0.86","2.0","0.9","8.0","16.0","7.5","1.0","3.0","1.2","1.3","6.0","1.4","6.5","1.1","2.85","2.2","1.0","5.0","1.2","0.69","5.6","1.6","2.0","3.2","3.95","3.55","2.6","2.5","4.25","4.6","1.85","3.15","11.0","1.25","3.45","3.65","1.3","2.1","2.0","2.75","3.0","6.5","3.9","14.5","2.0","3.5","2.5","1.6","4.0","3.0","2.0","16.0","1.8","3.45","3.0","1.35","2.65","13.0","1.35","0.75","3.5","3.0","2.17","1.99","1.3","5.0","2.0","2.5","4.5","1.25","4.75","5.0","2.4","0.9","3.0","5.0","2.2","3.0","3.0","2.0","0.5","3.0","1.6","2.0","2.4","6.49","2.1","3.0","4.0","3.5","12.0","1.5","2.5","4.35","3.0","1.6","1.85","1.5","1.2","1.5","2.8","9.5","2.97","3.5","3.5","25.0","3.65","3.3","3.7","4.1","4.0","1.9","3.8","1.45","2.15","2.65","0.75","3.9","5.45","7.0","2.8","3.25","1.25","2.2","2.5","2.95","3.25","2.0","1.61","4.0","2.8","2.1","2.0","12.0","1.1","2.5","3.0","3.5","1.7","3.25","2.0","2.0","3.25","5.5","2.0","2.75","1.75","2.5","2.8","2.5","1.7","21.6","1.25","0.95","2.75","12.0","1.9","2.05","5.0","2.0","1.9","6.3","1.5","6.0","2.2","0.6","2.4","3.0","5.6"],"header":"Min Price","minWidth":70,"align":"center","headerStyle":{"background":"light grey"}}],"defaultSortDesc":true,"defaultSorted":[{"id":"products","desc":true},{"id":"avg_price","desc":true}],"defaultPageSize":20,"paginationType":"numbers","showPageInfo":true,"minRows":1,"highlight":true,"bordered":true,"striped":true,"dataKey":"659c91da045ef8831ba33bd0be0971a6","key":"659c91da045ef8831ba33bd0be0971a6"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
```


