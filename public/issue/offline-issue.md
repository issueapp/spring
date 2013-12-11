Offline Issue structure
---

- holiday/
  - assets/                         # images, javascripts, stylesheets
    - issue.js                      # Compiled js
    - issue.css                     # Compiled css
    - javascripts/
    - stylesheets/
    - fonts/                        # Custom font
    - images/
      - 
      1
      
  - /index.html                     # cover
  - /items/toc.html                 # table of content
  - /items/1-dare-to-dream.html     # table of content
  - /issue.json  # meta data


- holiday.issue (universal image max-width or max-height 1024)
- holiday.mobile.issue (image <640)
- holiday.tablet.issue (image < 1024)
- holiday.retina.issue (image < 2048)

Image
---



JS Dependency
---

- zepto
- underscore
- backbone

fastclick

app/core
app/layout
app/issue
app/notification
app/user (maybe)
app/track (merge with app/notification)

offline overlay (later on)
