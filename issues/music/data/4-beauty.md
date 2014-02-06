---

    category: beauty
    image_url: assets/4-beauty/cover.jpg
    
    custom_class: five-shades
    
    layout:
      type: three-column
      image_align: left

    products:

      - title: Chanel Illusion d’Ombre Long-Wear Eyeshadow in Fatal
        image_url: assets/4-beauty/cover-product-1.png
        url: "#1"
        action: false
        
      - title: Yves Saint Laurent Volume Effet Faux Cils Mascara in High Density Black
        image_url: assets/4-beauty/cover-product-2.png
        url: "#2"
        action: false
        
      - title: "M.A.C Mineralize Skinfinish in Soft and Gentle"
        image_url: assets/4-beauty/cover-product-3.png
        url: "#3"
        action: false

      - title:  M.A.C Lipstick in Pink Plaid
        image_url: assets/4-beauty/cover-product-4.png
        url: "#4"
        action: false

      - title: M.A.C Lipstick in Lustering
        image_url: assets/4-beauty/cover-product-5.png
        url: "#5"
        action: false

---

<style>
  /*  Replace page heading with outline heading (change background url or height if needed) */
  article[data-page="4-beauty"] #uncovered {
    position: absolute;
    top: 0;
    right: 0;
    width: 120px;
  }

  article[data-page="4-beauty"] .product-set {
    margin: -35% 0 -20%;
    
    background-image: url('assets/4-beauty/product-bg.png');
    background-position: center;
    background-size: 110%;
  }

  article[data-page="4-beauty"] .product-set li {
/*    height: auto;*/
  }

  article[data-page="4-beauty"] .product-set li img {
    visibility: hidden;
  }

  article[data-page="4-beauty"] .product-set .hotspot {
    display: block;
  }
  
  article[data-page="4-beauty"] .product-set li:nth-child(1) .hotspot {
    margin-top: 75px;
  }

  article[data-page="4-beauty"] .product-set li:nth-child(2) .hotspot {
    margin-top: -80px;
  }

  article[data-page="4-beauty"] .product-set li:nth-child(3) .hotspot {
    margin-top: 0;
  }

  article[data-page="4-beauty"] .product-set li:nth-child(4) .hotspot {
    margin-top: -130px;
  }

  article[data-page="4-beauty"] .product-set li:nth-child(5) {
    margin-top: -12%;
    margin-left: 50%;
  }

  article[data-page="4-beauty"] .product-set li:nth-child(5) .hotspot {
    margin-top: -80px;
  }

  @media only screen and (min-width: 768px) {
    article[data-page="4-beauty"] #uncovered {
      position: absolute;
      right: initial;
      left: 0;
      width: 230px;
    }
  }

  @media only screen and (min-width: 768px) and (orientation: landscape) {
    article[data-page="4-beauty"] .product-set li:nth-child(5) {
/*      margin-left: 142px;
*/    }
    
  }

  @media only screen and (min-width: 768px) and (orientation: portrait) {
    article[data-page="4-beauty"].cover-left .content {
      height: auto;
    }
    
    article[data-page="4-beauty"] .content {
      width: 100%;
    }
    
    article[data-page="4-beauty"] .cover-area {
      height: 50%;
      width: 100%;
    }
    
    article[data-page="4-beauty"] .product-set {
      margin-top: -10%;
      width: 40%;
      float: left;
    }
    
    article[data-page="4-beauty"] .body {
      margin-left: 10%;
      width: 50%;
      float: left;
    }

    /*    article[data-page="4-beauty"] #uncovered-description {
          position: absolute;
          bottom: 30px;
          left: 15%;
          margin-bottom: 20px;
          padding: 20px;
          width: 60%;
        }*/
    article[data-page="4-beauty"] .product-set li:nth-child(5) {
      margin-left: 96px;
    }

    article[data-page="4-beauty"] .product-set li:nth-child(5) .hotspot {
      margin-top: -34px;
    }
  }
</style>

<img id="uncovered" src="assets/4-beauty/uncovered.png" alt="">

<p id="uncovered-description">
  Want to know the secrets to
  creating christina perri’s
  stunning look? Then you’ve come
  to the right place! We caught
  up with christina’s go-to beauty
  maestro giavonna brascia who
  gave us the lowdown on achieving
  cp’s  old-hollywood-meets-
  rock’n’roll glow in just a few
  easy steps! We know, we know...
  we’re just too good to you!
</p>
