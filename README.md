Spring - HTML5 Publishing
=============
A minimalistic framework for HTML5 based publishing, Simple HTML5 written with HTML, Javascript.

Features
---


  - Cover screen
  - Section page 
  - Toolbar
  - Swipe view where user can flick through different sections pages with swipe to view a continuously
  - Pagination
  
  - Responsive layout that scales automatically for iPhone, iPad depends on resolution and orientation
  - Menu for navigation
  
UI Design

 - Icon, startup screen
 - buttons
 - pop over dialog view for collect product and share
 - modal view  

Dependencies
---

  - zepto
  - pjax
  - scrollability
  - hammer.js (multi touch)

Structure
---

  - toolbar header
  - page

Grid system
---


This is using a [1000px grid system](http://elliotjaystocks.com/blog/a-better-photoshop-grid-for-responsive-web-design/) for layout. It makes percentage/pixel based conversation very simple.

  
![1000px grid](http://elliotjaystocks.com/assets/4f199548dabe9d54ad00d558/articleresponsivegrid01.jpg)


Layout & Rendering
---


Basic part of the rendering engine is based on the grid system listed above with 3 primary item layouts 

CSS classes, combination of these should be able to build rather complex layout for different devices.

 - Width: full, half, third, third-2 (two third)
 - Height: v-half, v-third, v-third2 (two third)
 - Columns: col, col.half, col.third, col.third-2

Row

Column

### Markup

    body
      nav#menu
        
      div[role=main]
        
        #sections
          header.toolbar
          div.pages
            div.page
            ...
        
        #content
          header.toolbar
          div.pages
            div.page
            ...
      
### Web layout

![web layout](http://cl.ly/3N223u3F0G380U1j322U/web-layout.png)

Example

    .row
      .col.half
        .item.v-half
        .item.v-half
        
      .col.half
        .item

### Ipad

Landscape view has similar dimension like a web view, except the primary rendering type should be split view, combining with couple of variations.

![ipad layout](http://cl.ly/273z072q0Y32001b0f17/ipad-landscape.png)

Example

    .row
      .col.half
        .item.v-third
        
      .col.half
        .item.v-third-2


Combining different width/height classes on col to achieve a more complex layout

![ipad layout](http://cl.ly/033G0u0D0c1W2Q360G21/ipad-landscape-2.png)

Portrait view has mostly vertically split views

![ipad layout](http://cl.ly/2L301w1j3D442L272u3m/Ipad%20portraite.png)

    .row.v-half
      .item.v-third
    
    .row.v-half
      .col.half
        .item
        
      .col.half
        .item.v-half
        .item.v-half

Item Style
---

Scaling upon screen size

demo: http://www.spookandpuff.com/examples/dynamicTextSize.html
Stackoverflow: http://stackoverflow.com/questions/5358183/is-it-possible-to-dynamically-scale-text-size-based-on-browser-width

Image centering

Stackoverflow: http://stackoverflow.com/questions/489340/how-do-i-vertically-align-text-next-to-an-image-with-css
Demo: http://jsfiddle.net/458BN/23/


EM and PX conversion in SASS
https://forrst.com/posts/SASS_px_to_em_and_em_to_px-JAd

Split

Dynamic paging
---

In order to create dynamic paging that is response and support horizontal scrolling, we need to create pages

 - Load 10 products per page load
 - Push into a local buffer
 - Lazy load additional page via ajax


Scrolling
---

Pagination
---

Speed, simplicity, responsive

Unlike treesaver which will cut off contents, This pagination will put items into pages.

    .pages
    
      .row
        .item.full
    
      .row
        .item.half
        .item.half
      
      .row
        .item.third
        .item.third
        .item.third
      
      .row
        .col.half
          .item-1
          .item-2
          .item-3

        .col.half
          .item
      
        .item
      .row
    
    page count
    pagination bar


Stylesheet
===

Here is the overall structure of our css files.

application.css
=====

------ Compass
------ Reset

html, body

------ layout - No style/colours

  structure (menu/main)
  grid (row/col)
  
------ ui
------ ui/menu
------ ui/toolbar
------ ui/forms
------ ui/buttons
------ ui/popover
------ ui/modal

------ item.scss
/* (core content and records) */

  .item 
    title
    image
    date
    desc
    author

  .article.item
  .product.item
  .collection.item
    
------ page
  .paging
  
  .page
  
  
  .product.page
    .panel
    
      h1.title
      a.brand
      span.price
      span.comparison-price
      button.purchase
      
      tabs.description
        a.user
          img

      
      tabs.comments
      tabs.related
      
  
  .article.page

// Static pages

  .signup
  .welcome

------ mobile
  
  .page {
    320
  }
  
  @media only screen and orientation {
    480
  }


------- ipad