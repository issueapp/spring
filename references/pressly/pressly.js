
(function () {
    var b = this.Pressly = {};
    b.version = "1.2.18";
    b.Core = function (a, c) {
        c = c ? c : {};
        this.defaults = this.defaults ? this.defaults : {};
        c.disableGestures || _.extend(this, new b.Gesture);
        _.extend(this, {
            profile: b.profile
        });
        this.element = $(a).get(0);
        this.options = _.extend(this.defaults, c);
        this.issue = this.options.issue ? this.options.issue : void 0;
        window.supportedUserAgents = this.options.userAgents ? this.options.userAgents : window.supportedUserAgents;
        this.getViewport = function () {
            var a = _(document.location.search.substr(1).split("&")).map(function (a) {
                return {
                    param: a.split("=")[0],
                    value: a.split("=")[1]
                }
            }),
                c = _(a).detect(function (a) {
                    return a.param === "width"
                }),
                a = _(a).detect(function (a) {
                    return a.param === "height"
                });
            return {
                width: parseInt(c !== void 0 ? c.value : window.innerWidth, 10),
                height: parseInt(a !== void 0 ? a.value : window.innerHeight, 10),
                toString: function () {
                    return this.width + "x" + this.height
                }
            }
        };
        this.isDebug = function () {
            return window.location.search.substr(1).indexOf("debug=true") > -1
        };
        this.updateViewportState = function () {
            this.viewportState = this.getViewport().toString()
        };
        this.hasViewportMismatch = function () {
            return this.viewportState !== this.getViewport().toString()
        };
        this.init()
    };
    b.destroy = function () {
        window.issue.destroy();
        for (var a in b) if ((typeof b[a] === "function" || typeof b[a] === "object") && typeof b[a].destroy === "function") console.log("Calling class-wide destroy"), b[a].destroy()
    };
    document.body.addEventListener("touchmove", function (a) {
        a.preventDefault()
    }, false);
    var a = _(document.location.search.substr(1).split("&")).map(function (a) {
        return {
            param: a.split("=")[0],
            value: a.split("=")[1]
        }
    }),
        c = _(a).detect(function (a) {
            return a.param == "debug"
        });
    $(window).scroll(function () {
        c && c.value == "true" || window.issue && window.issue.options && !window.issue.options.scrollLock || $(window).scrollTop() > 1 && $(window).scrollTop(1)
    });
    $(window).scrollTop(1)
})();
(function () {
    function b(a) {
        return navigator.userAgent.search(a) !== -1
    }
    Pressly.Device = {
        devices: [{
            name: "Apple iPad iOS 4.3+",
            pattern: /iPad.+OS\s4_3/,
            type: "tablet",
            list: "white",
            navTracking: true,
            adTracking: true
        }, {
            name: "Apple iPad iOS 5+",
            pattern: /iPad.+OS\s5/,
            type: "tablet",
            list: "white",
            navTracking: true,
            adTracking: true
        }, {
            name: "Samsung Galaxy Tab 10 GT-P7510",
            pattern: /Android.+GT/,
            type: "tablet",
            list: "white",
            navTracking: true,
            adTracking: true
        }, {
            name: "Kindle Fire",
            pattern: /Silk.+AppleWebKit/,
            type: "tablet",
            list: "grey",
            navTracking: true,
            adTracking: true
        }, {
            name: "RIM Playbook",
            pattern: /PlayBook.+RIM\sTablet.+AppleWebKit/,
            type: "tablet",
            list: "grey",
            navTracking: true,
            adTracking: true
        }, {
            name: "Apple iPad iOS 4.2",
            pattern: /iPad.+OS\s4_2/,
            type: "tablet",
            list: "grey",
            navTracking: true,
            adTracking: false
        }, {
            name: "HP Touchpad",
            pattern: /hp\-tablet.+hpwOS.+AppleWebKit/,
            type: "tablet",
            list: "grey",
            navTracking: true,
            adTracking: true
        }, {
            name: "Motorola Xoom",
            pattern: /Xoom.+AppleWebKit/,
            type: "tablet",
            list: "grey",
            navTracking: true,
            adTracking: true
        }, {
            name: "Apple iPhone 4+",
            pattern: /iPhone.+OS\s5/,
            type: "phone",
            list: "grey",
            navTracking: true,
            adTracking: true
        }, {
            name: "Apple iPhone Lesser",
            pattern: /iPhone.+OS\s(3|4)/,
            type: "phone",
            list: "black",
            navTracking: false,
            adTracking: false
        }, {
            name: "Windows Phone",
            pattern: /IEMobile/,
            type: "phone",
            list: "black",
            navTracking: false,
            adTracking: false
        }, {
            name: "BlackBerry Phone",
            pattern: /BlackBerry.+Mobile\sSafari/,
            type: "phone",
            list: "black",
            navTracking: false,
            adTracking: false
        }, {
            name: "Android Phone",
            pattern: /Android.+Mobile\sSafari/,
            type: "phone",
            list: "black",
            navTracking: false,
            adTracking: false
        }, {
            name: "Nokia Phone",
            pattern: /Nokia.+Mobile\sSafari/,
            type: "phone",
            list: "black",
            navTracking: false,
            adTracking: false
        }],
        isNamed: function (a) {
            for (var c = 0; c < this.devices.length; c++) if (b(this.devices[c].pattern)) return this.devices[c].name === a;
            return false
        },
        isTablet: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].type === "tablet";
            return false
        },
        isPhone: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].type === "phone";
            return false
        },
        isPhantom: function () {
            return window.phantom || window.location.href.indexOf("phantom") > -1
        },
        isSupported: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].list === "white";
            return false
        },
        isGreyListed: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].list === "grey";
            return false
        },
        isBlackListed: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].list === "black";
            return false
        },
        shouldTrackNav: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].navTracking === true;
            return false
        },
        shouldTrackAds: function () {
            for (var a = 0; a < this.devices.length; a++) if (b(this.devices[a].pattern)) return this.devices[a].adTracking === true;
            return false
        },
        isWebView: function () {
            return b("iPad") && !b("Safari") && !this.isStandAlone()
        },
        isStandAlone: function () {
            return "standalone" in navigator && navigator.standalone ? true : false
        }
    }
})();
(function () {
    Pressly.track = function () {};
    Pressly.Tracking = {};
    Pressly.Tracking.trackers = {};
    Pressly.Tracking.trackers.Tracker = function () {};
    Pressly.Tracking.trackers.Tracker.prototype = {
        trackerObject: void 0,
        trackerCustomVarRoutes: void 0,
        disableAdPageHinting: false,
        useArticleTitlesAsPagenames: false,
        beforeTrack: void 0,
        allowedCustomEvents: {
            "nav-section": true,
            "font-size": true,
            modal: true,
            share: true,
            "exit-link": true,
            "ad-impression": true
        },
        init: function (b) {
            this.options = b;
            this.trackCustomEvents = b.trackCustomEvents === true;
            if (b.disableAdPageHinting === true) this.disableAdPageHinting = true;
            if (b.useArticleTitlesAsPagenames === true) this.useArticleTitlesAsPagenames = true;
            if (typeof b.onBeforeTrack === "function") this.beforeTrack = b.onBeforeTrack;
            this.trackerObject = b.trackerObject;
            this.trackerCustomVarRoutes = b.customVarRoutes
        }
    };
    Pressly.Tracking = _.extend(Pressly.Tracking, {
        getPresslyCustomVariable: function (b, a, c, e) {
            if (_(["adLocation", "adSize", "trackingString"]).indexOf(b) > -1 || b.indexOf("client-") === 0) return e[b];
            else if (b === "iOSVersion") {
                var f,
                b = navigator.userAgent;
                if (b.indexOf("iPad") > -1 || b.indexOf("iPhone") > -1) try {
                    f = b.split("(")[1].split(")")[0];
                    var h = f.split(";");
                    h.pop();
                    f = h.join(";")
                } catch (j) {} else f = "";
                return f
            }
        },
        getPaginationTrackingStringSuffix: function (b, a) {
            var c = Pressly.Tracking.getPaginationParameters(b, a);
            return c ? "/pg_" + c.page + "_of_" + c.length : ""
        },
        getPaginationParameters: function (b) {
            return b[0] === "page" && b[1] === "navigate" && typeof b[4] === "number" && typeof b[5] === "number" ? {
                page: b[4],
                length: b[5]
            } : null
        },
        init: function (b) {
            var a = [],
                c = function (c) {
                    for (var b in Pressly.Tracking.trackers) b.toLowerCase() === c.provider.toLowerCase() && a.push(new Pressly.Tracking.trackers[b](c))
                };
            b.provider === "multiple" ? _(b.trackers).each(c) : c(b);
            Pressly.track = function (c, b) {
                if (window.phantom !== true && (!Pressly.Test || Pressly.Test && !Pressly.Test.testing())) {
                    if (document.location.search.indexOf("trackoverride=true") > -1 === false && b) {
                        if (Pressly.Device.shouldTrackNav() === false && b.ad !== true) return;
                        if (Pressly.Device.shouldTrackAds() === false && b.ad === true) return
                    }
                    _(a).each(function (a) {
                        a.track(c,
                        b)
                    })
                }
            }
        }
    })
})();
(function () {
    Pressly.Tracking.trackers.Mixpanel = function (b) {
        this.init(b);
        window.mpq = [];
        mpq.push(["init", b.token]);
        (function () {
            var a, c, b;
            a = document.createElement("script");
            a.type = "text/javascript";
            a.async = true;
            a.src = (document.location.protocol === "https:" ? "https:" : "http:") + "//api.mixpanel.com/site_media/js/api/mixpanel.js";
            c = document.getElementsByTagName("script")[0];
            c.parentNode.insertBefore(a, c);
            a = function (a) {
                return function () {
                    mpq.push([a].concat(Array.prototype.slice.call(arguments, 0)))
                }
            };
            c = "init,track,track_links,track_forms,register,register_once,identify,name_tag,set_config".split(",");
            for (b = 0; b < c.length; b++) mpq[c[b]] = a(c[b])
        })()
    };
    _.extend(Pressly.Tracking.trackers.Mixpanel.prototype, Pressly.Tracking.trackers.Tracker.prototype, {
        trackCustomEvent: function (b) {
            if (this.allowedCustomEvents[b[1]] === true) {
                var a = b[0] + "-" + b[1],
                    c;
                b[1] === "share" ? c = {
                    "share type": b[3],
                    "item id": b[4]
                } : b[1] === "exit-link" ? c = {
                    url: b[2]
                } : b[1] === "font-size" ? c = {
                    "font size": b[3],
                    "article id": b[4]
                } : b[1] === "ad-impression" ? (c = b[3].context, c = {
                    "context type": c.contextType,
                    "context id": c.contextId,
                    src: b[3].src
                }) : b[1] === "nav-section" && (b = window.issue.router.manifest.get(b[3]), c = {}, c["section id"] = b.type === "section" || b.selector === "section" ? b.id : b.sectionId);
                mpq.track(a, c)
            }
        },
        track: function (b, a) {
            var c = {}, e;
            if (this.trackerCustomVarRoutes && a) for (e in this.trackerCustomVarRoutes) if (this.trackerCustomVarRoutes.hasOwnProperty(e)) {
                var f = Pressly.Tracking.getPresslyCustomVariable(e, this.options, b, a);
                typeof f != "undefined" && (c[this.trackerCustomVarRoutes[e].name] = f)
            }
            if (b[0] === "video") e = {
                play: "video start",
                resume: "video resume",
                pause: "video pause",
                ended: "video end"
            }[b[1]], f = b[5], c.position = b[4], c.duration = f, c.section = a.sectionId, c["video id"] = a.trackingString, typeof e === "string" && mpq.track(e, c);
            else if (b[0] === "ui-event") this.trackCustomEvent(b, a);
            else {
                e = a.selector === ".gallery" || a.type === "gallery";
                if ((f = a.selector === ".article" || a.type === "article") || e) {
                    f = f ? "article" : "gallery";
                    e = f + " page view";
                    var h = Pressly.Tracking.getPaginationParameters(b, a);
                    h ? (c["page index"] = h.page, c["page count"] = h.length) : c["page index"] = 1;
                    c.title = a.title;
                    window.issue.router.manifest.get(a.pageId);
                    c[f + " id"] = a.id;
                    c.trackingString = a.trackingString;
                    c["parent page id"] = a.pageId
                } else e = "page swipe", c["has ad"] = a.hasAd === true, c["page id"] = a.id;
                mpq.track(e, c)
            }
        }
    })
})();
(function () {
    Pressly.Tracking.trackers.Omniture = function (b) {
        this.init(b);
        if (typeof b.s_gs_Account === "string") this.s_gs_Account = b.s_gs_Account
    };
    _.extend(Pressly.Tracking.trackers.Omniture.prototype, Pressly.Tracking.trackers.Tracker.prototype, {
        initOmnitureMediaModule: false,
        deferredTrackerInit: void 0,
        s_gs_Account: void 0,
        track: function (b, a) {
            if (!a || !(a.ad === true && this.disableAdPageHinting === true)) typeof this.s_gs_Account === "string" && a ? this.sgsTrack(b, a) : b[0] === "ui-event" ? this.trackCustomEvent(b, a) : this.sTrack(b,
            a)
        },
        sgsTrack: function (b, a) {
            var c;
            c = a.trackingString;
            if (a.hasAd === true && this.disableAdPageHinting === true) c = a.adlessTrackingString;
            c += Pressly.Tracking.getPaginationTrackingStringSuffix(b, a);
            if (this.useArticleTitlesAsPagenames === true && a.selector === ".article" && typeof a.title === "string" && a.title.length > 0) c = a.title;
            s_pageName = c;
            s_channel = a.sectionId;
            typeof this.beforeTrack === "function" && this.beforeTrack(c, a, this.trackerObject);
            this.trackerObject(this.s_gs_Account)
        },
        sTrack: function (b, a) {
            this.initializeOmnitureMediaModule({
                Media: {
                    trackWhilePlaying: true,
                    autoTrack: false,
                    playerName: "Pressly",
                    trackMilestones: "0,25,50,75,100"
                }
            });
            var c;
            this.trackerObject.channel = a.sectionId;
            if (b[0] === "video") this.trackerObject.pageName = a.trackingString, this.trackVideoEvent(b, a);
            else {
                if (this.trackerCustomVarRoutes) for (c in this.trackerCustomVarRoutes) this.trackerCustomVarRoutes.hasOwnProperty(c) && (this.trackerObject[this.trackerCustomVarRoutes[c]] = Pressly.Tracking.getPresslyCustomVariable(c, this.options, b, a));
                c = a.trackingString;
                if (a.hasAd === true && this.disableAdPageHinting === true) c = a.adlessTrackingString;
                this.trackerObject.pageName = c + Pressly.Tracking.getPaginationTrackingStringSuffix(b, a);
                if (this.useArticleTitlesAsPagenames === true && a.selector === ".article" && typeof a.title === "string" && a.title.length > 0) this.trackerObject.pageName = a.title;
                typeof this.beforeTrack === "function" && this.beforeTrack(c, a, this.trackerObject);
                (c = this.trackerObject.t()) && document.write(c);
                if (typeof this.deferredTrackerInit === "function") this.deferredTrackerInit(), this.deferredTrackerInit = void 0
            }
        },
        trackVideoEvent: function (b,
        a) {
            if (this.trackerObject.Media && typeof this.trackerObject.Media.open === "function" && typeof this.trackerObject.Media.play === "function" && typeof this.trackerObject.Media.stop === "function" && typeof this.trackerObject.Media.close === "function") if (b[1] == "play") this.trackerObject.Media.open(a.trackingString, b[5], "Pressly"), this.trackerObject.Media.play(a.trackingString, b[4]);
            else if (b[1] === "resume") this.trackerObject.Media.play(a.trackingString, b[4]);
            else if (b[1] === "pause" || b[1] === "ended") this.trackerObject.Media.stop(a.trackingString,
            b[4]), b[1] === "ended" && this.trackerObject.Media.close(a.trackingString)
        },
        trackCustomEvent: function (b) {
            if (this.trackCustomEvents === true && this.allowedCustomEvents[b[1]] === true) this.trackerObject.linkTrackVars = "None", this.trackerObject.linkTrackEvents = "None", b[1] === "share" ? this.trackerObject.tl(true, "o", b[1] + "-" + b[3] + "-" + b[4]) : b[1] === "exit-link" ? (this.trackerObject.trackExternalLinks = true, this.trackerObject.tl(true, "e", b[2])) : this.trackerObject.tl(true, "o", b[1] + "-" + b[3])
        },
        initializeOmnitureMediaModule: function (b) {
            if (this.initOmnitureMediaModule === false && (this.initOmnitureMediaModule = true, typeof this.trackerObject.loadModule === "function")) {
                this.trackerObject.loadModule("Media");
                for (var a in b) if (typeof b[a] == "object") for (var c in b[a]) this.trackerObject[a][c] = b[a][c];
                else this.trackerObject[a] = b[a]
            }
        },
        getMockOmnitureObject: function () {
            return {
                provider: "omniture",
                trackerObject: {
                    t: function () {
                        var b = [],
                            a;
                        for (a in this) a != "t" && a != "loadModule" && (console.log("fake omniture tracker call. prop[" + a + "] =", this[a]), b.push(a));
                        for (a = 0; a < b.length; a++) delete this[b[a]]
                    }
                },
                customVarRoutes: {
                    adSize: "prop1",
                    adLocation: "prop2"
                }
            }
        }
    })
})();
(function () {
    Pressly.Tracking.trackers.Google = function (b) {
        this.init(b);
        this.accountPrefix = typeof b.accountPrefix === "string" && b.accountPrefix.length > 0 ? b.accountPrefix : "";
        var a = document.createElement("script");
        a.type = "text/javascript";
        a.async = true;
        a.src = ("https:" == document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";
        var c = document.getElementsByTagName("script")[0];
        c.parentNode.insertBefore(a, c);
        if (typeof window._gaq === "undefined") window._gaq = [];
        this.push(["_setAccount",
        b.googleAnalyticsAccount]);
        (typeof b.sampleRate === "string" || typeof b.sampleRate === "number") && this.push(["_setSampleRate", b.sampleRate.toString()]);
        typeof b.allowLinker === "boolean" && this.push(["_setAllowLinker", b.allowLinker]);
        typeof b.domainName === "string" && this.push(["_setDomainName", b.domainName]);
        this.push(["_trackPageview"])
    };
    _.extend(Pressly.Tracking.trackers.Google.prototype, Pressly.Tracking.trackers.Tracker.prototype, {
        push: function (b) {
            typeof this.accountPrefix === "string" && this.accountPrefix.length > 0 && typeof b[0] === "string" && (b[0] = this.accountPrefix + "." + b[0]);
            window._gaq.push(b)
        },
        trackCustomEvent: function (b) {
            this.trackCustomEvents === true && this.allowedCustomEvents[b[1]] === true && this.push(b[1] === "share" ? ["_trackEvent", "ui-event-" + b[1] + "-" + b[3], b[4]] : b[1] === "exit-link" ? ["_trackEvent", "ui-event-" + b[1], b[2]] : ["_trackEvent", "ui-event-" + b[1], b[3]])
        },
        track: function (b, a) {
            if (this.trackerCustomVarRoutes && a) for (var c in this.trackerCustomVarRoutes) if (this.trackerCustomVarRoutes.hasOwnProperty(c)) {
                var e = Pressly.Tracking.getPresslyCustomVariable(c, this.options, b, a);
                typeof e != "undefined" && this.push(["_setCustomVar", this.trackerCustomVarRoutes[c].slot, this.trackerCustomVarRoutes[c].name, e, this.trackerCustomVarRoutes[c].scope])
            }
            if (b[0] === "video") if (c = b[4], this.push(["_setCustomVar", 1, "Section", a.sectionId, 3]), b[1] == "play") this.push(["_trackEvent", "video", "open", a.trackingString, b[5]]), this.push(["_trackEvent", "video", "play", a.trackingString, c]);
            else if (b[1] === "resume") this.push(["_trackEvent", "video", "play", a.trackingString, c]);
            else {
                if (b[1] === "pause" || b[1] === "ended") this.push(["_trackEvent", "video", "stop", a.trackingString, c]), b[1] === "ended" && this.push(["_trackEvent", "video", "close", a.trackingString, c])
            } else b[0] === "ui-event" ? this.trackCustomEvent(b, a) : (c = a.trackingString + Pressly.Tracking.getPaginationTrackingStringSuffix(b, a), this.push(["_setCustomVar", 1, "Section", a.sectionId, 3]), typeof this.beforeTrack === "function" && this.beforeTrack(c, this), this.push(["_trackPageview", c]))
        }
    })
})();
(function () {
    Pressly.Tracking.trackers.DW = function (b) {
        this.init(b);
        b = document.createElement("script");
        b.type = "text/javascript";
        b.src = ("https:" == document.location.protocol ? "https://" : "http://") + "dw.com.com/js/dw.js";
        var a = document.getElementsByTagName("script")[0];
        a.parentNode.insertBefore(b, a);
        this.assetToTrackingIdMap = {
            2: "28",
            6: "28",
            9: "28",
            14: "31"
        }
    };
    _.extend(Pressly.Tracking.trackers.DW.prototype, Pressly.Tracking.trackers.Tracker.prototype, {
        track: function (b, a) {
            if (a && b[0] !== "video") if (a.selector === ".article" || a.type === "article") {
                var c = a.originalId,
                    e = a.siteId,
                    f = a.assetTypeId;
                if (typeof c != "undefined" && typeof e != "undefined" && typeof f != "undefined") {
                    e = Pressly.Tracking.getPaginationParameters(b, a);
                    f = f.toString();
                    c = c.toString();
                    DW.pageParams = {
                        siteid: "3",
                        edid: "4839",
                        astid: this.assetToTrackingIdMap[f.toString()],
                        asid: c.toString()
                    };
                    if (a.selector === ".article" || a.type === "article") DW.pageParams.pgnbr = e !== null ? e.page : 1;
                    DW.clear()
                }
            } else if (b[0] === "page") DW.pageParams = {
                siteid: "3",
                edid: "4839"
            }, DW.clear()
        }
    })
})();
(function () {
    var b;
    Pressly.Keyboard = {
        init: function () {
            var a = this;
            b = window.issue.router;
            $(window.document).keydown(function (c) {
                a.handler(c)
            });
            console.log("Desktop Mode: Keyboard navigation initiated.")
        },
        handler: function (a) {
            if (!([27, 8, 37, 38, 39, 40].indexOf(a.keyCode) < 0)) switch (a.stopPropagation(), a.preventDefault(), a.keyCode) {
            case 37:
                b.hasActiveNav() ? b.sectionNav && b.sectionNavBlind.is("on") && b.sectionNav.swipe.gotoPreviousPage() : b.articleLayer.isActive() ? (a = b.articleLayer.pages.currentPage.article) && a.mediaOverlay && a.mediaOverlay.isVisible() && a.mediaOverlay.galleryLayer ? a.mediaOverlay.galleryLayer.gotoPreviousPage() : a && a.paging && a.paging.currentIndex > 0 ? a.paging.gotoPreviousPage() : b.articleLayer.gotoPreviousPage() : b.pageLayer.gotoPreviousPage();
                break;
            case 39:
                b.hasActiveNav() ? b.sectionNav && b.sectionNavBlind.is("on") && b.sectionNav.swipe.gotoNextPage() : b.articleLayer.isActive() ? (a = b.articleLayer.pages.currentPage.article) && a.mediaOverlay && a.mediaOverlay.isVisible() && a.mediaOverlay.galleryLayer ? a.mediaOverlay.galleryLayer.gotoNextPage() : a && a.paging && a.paging.pages.length > 1 && a.paging.currentIndex + 1 < a.paging.pages.length ? a.paging.gotoNextPage() : b.articleLayer.gotoNextPage() : b.pageLayer.gotoNextPage();
                break;
            case 38:
                b.sectionNav && b.sectionNavBlind.is("on") && b.hideAllNav();
                break;
            case 40:
                b.sectionNav && b.sectionNavBlind.is("off") && b.showSectionNav()
            }
        }
    }
})();
(function (b) {
    function a(a, b) {
        this.defaults = {};
        Pressly.Core.call(this, a, b)
    }
    a.prototype.init = function () {
        var a = this;
        Pressly.Device.isNamed("Apple iPad iOS 4.3+") ? this.overlayInit() : setTimeout(function () {
            var b = document.createEvent("HTMLEvents");
            b.initEvent("click", true, true);
            $("<a></a>").attr("href", a.options.url).attr("target", "_blank")[0].dispatchEvent(b)
        }, 500)
    };
    a.prototype.overlayInit = function () {
        var a = this,
            b = $("#external-link-copy").find("#" + this.options.context).text();
        if (b === null || typeof b === "string" && b.length === 0) b = "Tap to exit";
        b = $("<a class='external-link-note'></a>").text(b);
        b.attr("href", this.options.url);
        this.options.url.indexOf("mailto:") > -1 || b.attr("target", "_blank");
        b.click(function () {
            a.overlay.remove()
        });
        this.overlay = $("<div class='external-link-overlay'></div>");
        this.overlay.append(b);
        this.overlay.css({
            zIndex: 9999
        });
        $(this.element).append(this.overlay);
        this.overlayOpacity = new Pressly.Transition(this.overlay, {
            property: "opacity",
            on: "1",
            off: "0",
            duration: 200,
            transitionEnd: function () {}
        });
        this.overlayOpacity.on()
    };
    a.prototype.destroy = function () {
        this.overlay && this.overlay.remove && this.overlay.remove()
    };
    b.Pressly.ExternalLink = a
})(window);
(function () {
    Pressly.Storage = {
        supported: function () {
            try {
                return "localStorage" in window && window.localStorage !== null
            } catch (b) {}
            return false
        },
        set: function (b, a) {
            Pressly.Storage.supported() && window.localStorage.setItem(b, a)
        },
        get: function (b) {
            if (Pressly.Storage.supported()) return window.localStorage.getItem(b)
        }
    }
})();
(function () {
    var b = function (a, c) {
        this.defaults = {
            cleanup: true
        };
        Pressly.Core.apply(this, arguments)
    };
    b.prototype.init = function () {
        this.manifestCache = {};
        var a = $(this.element);
        b.timestamp = a.data("timestamp");
        var c = 0,
            e = 0,
            f = 0,
            h = this;
        a.find("section").each(function (a, b) {
            var b = $(b),
                k = b.data("id"),
                l = b.data("pagination") === false ? false : true,
                i = 0,
                r = b.find("li.page");
            r.each(function (a, b) {
                var b = $(b),
                    n = b.data("id"),
                    j = b.find("a").attr("href"),
                    r = [],
                    z = b.data("pagination") === false ? false : true,
                    E = 0;
                b.find("li.article").each(function (a,
                b) {
                    var b = $(b),
                        l = b.data("id");
                    r.push(l);
                    if (h.manifestCache.hasOwnProperty(l)) console.error("Manifest cache collision on article: " + l + " at articleIndex=" + f);
                    else {
                        h.manifestCache[l] = {
                            id: l,
                            originalId: b.data("original-id"),
                            siteId: b.data("site-id"),
                            assetTypeId: b.data("asset-type-id"),
                            url: j,
                            index: f,
                            indexInPage: E,
                            indexInSection: i,
                            sectionIndex: c,
                            childrenIds: [],
                            sectionId: k,
                            pageId: n,
                            pageIndex: e,
                            selector: ".article",
                            title: b.data("title"),
                            fullscreen: b.data("fullscreen") === "data-fullscreen",
                            trackingString: "tablet/" + k + "/articles/" + l,
                            gigyaCategoryId: b.data("gigya-category-id"),
                            gigyaStreamId: b.data("gigya-stream-id")
                        };
                        _(b.get(0).attributes).chain().select(function (a) {
                            return typeof a.name === "string" && a.name.indexOf("data-client-") === 0
                        }).each(function (a) {
                            var c = a.name.substr(5);
                            h.manifestCache[l][c] = a.value
                        });
                        var p = 0;
                        b.find("li.gallery").each(function (a, b) {
                            var b = $(b),
                                e = b.data("id");
                            r.push(e);
                            h.manifestCache.hasOwnProperty(e) ? console.error("Manifest cache collision on gallery: " + e + " at articleIndex=" + f) : (h.manifestCache[e] = {
                                id: e,
                                url: j,
                                indexInArticle: p,
                                index: f,
                                indexInSection: i,
                                sectionIndex: c,
                                childrenIds: [],
                                sectionId: k,
                                pageId: n,
                                selector: ".gallery",
                                fullscreen: b.data("fullscreen") === "data-fullscreen",
                                trackingString: "tablet/" + k + "/articles/" + e
                            }, p++)
                        });
                        b.find(".video").each(function (a, b) {
                            var b = $(b),
                                e = b.data("id");
                            r.push(e);
                            h.manifestCache.hasOwnProperty(e) ? console.error("Manifest cache collision on video: " + e + " at articleIndex=" + f) : h.manifestCache[e] = {
                                id: e,
                                url: j,
                                index: f,
                                indexInSection: i,
                                sectionIndex: c,
                                childrenIds: [],
                                sectionId: k,
                                pageId: n,
                                selector: ".video",
                                fullscreen: b.data("fullscreen") === "data-fullscreen",
                                trackingString: "tablet/" + k + "/articles/" + e,
                                videoType: b.data("video-type")
                            }
                        })
                    }
                    f++;
                    E++
                });
                if (h.manifestCache.hasOwnProperty(n)) console.error("Manifest cache collision on page: " + n);
                else {
                    var L = b.data("ad") === "data-ad",
                        M = b.data("hasad") === true,
                        m, B;
                    L ? m = "tablet/" + k + "/ad-" + n : M ? (m = "tablet/" + k + "/index-" + i + "-with-ad", B = "tablet/" + k + "/index-" + i) : m = "tablet/" + k + "/index-" + i;
                    h.manifestCache[n] = {
                        id: n,
                        url: j,
                        paginated: z && l,
                        numbered: k === "cover_section" ? false : true,
                        index: e,
                        indexInSection: i,
                        sectionIndex: c,
                        childrenIds: r,
                        sectionId: k,
                        pageId: n,
                        selector: ".page",
                        isTOCPage: n.indexOf("table-of-contents") === 0 ? true : false,
                        fullscreen: b.data("fullscreen") === "data-fullscreen",
                        ad: L,
                        hasAd: M,
                        adLocation: b.data("adlocation"),
                        adSize: b.data("adsize"),
                        trackingString: m,
                        adlessTrackingString: B
                    }
                }
                e++;
                i++
            });
            h.manifestCache[k] = {
                id: k,
                index: c,
                childCount: r.length,
                selector: "section",
                trackingString: "tablet/" + k
            };
            c++
        });
        this.options.cleanup && this.cleanup()
    };
    b.prototype.getPageByIndex = function (a) {
        return _(this.manifestCache).detect(function (c) {
            return c.index === a && c.selector === ".page"
        })
    };
    b.prototype.find = function (a) {
        return _(this.manifestCache).select(function (c) {
            return c.selector === a
        })
    };
    b.prototype.analyze = function () {
        var a = {}, c = {}, b = {}, f;
        for (f in this.manifestCache) {
            var h = this.manifestCache[f],
                j = typeof h.title === "string" && h.title.length > 0 ? h.title : "_____EMPTY_TITLE_____";
            c[j] = typeof c[j] === "number" ? c[j] + 1 : 1;
            a[h.selector] = typeof a[h.selector] === "number" ? a[h.selector] + 1 : 1
        }
        for (f in c) c[f] > 1 && (b[f] = this.allByTitle(f));
        console.log("type counts:", a);
        console.log("title counts:", c);
        console.log("repeat articles:", b)
    };
    b.prototype.allByTitle = function (a) {
        return _.sortBy(_.select(this.manifestCache, function (c) {
            return c.title === a
        }), function (a) {
            return a.index
        })
    };
    b.prototype.allByTitlePrefix = function (a, c) {
        return _.sortBy(_.select(this.manifestCache, function (b) {
            return c ? typeof b.title === "string" && b.title.toLowerCase().indexOf(a.toLowerCase()) > 0 : typeof b.title === "string" && b.title.indexOf(a) > 0
        }),

        function (a) {
            return a.index
        })
    };
    b.prototype.allByTitleSubstring = function (a, c) {
        return _.sortBy(_.select(this.manifestCache, function (b) {
            return c ? typeof b.title === "string" && b.title.toLowerCase().indexOf(a.toLowerCase()) > -1 : typeof b.title === "string" && b.title.indexOf(a) > -1
        }), function (a) {
            return a.index
        })
    };
    b.prototype.allByAnyId = function (a) {
        return _.sortBy(_.select(this.manifestCache, function (c) {
            return c.id === a
        }), function (a) {
            return a.index
        })
    };
    b.prototype.allByAnyIdSubstring = function (a, c) {
        return _.sortBy(_.select(this.manifestCache,

        function (b) {
            return c ? typeof b.id === "string" && b.id.toLowerCase().indexOf(a.toLowerCase()) > -1 : b.id === a || typeof b.id === "string" && b.id.indexOf(a) > -1
        }), function (a) {
            return a.index
        })
    };
    b.prototype.allBySelector = function (a) {
        return _.sortBy(_.select(this.manifestCache, function (c) {
            return a === "toc" ? c.isTOCPage === true : c.selector === a
        }), function (a) {
            return a.index
        })
    };
    b.prototype.search = function (a) {
        return [].concat(this.allByTitleSubstring(a, true)).concat(this.allByAnyIdSubstring(a, true))
    };
    b.prototype.allPages = function () {
        return this.allBySelector(".page")
    };
    b.prototype.allArticles = function () {
        return this.allBySelector(".article")
    };
    b.prototype.allGalleries = function () {
        return this.allBySelector(".gallery")
    };
    b.prototype.get = function (a) {
        return this.manifestCache[a]
    };
    b.prototype.cleanup = function () {
        $(this.element).remove()
    };
    b.prototype.destroy = function () {
        this.cleanup();
        this.element = this.options = void 0
    };
    Pressly.Manifest = b
})();
(function () {
    function b() {}
    b.prototype.onStateChange = function (a, c) {
        var b = a.target,
            f = $(c.element);
        f.data("playing", f.data("playing") ? true : false);
        switch (a.data) {
        case YT.PlayerState.PLAYING:
            f.data("playing") === true ? window.issue.router.track(["video", "resume", "pageObject", c.manifestInfo, b.getCurrentTime(), b.getDuration()]) : (f.data("playing", true), window.issue.router.track(["video", "play", "pageObject", c.manifestInfo, b.getCurrentTime(), b.getDuration()]));
            break;
        case YT.PlayerState.PAUSED:
            window.issue.router.track(["video", "pause", "pageObject", c.manifestInfo, b.getCurrentTime()]);
            break;
        case YT.PlayerState.ENDED:
            f.data("playing", false), window.issue.router.track(["video", "ended", "pageObject", c.manifestInfo, b.getCurrentTime()])
        }
    };
    Pressly.YoutubeListener = b
})();

function onYouTubePlayerAPIReady() {}
(function () {
    function b(a, c) {
        this.defaults = {};
        Pressly.Core.apply(this, arguments)
    }
    b.prototype.init = function () {};
    b.prototype.isVisible = function () {
        return this.container && this.transition && this.transition.is("on")
    };
    b.prototype.show = function (a, c) {
        var b = this;
        this.remove();
        this.manifestInfo = c;
        this.id = c.id;
        this.fullscreen = $(a).data("fullscreen") === true;
        this.container = $("<div class='media-overlay'></div>");
        this.transition = new Pressly.Transition(this.container, {
            property: "opacity",
            on: "1",
            off: "0",
            duration: 400,
            transitionEnd: function () {
                switch (this.state) {
                case "on":
                    if (b.galleryLayer) b.galleryLayer.onShow();
                    break;
                case "off":
                    if (b.galleryLayer) b.galleryLayer.onHide();
                    b.cleanup()
                }
            }
        });
        this.actionBoxes = [];
        $(a).find("[data-action]").each(function (a, c) {
            $(c).data("box-initialized") !== true && b.actionBoxes.push(new Pressly.Box(c, {
                page: b
            }))
        });
        switch (this.manifestInfo.selector) {
        case ".gallery":
            window.issue.router.track(["media", "show", "pageObject", this.manifestInfo]);
            this.initializeGallery(a);
            break;
        case ".video":
            window.issue.router.track(["video", "navigate", "pageObject", this.manifestInfo]), this.initializeVideo(a)
        }
    };
    b.prototype.initializeVideo = function (a) {
        var c = this;
        $(this.container).append(a.children());
        this.fullscreen ? $("#articles_wrapper").after(this.container) : $(this.element).append(this.container);
        var b = false;
        $(this.container).find("video").each(function (a, h) {
            var j = $(h);
            j.bind("play", function () {
                b ? window.issue.router.track(["video", "resume", "pageObject", c.manifestInfo, this.currentTime, this.duration]) : (b = true, window.issue.router.track(["video", "play", "pageObject", c.manifestInfo, this.currentTime, this.duration]))
            });
            j.bind("pause", function () {
                b && window.issue.router.track(["video", "pause", "pageObject", c.manifestInfo, this.currentTime])
            });
            j.bind("ended", function () {
                b = false;
                window.issue.router.track(["video", "ended", "pageObject", c.manifestInfo, this.currentTime])
            });
            j.attr("src", j.data("src"));
            j.bind("seeking", function () {
                b && window.issue.router.track(["video", "pause", "pageObject", c.manifestInfo, this.currentTime])
            });
            j.bind("seeked", function () {
                b && window.issue.router.track(["video", "resume", "pageObject", c.manifestInfo, this.currentTime])
            })
        });
        a = $(this.container).find("iframe.youtube");
        if (a.length === 1) window.issue.youtubeListener = window.issue.youtubeListener || new Pressly.YoutubeListener, a.attr("src", a.data("src")), this.youtubePlayer = new YT.Player("api-player", {
            events: {
                onStateChange: function (a) {
                    window.issue.youtubeListener.onStateChange(a, c)
                }
            }
        });
        setTimeout(function () {
            c.transition.on()
        }, 0)
    };
    b.prototype.initializeGallery = function (a) {
        var c = this,
            b = [],
            f = $("<div class='gallery_paging'></div>"),
            h = $(a).find("ul[data-type=gallery] li");
        h.each(function (a) {
            var f = c.id + "_subpage_" + a,
                k = $("<div class='subpage'></div>").attr("id", f);
            b.push(new Pressly.Page(k, void 0, {
                id: f,
                pageId: c.manifestInfo.pageId,
                pageClass: "subpage",
                index: a,
                cache: true,
                contentLoader: function (a) {
                    h.eq(a.index).find("img").each(function (a, c) {
                        c = $(c);
                        c.attr("src", c.data("src"));
                        c.addClass("overlay_image");
                        c.load(function () {
                            $(this).addClass("loaded")
                        })
                    });
                    return h.eq(a.index)
                }
            }))
        });
        a.find("ul[data-type=gallery]").remove();
        this.container.append(f).append(a.children());
        this.fullscreen ? $("#articles_wrapper").after(this.container) : $(this.element).append(this.container);
        this.galleryLayer = new Pressly.Paging(f, {
            resettable: false,
            pageClass: "subpage",
            greedySwipes: true,
            pages: b,
            name: "gallery",
            success: function () {},
            onDoubleswipeup: this.options.onDoubleswipeup,
            onDoubleswipedown: this.options.onDoubleswipedown,
            onSymmetricalPinch: this.options.onSymmetricalPinch,
            onTouchtap: function (a) {
                c.handleTouchTap(a)
            }
        });
        a = function (a, b) {
            var e = $(c.galleryLayer.pages.currentPage.element).find("img");
            a !== b && Pressly.track(["page", "navigate", "pageObject", void 0, a + 1, c.galleryLayer.pages.length], c.manifestInfo);
            e.hasClass("hires") === false && e.attr("src", $(e).data("hires"))
        };
        this.galleryLayer.addPageChangeListener(a);
        a(0, void 0);
        this.galleryLayer.beforeShow();
        setTimeout(function () {
            c.transition.on()
        }, 0)
    };
    b.prototype.initializeYoutubeIframeAPI = function () {
        var a = document.createElement("script");
        a.src = "http://www.youtube.com/player_api";
        var c = document.getElementsByTagName("script")[0];
        c.parentNode.insertBefore(a,
        c)
    };
    b.prototype.hide = function () {
        this.container && this.transition && (this.galleryLayer && this.galleryLayer.beforeHide(), this.transition.off())
    };
    b.prototype.remove = function () {
        this.container && this.container.remove()
    };
    b.prototype.cleanup = function () {
        this.destroy();
        if (typeof this.options.onHide === "function") this.options.onHide()
    };
    b.prototype.destroy = function () {
        if (this.actionBoxes) for (var a = 0; a < this.actionBoxes.length; a++) this.actionBoxes[a].destroy();
        this.actionBoxes = void 0;
        if (this.transition) this.transition.destroy(),
        this.transition = void 0;
        if (this.galleryLayer) this.galleryLayer.destroy(), this.galleryLayer = void 0;
        this.remove()
    };
    b.prototype.handleTouchTap = function () {
        this.container.toggleClass("cinema")
    };
    b.prototype.handleViewportChange = function () {
        this.galleryLayer && this.galleryLayer.handleViewportChange()
    };
    Pressly.MediaOverlay = b
})();
(function () {
    var b = function (a, b) {
        this.defaults = {};
        Pressly.Core.apply(this, arguments)
    };
    b.cachedViewportStyles = {};
    b.prototype.init = function () {
        var a = this;
        $(this.element);
        this.navOverlay = $("<div class='nav-overlay'></div>");
        this.navOverlayButton = new Pressly.Box(this.navOverlay);
        this.navOverlayButton.addAction(function () {
            a.hideAllNav()
        });
        this.navOverlayOpacity = new Pressly.Transition(this.navOverlay, {
            property: "opacity",
            on: "1",
            off: "0",
            duration: 200,
            transitionEnd: function () {
                switch (this.state) {
                case "off":
                    a.navOverlay.detach()
                }
            }
        });
        this.webview = null;
        this.articleLayerBlind = new Pressly.Transition("#articles_wrapper", {
            property: "transform",
            vendorPrefix: true,
            duration: 400,
            transitionEnd: function (b) {
                if (!(b && b.target !== this.element)) switch (this.state) {
                case "on":
                    b = a.articleLayer.pages.currentPage;
                    a.articleLayer.onShow();
                    a.pageLayer.onHide();
                    b.article && b.article.prepareNeighbors();
                    $(this.element).removeClass("events_locked");
                    break;
                case "off":
                    a.articleLayer.onHide(), a.pageLayer.onShow()
                }
            }
        });
        var b = $("#sections");
        $("section.manifest nav.sections header[role=topnav]").each(function () {
            b.append($(this).clone().attr("id",
            $(this).closest("section").data("id")).addClass("subpage"))
        });
        this.manifest = new Pressly.Manifest(".manifest", {
            cleanup: true
        });
        _(this.manifest.allBySelector(".video")).select(function (a) {
            return a.videoType === "youtubeID"
        }).length > 0 && Pressly.MediaOverlay.prototype.initializeYoutubeIframeAPI();
        this.initializeViewportChangeListeners();
        a.sectionLayer = new Pressly.Paging("#sections", {
            resettable: false,
            pageClass: "subpage",
            name: "sectionLayer",
            disableGestures: true,
            active: true,
            success: function (f) {
                f.lock();
                a.attachMediaQueryCSS(true);
                a.pageLayer = new Pressly.Paging("#pages", {
                    resettable: true,
                    manifestItems: a.manifest.find(".page"),
                    navSource: "nav.sections",
                    name: "pageLayer",
                    trimmable: true,
                    direction: $("#pages_wrapper").data("vertical") ? "y" : "x",
                    prepend: function () {
                        if (!this.isFullscreen()) {
                            var a = b.find("#" + this.sectionId).clone().removeAttr("id").removeAttr("data-index").removeAttr("style").removeClass("subpage");
                            a.find("*").removeAttr("data-action");
                            a.find(".modal").remove();
                            return a
                        }
                    },
                    tracker: function (b) {
                        a.track(b)
                    },
                    active: true,
                    success: function (b) {
                        a.initSectionNav();
                        a.articleLayer = new Pressly.Paging("#articles", {
                            resettable: true,
                            name: "articleLayer",
                            manifestItems: a.manifest.find(".article"),
                            disableGestures: true,
                            tracker: function (b) {
                                a.track(b)
                            },
                            success: function (e) {
                                a.initializeLayerSync();
                                a.initNavEvents();
                                !Pressly.Device.isTablet() && !Pressly.Device.isPhone() && Pressly.Keyboard && Pressly.Keyboard.init();
                                setTimeout(function () {
                                    a.attachMediaQueryCSS()
                                }, 1);
                                a.options.jumpToPageAfterLoad && setTimeout(function () {
                                    b.isFirstPage() && b.snapToPage(a.options.jumpToPageAfterLoad)
                                },
                                a.options.jumpToPageDelay || 2E3);
                                a.articleSlide = $(e.element).data("horizontal-slide") ? "horizontal" : "vertical";
                                Pressly.Test && (new Pressly.Test).findTests()
                            }
                        })
                    }
                })
            }
        })
    };
    b.prototype.gotoExternalLink = function (a, b) {
        this.externalLink && this.externalLink.destroy();
        this.externalLink = new Pressly.ExternalLink($("#issue").get(0), {
            url: a,
            context: b
        })
    };
    b.prototype.showArticleBackButton = function () {
        $(this.sectionLayer.element).find(".button.back").show().addClass("visible");
        $(this.sectionLayer.element).find(".button.options").show().addClass("visible")
    };
    b.prototype.hideArticleBackButton = function () {
        $(this.sectionLayer.element).find(".button.back").hide().removeClass("visible");
        $(this.sectionLayer.element).find(".button.options").hide().removeClass("visible")
    };
    b.prototype.handleNavigationRequest = function (a) {
        var b = this.manifest.get(a);
        b && b.selector === ".page" ? (this.articleLayer.isActive() && this.hideArticleLayer(true), this.goTo(a)) : console.error("Router: Navigation to page that does not exist.")
    };
    b.prototype.initSectionNav = function () {
        var a = this,
            b = $("nav.links"),
            f = $("#sectionnav");
        f.length === 0 && b.wrap("<div id='sectionnav'></div>");
        b.length > 0 ? (this.sectionNav = new Pressly.Nav(b, {
            onNavigationRequest: function (b) {
                Pressly.track(["ui-event", "nav-section", "name", b]);
                a.handleNavigationRequest(b)
            }
        }), this.sectionNav.lock(), b.show(), this.sectionNavBlind = new Pressly.Transition("#sectionnav", {
            property: "transform",
            vendorPrefix: true,
            duration: 200,
            off: "translateX(0px) translateY(0px) translateZ(0px)",
            transitionEnd: function () {
                switch (this.state) {
                case "on":
                    a.sectionNav.unlock()
                }
                if (typeof a.navTransitionCallback === "function") {
                    var b = a.navTransitionCallback;
                    a.navTransitionCallback = null;
                    b()
                }
            }
        })) : this.sectionNav = null;
        this.sectionNavActionBoxes = [];
        f.find("[data-action]").each(function (b, e) {
            $(e).data("box-initialized") !== true && a.sectionNavActionBoxes.push(new Pressly.Box(e))
        })
    };
    b.prototype.goTo = function (a, b, f) {
        var h = this;
        if (this.pageLayer.isActive() && this.pageLayer.pages.currentPage.id === a) typeof b === "function" && b();
        else if (Pressly.Device.isPhantom()) typeof a === "number" && (this.pageLayer.unlock(), this.pageLayer.snapToPage(a,
        void 0, b));
        else {
            var j = this.manifest.get(a);
            if (j) switch (j.selector) {
            case ".article":
                this.showArticleLayerAtPage(j.index, b);
                break;
            case ".page":
                this.hideAllNav(function () {
                    h.articleLayer.isActive() && h.hideArticleLayer(true);
                    h.pageLayer.unlock();
                    h.pageLayer.snapToPage(j.index, void 0, b)
                });
                break;
            case ".video":
                f && f.mediaOverlay && (a = Pressly.Page.getCachedContent(j.pageId, "#" + a)) && f.mediaOverlay.show(a.clone(), j);
                break;
            case ".gallery":
                f && f.mediaOverlay && (a = Pressly.Page.getCachedContent(j.pageId, "#" + a)) && f.mediaOverlay.show(a.clone(),
                j)
            }
        }
    };
    b.prototype.goToMediaInForegroundArticle = function (a) {
        this.goTo(a, void 0, window.issue.router.articleLayer.pages.currentPage.article)
    };
    b.prototype.track = function (a) {
        if ((a[1] === "navigate" || a[0] === "video") && a[2] === "pageObject") {
            var b = this.manifest.get(a[3].id);
            b && (b.selector === ".page" || b.selector === ".video" || b.selector === ".gallery") && Pressly.track(a, b)
        }
    };
    b.prototype.initializeLayerSync = function () {
        var a = this,
            b = $("#sections_wrapper"),
            f = {
                paging: this.sectionLayer,
                toggleFunction: function (f) {
                    var j = a.pageLayer.pages.currentPage,
                        n = a.pageLayer.pages.previousPage,
                        k = a.pageLayer.pages.nextPage,
                        l = a.manifest.get(j.id),
                        i = a.manifest.get(l.sectionId),
                        i = l.indexInSection === i.childCount - 1,
                        l = l.indexInSection === 0;
                    f.currentIndex !== f.targetIndex && (i && f.delta < 0 || l && f.delta > 0 ? b.css("visibility", "hidden") : n && n.isFullscreen() && f.delta > 0 || k && k.isFullscreen() && f.delta < 0 ? b.css("visibility", "hidden") : !j.isFullscreen() && (n && n.isFullscreen() && f.delta <= 0 || k && k.isFullscreen() && f.delta >= 0) ? b.css("visibility", "visible") : !j.isFullscreen() && (i && f.delta >= 0 || l && f.delta <= 0) && b.css("visibility", "visible"));
                    return false
                },
                relationFunction: function (b) {
                    return a.manifest.getPageByIndex(b).sectionIndex
                },
                beforeShow: function (f, j) {
                    if (f !== void 0 && j !== void 0 && j !== null) {
                        var n = this.relationFunction(j),
                            k = this.relationFunction(f);
                        (a.manifest.getPageByIndex(j).fullscreen || k !== n) && b.css("visibility", "hidden")
                    }
                },
                onShow: function (f) {
                    var j = this.relationFunction(f);
                    a.manifest.getPageByIndex(f).fullscreen ? b.css("visibility", "hidden") : (b.css("visibility", "visible"), a.sectionLayer.currentIndex !== j && (a.sectionLayer.unlock(), a.sectionLayer.snapToPage(j, 0), a.sectionLayer.lock()))
                }
            };
        this.pageLayer.syncSlave(f);
        this.pageLayer.options.direction === "y" && this.pageLayer.syncSlave({
            paging: this.sectionLayer,
            toggleFunction: function (b) {
                var e = a.pageLayer.pages.currentPage,
                    f = a.pageLayer.pages.previousPage,
                    k = a.pageLayer.pages.nextPage,
                    l = typeof f === "undefined" || f && f.sectionId != e.sectionId,
                    i = typeof k === "undefined" || k && k.sectionId != e.sectionId;
                b.currentIndex !== b.targetIndex && (b.delta < 0 ? i || !k || k.isFullscreen() || e.isFullscreen() ? ($(e.element).find("header").css("visibility", "visible"), k && $(k.element).find("header").css("visibility", "visible")) : $(k.element).find("header").css("visibility", "hidden") : b.delta > 0 && (l || !f || f.isFullscreen() || e.isFullscreen() ? (f && $(f.element).find("header").css("visibility", "visible"), $(e.element).find("header").css("visibility", "visible")) : $(e.element).find("header").css("visibility", "hidden")))
            }
        });
        this.manifest.getPageByIndex(this.pageLayer.currentIndex).fullscreen || b.addClass("visible");
        this.pageLayer.addPageChangeListener(function (f, j) {
            if (f !== j) {
                var n = a.pageLayer.pages.get(f);
                a.syncSectionNav(n);
                n.isFullscreen() ? b.removeClass("visible") : b.addClass("visible")
            }
        });
        this.articleLayer.addBeforePageChangeListener(function (b, e) {
            e >= 0 && a.showHeaderArticleTitle(a.articleLayer.pages.get(e))
        });
        this.articleLayer.addPageChangeListener(function (b, e) {
            if (b !== e) {
                var n = a.articleLayer.pages.get(b);
                if (n) {
                    var k = a.pageLayer.pages.get(n.pageIndex);
                    k && (a.syncSectionNav(k), f.onShow(k.index));
                    n.article && n.article.prepareNeighbors()
                } else console.error("Note: router's articleLayer pageChangeListener couldn't find a page object for currentIndex = " + b)
            }
        })
    };
    var a;
    b.prototype.syncSectionNav = function (c) {
        var b = this,
            f = b.sectionLayer.pages.get(c.sectionIndex);
        if (f && this.sectionNav && a !== f.index) $(this.sectionNav.element).find("a.nav-link.current").removeClass("current"), $(this.sectionNav.element).find("a.nav-link").each(function (a, c) {
            var c = $(c),
                n = c.attr("href").substr(1);
            (n = b.manifest.get(n)) && n.sectionId === f.id && $(c).addClass("current")
        }), a = f.index
    };
    b.prototype.attachMediaQueryCSS = function (a) {
        var e = this.getViewport(),
            f = e.width > e.height ? "landscape" : "portrait",
            h = this.getViewport().toString(),
            j = this.headerHeight = this.sectionLayer ? $(this.sectionLayer.pages.currentElement).outerHeight(true) : 0,
            n = this.articleToolbarHeight = this.articleLayer ? $(this.articleLayer.element).find("footer:visible").outerHeight(true) : 0;
        this.articleLayerTop = j;
        this.articleLayerBlind.is("on") || (this.articleSlide === "horizontal" ? this.articleLayerBlind.fire("translateX(" + e.width + "px) translateY(0px) translateZ(0px)") : this.articleLayerBlind.fire("translateX(0px) translateY(" + e.height + "px) translateZ(0px)"));
        $(this.articleLayerBlind.element).css("top", this.articleLayerTop + "px");
        if (!b.cachedViewportStyles[h]) {
            var k = function (a, c) {
                var b = c - j,
                    e = b - n,
                    f = e - 48,
                    b = {
                        "body, #wrapper": {
                            width: a + "px",
                            height: c + "px"
                        },
                        "#sections_wrapper": {
                            height: j + "px"
                        },
                        "#articles_wrapper": {
                            height: b + "px"
                        },
                        "#articles_wrapper article .subpage": {
                            height: e + "px"
                        },
                        "footer[role='toolbar'] .comments .widget": {
                            height: f + "px",
                            width: "500px"
                        },
                        "footer[role='toolbar'] .comments .widget .gigya_ui_wrapper": {
                            height: f - 42 + "px"
                        },
                        "footer[role='toolbar'] .comments .widget .vertical-scroll": {
                            height: (Pressly.Device.isNamed("Apple iPad iOS 4.3+") || Pressly.Device.isStandAlone() || Pressly.Device.isWebView() ? f - 46 : f - 42 - 95) + "px"
                        }
                    }, e = "\n",
                    h;
                for (h in b) if (b.hasOwnProperty(h)) {
                    e += h + "{";
                    for (var i in b[h]) b[h].hasOwnProperty(i) && (e += i + ":" + b[h][i] + ";");
                    e += "}\n"
                }
                return e
            }, l = k(e.width, e.height),
                l = "<style class='" + f + "' data-viewport='" + h + "'>\n@media only screen and (orientation:" + f + ")\n{" + l + "}\n</style>",
                i = $("style." + f);
            a || (b.cachedViewportStyles[h] = l);
            i.length > 0 ? i.replaceWith(l) : ($("html").append(l), a = f === "landscape" ? "portrait" : "landscape", e = k(e.height * 0.9, e.width * 0.9), $("html").append("<style class='" + a + "' data-viewport='temp'>\n@media only screen and (orientation:" + a + ")\n{" + e + "}\n</style>"))
        }
    };
    b.prototype.handleViewportChange = function () {
        function a() {
            b.sectionLayer && b.sectionLayer.handleViewportChange();
            b.pageLayer && b.pageLayer.handleViewportChange();
            b.articleLayer && b.articleLayer.handleViewportChange();
            b.sectionNav && b.sectionNav.handleViewportChange()
        }
        var b = this;
        this.attachMediaQueryCSS();
        window.scrollTo(0, 0);
        this.pageLayer && this.pageLayer.isActive() ? setTimeout(function () {
            a()
        }, 300) : a()
    };
    b.prototype.hideProgressBar = function () {
        $("#overlay").hide()
    };
    b.prototype.initializeViewportChangeListeners = function () {
        var a = this;
        if (navigator.userAgent.indexOf("Linux") > -1) {
            var b = 0,
                f = function () {
                    if (window.orientation !== b) b = window.orientation, setTimeout(function () {
                        a.handleViewportChange()
                    }, 100)
                };
            $(window).bind("resize", f);
            $(window).bind("orientationchange", f);
            a.androidOrientationChecker = setInterval(f, 1500)
        } else $(window).bind("orientationchange", function () {
            a.handleViewportChange()
        })
    };
    b.prototype.removeViewportChangeListeners = function () {
        clearInterval(this.androidOrientationChecker);
        $(window).unbind();
        $("body").unbind()
    };
    b.prototype.initNavEvents = function () {
        this.addGestureListener("doubleswipeup", _.bind(this.handleDoubleSwipeUp, this));
        this.addGestureListener("doubleswipedown", _.bind(this.handleDoubleSwipeDown, this))
    };
    b.prototype.handleDoubleSwipeUp = function () {
        this.sectionNav && this.sectionNavBlind.is("on") && (this.hideSectionNav(), this.hideNavOverlay())
    };
    b.prototype.handleDoubleSwipeDown = function () {
        this.sectionNav && this.sectionNavBlind.is("off") && this.showSectionNav()
    };
    b.prototype.toggleSectionNav = function () {
        this.sectionNavBlind.is("on") ? (this.hideSectionNav(), this.hideNavOverlay()) : this.sectionNavBlind.isBusy() || this.showSectionNav()
    };
    b.prototype.showSectionNav = function () {
        if (this.sectionNav) {
            this.showNavOverlay();
            $(".button.section_nav").addClass("selected");
            $(this.sectionLayer.element).find(".subpage.current").addClass("sectionnav-active");
            var a = Math.abs(parseInt($(this.sectionNavBlind.element).css("top"),
            10));
            this.pageLayer.pages.currentPage.isFullscreen() || (a += this.headerHeight);
            this.sectionNavBlind.on({
                value: "translateX(0px) translateY(" + a + "px) translateZ(0px)"
            })
        }
    };
    b.prototype.hideSectionNav = function () {
        this.sectionNav && this.sectionNavBlind.is("on") && (this.sectionNav.lock(), $(".button.section_nav").removeClass("selected"), $(this.sectionLayer.element).find(".subpage.current").removeClass("sectionnav-active"), this.sectionNavBlind.off())
    };
    b.prototype.showNavOverlay = function () {
        var a = this;
        this.navOverlay.is(":visible") || ($(this.element).append(this.navOverlay), setTimeout(function () {
            a.navOverlayOpacity.on()
        }, 0))
    };
    b.prototype.hideNavOverlay = function () {
        this.navOverlay.is(":visible") && this.navOverlayOpacity.off()
    };
    b.prototype.hideAllNav = function (a) {
        this.hasActiveNav() ? (this.navTransitionCallback = a, this.hideSectionNav(), this.hideNavOverlay()) : typeof a === "function" && a()
    };
    b.prototype.hasActiveNav = function () {
        return this.sectionNav && !this.sectionNavBlind.is("off")
    };
    b.prototype.showHeaderArticleTitle = function (a) {
        var a = a || this.articleLayer.pages.currentPage,
            b = this.sectionLayer.pages.getById(a.sectionId),
            a = a.title,
            b = $(b.element).find("h1.article_title");
        b.html(a);
        b.addClass("visible")
    };
    b.prototype.hideHeaderArticleTitle = function () {
        this.sectionLayer.pages.all.find("h1.article_title").removeClass("visible")
    };
    b.prototype.showArticleLayerAtPage = function (a, b) {
        this.showArticleBackButton();
        this.hideAllNav();
        this.getViewport();
        this.articleLayer.unlock();
        this.articleLayer.snapToPage(a, 0, b);
        this.track(["page", "navigate", "pageObject",
        this.articleLayer.pages.currentPage], true);
        var f = this.articleLayer.pages.currentPage;
        f.article && f.article.paging && (f.article.setFontSize(), f.article.paging.snapToPage(0, 0));
        this.articleLayer.beforeShow();
        this.pageLayer.beforeHide();
        $(this.sectionLayer.element).find(".logo").hide();
        this.showHeaderArticleTitle();
        $(this.articleLayerBlind.element).addClass("events_locked");
        this.articleLayerBlind.on({
            value: "translateX(0px) translateY(0px) translateZ(0px)"
        })
    };
    b.prototype.hideArticleLayer = function (a) {
        this.hideArticleBackButton();
        var b = this.getViewport(),
            f = this.manifest.get(this.articleLayer.pages.currentPage.pageId);
        f && this.pageLayer.currentIndex !== f.index && (this.pageLayer.unlock(), this.pageLayer.snapToPage(f.index, 0), this.pageLayer.lock());
        this.articleLayer.beforeHide();
        this.pageLayer.beforeShow();
        $(this.sectionLayer.element).find(".logo").show();
        this.hideHeaderArticleTitle();
        b = this.articleSlide === "horizontal" ? "translateX(" + (b.width + 300) + "px) translateY(0px) translateZ(0px)" : "translateX(0px) translateY(" + (b.height + 300) + "px) translateZ(0px)";
        a ? this.articleLayerBlind.off({
            value: b,
            duration: 0
        }) : this.articleLayerBlind.off({
            value: b
        })
    };
    b.prototype.destroy = function () {
        this.sectionNav.destroy();
        this.sectionNav = void 0;
        this.sectionNavBlind.destroy();
        $("#sections").remove();
        this.manifest.destroy();
        this.manifest = void 0;
        this.sectionLayer.destroy();
        this.sectionLayer = void 0;
        this.pageLayer.destroy();
        this.pageLayer = void 0;
        this.articleLayer.destroy();
        this.articleLayer = void 0;
        this.articleLayerBlind.destroy();
        if (this.navOverlayButton) this.navOverlayButton.destroy(),
        this.navOverlayButton = void 0;
        this.navOverlayOpacity.destroy();
        $(this.element).unbind("webkitTransitionEnd transitionend");
        $(window.document).unbind("keydown");
        b.cachedViewportStyles = void 0;
        typeof this.removeAllGestureListeners === "function" && this.removeAllGestureListeners();
        $(this.element).remove();
        this.options = this.element = void 0;
        Pressly.Page.destroyCache()
    };
    window.Pressly.Router = b
})();
(function () {
    function b() {
        this.gesture = {
            gesturesAreGreedy: false,
            touches: null,
            moved: false,
            gesturing: false,
            attachedGestureListeners: false,
            gestureListeners: [],
            nativeGestureListeners: []
        }
    }
    var a = {
        touchtap: true,
        touchstart: true,
        touchmove: true,
        touchend: true,
        singletouchcancel: true,
        touchmovevertical: true,
        touchmovevertical_start: true,
        touchmovevertical_end: true,
        touchmovehorizontal: true,
        touchmovehorizontal_start: true,
        touchmovehorizontal_end: true
    }, c = {
        debuggesture: function (a) {
            return _(a).each(function (a, c) {
                var b = a.currentX - a.startX,
                    e = a.currentY - a.startY;
                console.log("Touch " + c + ": dX=" + b + " dY=" + e + " s=" + e / b)
            })
        },
        doubleswipeleft: function (a) {
            return c.symmetricalpinch(a) ? false : _(a).reduce(function (a, c) {
                var b = c.currentX - c.startX,
                    e = c.currentY - c.startY;
                return a === false ? false : Math.abs(e / b) < 0.6 && b < -10
            }, true)
        },
        doubleswiperight: function (a) {
            return c.symmetricalpinch(a) || !a || a && a.length === 0 ? false : _(a).reduce(function (a, c) {
                var b = c.currentX - c.startX,
                    e = c.currentY - c.startY;
                return a === false ? false : Math.abs(e / b) < 0.6 && b > 10
            }, true)
        },
        doubleswipedown: function (a) {
            return c.symmetricalpinch(a) || !a || a && a.length === 0 ? false : _(a).reduce(function (a, c) {
                var b = c.currentX - c.startX,
                    e = c.currentY - c.startY;
                return a === false ? false : Math.abs(e / b) > 1.25 && e > 10
            }, true)
        },
        doubleswipeup: function (a) {
            if (c.symmetricalpinch(a) || !a || a && a.length === 0) return false;
            Math.random().toString().substr(0, 6);
            return _(a).reduce(function (a, c) {
                var b = c.currentX - c.startX,
                    e = c.currentY - c.startY;
                return a === false ? false : Math.abs(e / b) > 1.25 && e < -10
            }, true)
        },
        symmetricalpinch: function (a,
        c) {
            return a && a.length === 2 && c && c.scale < 0.55
        },
        zoom: function (a, c) {
            return a && a.length === 2 && c && c.scale > 2
        },
        doubleswipemove: function () {}
    }, e = function (a, c) {
        return _(a.gesture.gestureListeners).reduce(function (a, b) {
            return a + (b.gestureName === c ? 1 : 0)
        }, 0)
    }, f = function (b, e, f) {
        _(b.gesture.gestureListeners).each(function (h) {
            a[h.gestureName] !== true && c[h.gestureName](e, f) === true && h.handler.apply(b, [e, f])
        })
    }, h = function (c, b, e) {
        _(c.gesture.gestureListeners).each(function (f) {
            a[b] && f.gestureName === b && f.handler.apply(c, [e])
        })
    },
    j = function (a) {
        this.gesture.gesturing = a.touches.length > 1 ? true : false;
        if (!this.gesture.gesturing) {
            if (Pressly.Device.isNamed("RIM Playbook")) b.touchMoveBan = true, clearInterval(b.touchMoveBanTimeout), b.touchMoveBanTimeout = setTimeout(function () {
                b.touchMoveBan = false
            }, 100);
            this.gesture.verticallyLocked = false;
            this.gesture.horizontallyLocked = false;
            this.gesture.reversedVerticalDirection = false;
            this.gesture.reversedHorizontalDirection = false;
            this.gesture.directionX = void 0;
            this.gesture.directionY = void 0;
            h(this, "touchstart",
            a)
        }
    }, n = function (a) {
        this.gesture.moved = true;
        if (this.gesture.touches === null || a.touches.length > this.gesture.touches.length) {
            this.gesture.touches = [];
            for (var c = 0; c < a.touches.length; c++) this.gesture.touches[c] = {
                startX: a.touches[c].clientX,
                startY: a.touches[c].clientY,
                currentX: a.touches[c].clientX,
                currentY: a.touches[c].clientY
            }
        } else for (c = 0; c < a.touches.length; c++) this.gesture.touches[c].currentX = a.touches[c].clientX, this.gesture.touches[c].currentY = a.touches[c].clientY;
        var e;
        this.gesture.touches && (e = this.gesture.touches[0]);
        if (!this.gesture.gesturing) {
            if (b.touchMoveBan) if (Math.sqrt(Math.pow(e.currentX - e.startX, 2) + Math.pow(e.currentY - e.startY, 2)) < 2) {
                this.gesture.moved = false;
                return
            } else clearInterval(b.touchMoveBanTimeout), b.touchMoveBan = false;
            var f = c = false;
            if (this.gesture.allowAxialLockedGesturing) {
                var k = Math.abs(e.currentX - e.startX) < 15 && Math.abs(e.currentY - e.startY) > 15,
                    n = Math.abs(e.currentX - e.startX) > 15 && Math.abs(e.currentY - e.startY) < 15;
                if (k && !this.gesture.horizontallyLocked) {
                    if (!this.gesture.verticallyLocked) c = true,
                    this.gesture.verticallyLocked = true
                } else if (n && !this.gesture.verticallyLocked && !this.gesture.horizontallyLocked) f = true, this.gesture.horizontallyLocked = true
            }
            this.gesture.verticallyLocked ? c ? h(this, "touchmovevertical_start", a) : h(this, "touchmovevertical", a) : this.gesture.horizontallyLocked ? f ? h(this, "touchmovehorizontal_start", a) : h(this, "touchmovehorizontal", a) : this.gesture.allowAxialLockedGesturing ? Math.abs(e.currentX - e.startX) > 16 && h(this, "touchmove", a) : h(this, "touchmove", a)
        }
    }, k = function (a) {
        if (b.touchTapBan) clearInterval(b.touchTapBanTimeout),
        b.touchTapBanTimeout = setTimeout(function () {
            b.touchTapBan = false
        }, 450);
        if (!b.touchTapBan && !this.gesture.moved && e(this, "touchtap") > 0 && a.touches.length === 0) h(this, "touchtap", a), this.gesture.touches = null, this.gesture.moved = false;
        else if (this.gesture.gesturing === false ? this.gesture.verticallyLocked ? h(this, "touchmovevertical_end", a) : this.gesture.horizontallyLocked ? h(this, "touchmovehorizontal_end", a) : h(this, "touchend", a) : (f(this, this.gesture.touches, a), this.gesture.touches = null), a.touches.length === 0) this.gesture.moved = false, this.gesture.touches = null
    }, l = function (a) {
        b.touchTapBan = true;
        h(this, "singletouchcancel", a)
    };
    b.touchTapBanTimeout = void 0;
    b.touchTapBan = false;
    b.touchMoveBanTimeout = void 0;
    b.touchMoveBan = false;
    b.prototype = {
        createGestureListenersFromOptions: function (a, c) {
            var b = this,
                e = function (e) {
                    var f = e.substr(2).toLowerCase();
                    b.addGestureListener(f, function (c, b) {
                        if (_.isArray(c)) a[e](c, b);
                        else {
                            if (b = c) b.preventDefault(), b.stopPropagation();
                            a[e](b)
                        }
                    }, c)
                }, f;
            for (f in a) f.indexOf("on") === 0 && typeof a[f] === "function" && this.isTouchHandlerName(f.substr(2).toLowerCase()) && e(f);
            this.setGreedyGestures(true)
        },
        isTouchHandlerName: function (b) {
            var e = typeof c[b] === "function";
            return a[b] === true || e
        },
        setGreedyGestures: function (a) {
            this.gesture.gesturesAreGreedy = a
        },
        addGestureListener: function (a, c, b) {
            var b = typeof b == "undefined" ? this.element : b,
                e = $(window);
            if (this.gesture.attachedGestureListeners === false) {
                var f = this;
                if (b) f._addNativeGestureListener(b, "touchstart", function (a) {
                    e.scrollTop(1);
                    j.apply(f, arguments);
                    f.gesture.gesturesAreGreedy && (a.stopPropagation(), a.preventDefault())
                }, false), f._addNativeGestureListener(b, "touchmove", function (a) {
                    n.apply(f, arguments);
                    f.gesture.gesturesAreGreedy && (a.stopPropagation(), a.preventDefault())
                }, false), f._addNativeGestureListener(b, "touchend", function (a) {
                    k.apply(f, arguments);
                    f.gesture.gesturesAreGreedy && (a.stopPropagation(), a.preventDefault())
                }, false), f._addNativeGestureListener(b, "gesturestart", function (a) {
                    l.apply(f, arguments);
                    f.gesture.gesturesAreGreedy && (a.stopPropagation(), a.preventDefault())
                },
                false), this.gesture.attachedGestureListeners = true
            }
            if (a === "touchmovevertical" || a === "touchmovehorizontal") this.gesture.allowAxialLockedGesturing = true;
            this.gesture.gestureListeners.push({
                gestureName: a,
                handler: c
            })
        },
        _addNativeGestureListener: function (a, c, b, e) {
            this.gesture.nativeGestureListeners.push({
                name: c,
                func: b,
                element: a,
                useCapture: e
            });
            a.addEventListener(c, b, e)
        },
        removeAllGestureListeners: function () {
            _.each(this.nativeGestureListeners, function (a) {
                a.element.removeEventListener(a.name, a.func, a.useCapture)
            });
            this.gesture.nativeGestureListeners = [];
            this.gesture.gestureListeners = []
        }
    };
    Pressly.Gesture = b
})();
(function () {
    function b(a, c) {
        this.defaults = {
            pageClass: "page",
            containerClass: "page",
            pageStep: 1,
            greedySwipes: false,
            onTouchTap: null,
            swipeTransitionTime: 400
        };
        this.pageHeight = this.pageWidth = this.pageCount = this.currentPage = 0;
        this.startY = this.startX = this.targetPage = null;
        this.contentOffsetY = this.contentOffsetX = this.contentStartOffsetY = this.contentStartOffsetX = 0;
        this.direction = "horizontal";
        this.locked = false;
        this.pageChangeListeners = [];
        Pressly.Core.apply(this, arguments)
    }
    b.prototype.init = function () {
        var a = this;
        this.pageStep = parseInt(this.options.pageStep, 10);
        this.pages = $(this.element).find("." + this.options.pageClass);
        this.pageCount = this.pages.size();
        this.pageWidth = this.pages.outerWidth();
        this.pageHeight = this.pages.outerHeight();
        _(this.pages).each(function (a, c) {
            $(a).attr("data-index", c)
        });
        var c = $("<div class='pressly-swipe'>").css({
            overflow: "hidden"
        }).height(this.pageHeight);
        $(this.element).wrap(c);
        this.calculateDimensions();
        this.addGestureListener("touchstart", function (c) {
            a.moved = false;
            a.onTouchStart(c)
        });
        this.addGestureListener("touchmove", function (c) {
            a.moved = true;
            a.onTouchMove(c)
        });
        this.addGestureListener("touchend", function (c) {
            if (a.moved) a.moved = false, a.onTouchEnd(c)
        });
        this.addGestureListener("singletouchcancel", function () {
            a.snapToPage(a.currentPage)
        });
        this.createGestureListenersFromOptions(this.options);
        this.setGreedyGestures(this.options.greedySwipes);
        this.transition = new Pressly.Transition(a.element, {
            property: "transform",
            vendorPrefix: true,
            transitionEnd: function (c) {
                a.transitionEnd(c)
            }
        });
        a.pages.each(function (c) {
            c *= a.pageWidth;
            $(this).css({
                "-webkit-transition": "",
                "-webkit-transform": "translateX(" + c + "px) translateY(0px) translateZ(0px)",
                "-moz-transition": "",
                "-moz-transform": "translateX(" + c + "px) translateY(0px)"
            })
        });
        this.element.style.webkitTransform = "translateZ(0px)"
    };
    b.prototype.transitionEnd = function () {};
    b.prototype.destroy = function () {
        this.pages = void 0;
        this.removeAllPageChangeListeners();
        typeof this.removeAllGestureListeners === "function" && this.removeAllGestureListeners();
        this.transition && this.transition.destroy();
        this.transition = void 0;
        $(this.element).parent().remove()
    };
    b.prototype.addPageChangeListener = function (a) {
        this.pageChangeListeners.push(a)
    };
    b.prototype.removeAllPageChangeListeners = function () {
        this.pageChangeListeners = []
    };
    b.prototype.reset = function () {
        this.snapToPage(0)
    };
    b.prototype.lock = function () {
        this.locked = true
    };
    b.prototype.unlock = function () {
        this.locked = false
    };
    b.prototype.calculateDimensions = function () {
        this.isHorizontal() ? ($(this.element).width(this.pageCount * this.pageWidth), $(this.element).height(this.pageHeight)) : ($(this.element).width(this.pageWidth), $(this.element).height(this.pageCount * this.pageHeight))
    };
    b.prototype.setDirection = function (a) {
        this.reset();
        this.direction = a;
        this.calculateDimensions()
    };
    b.prototype.isHorizontal = function () {
        return this.direction == "horizontal"
    };
    b.prototype.gotoNextPage = function () {
        this.snapToPage(this.nextPage())
    };
    b.prototype.gotoPreviousPage = function () {
        this.snapToPage(this.previousPage())
    };
    b.prototype.nextPage = function () {
        return this.currentPage + this.pageStep > this.pageCount - this.pageStep ? this.pageCount - this.pageStep : this.currentPage + this.pageStep
    };
    b.prototype.previousPage = function () {
        return this.currentPage - this.pageStep < 0 ? 0 : this.currentPage - this.pageStep
    };
    b.prototype.isFirstPage = function () {
        return this.targetPage === 0 && this.currentPage === 0
    };
    b.prototype.isLastPage = function () {
        return this.targetPage == this.pageCount - 1 && this.currentPage == this.pageCount - 1
    };
    b.prototype.isEndOfSwipe = function () {
        return this.isFirstPage() || this.isLastPage()
    };
    b.prototype.snapToPage = function (a, c) {
        c = typeof c === "number" ? c : this.options.swipeTransitionTime;
        this.targetPage = a;
        var b, f;
        this.isHorizontal() ? (b = -this.targetPage * this.pageWidth, f = 0) : (b = 0, f = -this.targetPage * this.pageHeight);
        var h = this;
        _(this.pageChangeListeners).each(function (a) {
            typeof a === "function" && a(h.targetPage)
        });
        this.animateTo(b, f, c);
        this.currentPage = this.targetPage
    };
    b.prototype.animateTo = function (a, c, b) {
        this.contentOffsetX = a;
        this.contentOffsetY = c;
        this.transition.fire("translateX(" + a + "px) translateY(" + c + "px) translateZ(0px)", b)
    };
    b.prototype.onTouchStart = function (a) {
        if (this.locked) return false;
        this.startX = a.touches[0].clientX;
        this.startY = a.touches[0].clientY;
        this.startTime = (new Date).getTime();
        this.contentStartOffsetX = this.contentOffsetX;
        this.contentStartOffsetY = this.contentOffsetY;
        this.touchCoords = [{
            x: this.startX,
            y: this.startY,
            time: this.startTime
        }]
    };
    b.prototype.onTouchMove = function (a) {
        if (this.locked) return false;
        a.preventDefault();
        var c = a.touches[0].pageX,
            a = a.touches[0].pageY;
        this.touchCoords.push({
            x: c,
            y: a,
            time: (new Date).getTime()
        });
        this.touchCoords.length > 2 && this.touchCoords.shift();
        var b;
        this.isHorizontal() ? (this.delta = c - this.startX, c -= this.startX, this.isEndOfSwipe() && (c *= 0.5), a = c + this.contentStartOffsetX, b = 0) : (this.delta = a - this.startY, c = a - this.startY, this.isEndOfSwipe() && (c *= 0.5), a = 0, b = c + this.contentStartOffsetY);
        this.targetPage = Math.abs(c) > 0.01 * this.pageWidth ? c > 0 ? this.previousPage() : this.nextPage() : this.currentPage;
        this.animateTo(a, b)
    };
    b.prototype.onTouchEnd = function () {
        if (this.locked) return false;
        this.snapToPage(this.targetPage)
    };
    b.prototype.handleViewportChange = function () {
        var a = this.getViewport();
        this.pageStep = parseInt(a.width / this.pageWidth, 10);
        this.currentPage + this.pageStep >= this.pageCount && this.snapToPage(this.pageCount - this.pageStep, 0)
    };
    Pressly.Swipe = b
})();
(function () {
    function b(a, c) {
        this.defaults = {
            orientation: "vertical",
            allowOutOfBounds: true,
            frameRate: 100,
            wrap: true,
            addListeners: true,
            scrollbar: false,
            homeButton: false,
            snap: false,
            snapSelector: "li",
            snapThreshold: 1,
            friction: 0.5,
            settle: 0.15,
            elasticity: 5,
            dampen: 2
        };
        Pressly.Core.apply(this, arguments)
    }
    b.prototype.init = function () {
        var a = this;
        this.options.wrap && $(this.element).wrap("<div class='" + this.options.orientation + "-scroll'></div>");
        this.velocity = this.position = 0;
        this.isSnapping = this.isAnimating = this.isScrolling = false;
        this.animationTimer = null;
        this.calculateDimensions(true);
        this.transition = new Pressly.Transition(a.element, {
            property: "transform",
            vendorPrefix: true,
            transitionEnd: function () {
                if (this.state === "reset") a.position = 0, a.velocity = 0, a.stopAnimation()
            }
        });
        this.transition.fire("translateX(0px) translateY(0px) translateZ(0px)", 0);
        this.options.addListeners && (this.addGestureListener("touchstart", function (c) {
            a.onTouchStart(c)
        }), this.addGestureListener("touchmove", function (c) {
            a.onTouchMove(c)
        }), this.addGestureListener("touchend",

        function (c) {
            a.onTouchEnd(c)
        }));
        this.options.scrollbar && this.options.orientation === "vertical" && this.createScrollbar()
    };
    b.prototype.calculateDimensions = function (a) {
        var c = this;
        if (a) this.height = $(this.element).parent().innerHeight(), this.width = $(this.element).parent().innerWidth(), this.options.orientation === "vertical" && $(this.element).height() < this.height && $(this.element).height(this.height);
        this.options.orientation === "vertical" ? this.overflowHeight = $(this.element).outerHeight(true) : this.overflowWidth = $(this.element).outerWidth(true);
        this.scrollRange = this.options.orientation === "horizontal" ? this.overflowWidth - this.width : this.overflowHeight - this.height;
        this.upperBoundsLimit = this.outOfBoundsLimit = this.options.allowOutOfBounds ? (this.options.orientation === "horizontal" ? this.width : this.height) / 2 : 0;
        this.lowerBoundsLimit = -this.scrollRange - this.outOfBoundsLimit;
        if (this.options.snap) this.snapOffsets = [], $(this.element).find(this.options.snapSelector).each(function () {
            var a = c.options.orientation === "horizontal" ? this.offsetLeft : this.offsetTop;
            a <= c.scrollRange && c.snapOffsets.push(a)
        }), this.snapOffsets.indexOf(this.scrollRange) === -1 && this.snapOffsets.push(this.scrollRange)
    };
    b.prototype.beforeShow = function () {
        this.transition.fire("translateX(0px) translateY(0px) translateZ(0px)", 0, "reset")
    };
    b.prototype.onShow = function () {};
    b.prototype.onTouchStart = function (a) {
        this.animationTimer && this.stopAnimation();
        this.startPosition = this.options.orientation === "horizontal" ? a.touches[0].clientX : a.touches[0].clientY;
        this.calculateDimensions();
        this.previousTouchPosition = this.startPosition;
        this.isScrolling = true;
        this.showScrollbar()
    };
    b.prototype.onTouchMove = function (a) {
        this.currentTouchPosition = this.options.orientation === "horizontal" ? a.touches[0].pageX : a.touches[0].pageY;
        this.velocity = this.currentTouchPosition - this.previousTouchPosition;
        this.previousTouchPosition = this.currentTouchPosition;
        if (this.position > 0 && this.velocity > 0 || this.position < -this.scrollRange && this.velocity < 0) this.velocity *= 1 - Math.abs(this.position > 0 ? this.position : this.position + this.scrollRange) / this.outOfBoundsLimit;
        this.position += this.velocity;
        this.update()
    };
    b.prototype.onTouchEnd = function () {
        var a = this;
        this.isScrolling = false;
        this.isAnimating = true;
        this.animationTimer = setInterval(function () {
            a.animate()
        }, 1E3 / this.options.frameRate)
    };
    b.prototype.stopAnimation = function () {
        clearInterval(this.animationTimer);
        this.animationTimer = void 0;
        this.isSnapping = this.isAnimating = false;
        this.options.homeButton && (this.position === 0 ? this.hideHomeScrollButton() : this.showHomeScrollButton());
        this.hideScrollbar()
    };
    b.prototype.animate = function () {
        var a;
        if (this.position > 0) this.velocity <= 0 ? this.velocity = -1 * this.options.settle * Math.abs(this.position) : this.velocity -= this.options.elasticity;
        else if (this.position < -this.scrollRange) this.velocity >= 0 ? this.velocity = this.options.settle * Math.abs(this.position + this.scrollRange) : this.velocity += this.options.elasticity;
        else if (this.options.snap && Math.abs(this.velocity) <= this.options.friction) if (this.isSnapping = true, a = this.findClosestSnapOffset(), this.position > -a) this.velocity = this.velocity <= 0 ? -1 * this.options.settle * Math.abs(this.position + a) : this.options.settle * Math.abs(this.position + a);
        else {
            if (this.position < -a) this.velocity = this.velocity >= 0 ? this.options.settle * Math.abs(this.position + a) : -1 * this.options.settle * Math.abs(this.position + a)
        } else if (this.velocity -= (this.velocity > 0 ? 1 : -1) * this.options.friction, this.options.friction > Math.abs(this.velocity)) this.velocity = 0, this.options.snap || this.stopAnimation();
        this.position += this.velocity / this.options.dampen;
        if (this.position > this.upperBoundsLimit || this.position < this.lowerBoundsLimit) this.position = this.position > 0 ? this.upperBoundsLimit : this.lowerBoundsLimit, this.velocity *= -1;
        if (this.position > 0 || this.position < -this.scrollRange) {
            if (Math.abs(this.position > 0 ? this.position : this.position + this.scrollRange) < this.options.snapThreshold) this.position = this.position > 0 ? 0 : -this.scrollRange, this.velocity = 0, this.stopAnimation()
        } else if (this.isSnapping && Math.abs(this.position + a) < this.options.snapThreshold) this.position = -a, this.velocity = 0, this.stopAnimation();
        this.update()
    };
    b.prototype.update = function () {
        this.transition.fire(this.options.orientation === "horizontal" ? "translateX(" + this.position + "px) translateY(0px) translateZ(0px)" : "translateX(0px) translateY(" + this.position + "px) translateZ(0px)", 0);
        this.updateScrollbar()
    };
    b.prototype.hideScrollbar = function () {
        this.options.scrollbar && this.scrollbarTransition.off()
    };
    b.prototype.showScrollbar = function () {
        if (this.options.scrollbar) this.scrollbarTransition.on()
    };
    b.prototype.hideHomeScrollButton = function () {
        this.options.homeButton && this.homeScrollButtonTransition.off()
    };
    b.prototype.showHomeScrollButton = function () {
        if (this.options.homeButton) this.homeScrollButtonTransition.on()
    };
    b.prototype.updateScrollbar = function () {
        if (this.options.scrollbar && this.options.orientation === "vertical") {
            var a = -1 * (this.position / this.scrollRange),
                c;
            c = this.options.homeButton ? this.height - this.scrollbar.height() - (this.homeScrollButtonSize + this.homeScrollButtonMargin * 2 + this.homeScrollButtonSpacing) : this.height - this.scrollbar.height() - 15;
            a = Math.max(0, Math.min(c,
            a * c));
            if (this.position > 0 || this.position < -this.scrollRange) {
                c = 1 - Math.abs(this.position > 0 ? this.position : this.position + this.scrollRange) / this.outOfBoundsLimit;
                var b = Math.min(this.height - 4, this.height / this.overflowHeight * this.height);
                this.scrollbar.height(Math.max(4, b * c))
            }
            this.scrollbar.css({
                "-webkit-transform": "translateX(0px) translateY(" + a + "px) translateZ(0px)"
            })
        }
    };
    b.prototype.createScrollbar = function () {
        var a = this;
        this.scrollbar = $("<div class='vertical-scroll-bar' />").css({
            backgroundColor: "#000000",
            "border-radius": 2.5,
            width: "5px",
            opacity: 0.3,
            top: "0px",
            height: Math.min(this.height - 4, this.height / this.overflowHeight * this.height) + "px"
        });
        this.scrollbarTransition = new Pressly.Transition(this.scrollbar.get(0), {
            property: "opacity",
            on: 0.3,
            off: 0,
            duration: 400
        });
        this.hideScrollbar();
        $(this.element).parent().append(this.scrollbar);
        if (this.options.homeButton) this.homeScrollButtonSpacing = 10, this.homeScrollButtonMargin = 7, this.homeScrollButtonSize = 29, this.homeScrollButton = $("<div class='vertical-scroll-home' />").css({
            width: this.homeScrollButtonSize + "px",
            height: this.homeScrollButtonSize + "px"
        }), this.homeScrollActionBox = new Pressly.Box(this.homeScrollButton.get(0), {}), this.homeScrollActionBox.addAction(function () {
            a.transition.fire("translateX(0px) translateY(0px) translateZ(0px)", 300, "reset");
            a.hideHomeScrollButton()
        }), this.homeScrollButtonTransition = new Pressly.Transition(this.homeScrollButton.get(0), {
            property: "opacity",
            on: 1,
            off: 0,
            duration: 400
        }), this.hideHomeScrollButton(), $(this.element).parent().append(this.homeScrollButton)
    };
    b.prototype.findClosestSnapOffset = function () {
        var a = this,
            c = _(this.snapOffsets).map(function (c) {
                return Math.abs(c + a.position)
            });
        return this.snapOffsets[c.indexOf(Math.min.apply(this, c))]
    };
    b.prototype.destroy = function () {
        if (this.scrollbar) this.scrollbar.remove(), this.scrollbar = void 0;
        if (this.homeScrollButton) this.homeScrollButton.remove(), this.homeScrollButton = void 0
    };
    Pressly.Scroll = b
})();
(function () {
    function b(a, c, b) {
        this.defaults = {
            pageClass: "page"
        };
        this.rendered = this.loading = this.loaded = false;
        var f = this.options && typeof this.options.pageClass == "string" ? this.options.pageClass : this.defaults.pageClass;
        c ? (this.pageId = c.pageId, this.pageIndex = c.pageIndex, this.sectionId = c.sectionId, this.sectionIndex = c.sectionIndex, this.childrenIds = c.childrenIds, this.index = c.index, this.url = c.url, this.title = c.title, this.fullscreen = c.fullscreen, this.hasAd = c.ad, this.selector = c.selector, this.needsActionAttachOnInit = false, a = $("<div class='loading'><img src='img/spinner.gif' class='spinner' /></div>").addClass(f).attr("id", c.id).get(0)) : b && typeof b.contentLoader === "function" ? (this.index = b.index, this.needsActionAttachOnInit = false, this.pageId = b.pageId, a || (a = $("<div class='loading'><img src='img/spinner.gif' class='spinner' /></div>").addClass(f).attr("id", b.id).get(0))) : (this.needsActionAttachOnInit = this.loaded = true, this.index = $(a).index());
        this.index >= 0 === false && console.error("Page requires a valid index");
        this.id = $(a).attr("id");
        Pressly.Core.call(this, a, b)
    }
    b.Cache = {};
    b.destroyCache = function () {
        b.Cache = void 0
    };
    b.pages = [];
    b.prototype.init = function () {
        this.needShow = false;
        this.needBeforeShow = true;
        $(this.element).attr("data-index", this.index);
        this.needsActionAttachOnInit && this.attachActions();
        if (typeof this.options.prepend === "function") this.options.prepend = _.bind(this.options.prepend, this);
        this.updateViewportState();
        b.pages.push(this)
    };
    b.prototype.isFullscreen = function () {
        return this.fullscreen
    };
    b.prototype.isAdPage = function () {
        return typeof this.id === "string" && this.id.indexOf("ad") === 0
    };
    b.prototype.isArticle = function () {
        return this.selector === ".article"
    };
    b.prototype.load = function (a, c) {
        this.callback = a;
        if (!this.isLoading())!this.isLoaded() || c ? this.hasCache() ? this.setContent() : (this.loading = true, typeof this.options.contentLoader === "function" ? this.finishedLoading(this.options.contentLoader(this)) : $.ajax({
            url: this.url,
            type: "GET",
            dataType: "html",
            success: _.bind(this.finishedLoading, this)
        })) : typeof a === "function" && a(this)
    };
    b.prototype.initPageComponents = function () {
        this.isArticle() ? this.initializeArticle() : (this.isAdPage() || Pressly.Ad.pageHasBigBoxAds(this)) && this.initializeAd()
    };
    b.prototype.initializeArticle = function () {
        if (!this.article) this.article = new Pressly.Article(this.element)
    };
    b.prototype.initializeAd = function () {
        if (this.ad) this.hasViewportMismatch() && this.ad.handleViewportChange();
        else {
            var a, c;
            this.id ? (a = this.isAdPage() ? "fullscreen" : "page", c = this.id) : (a = "article", c = window.issue.router.articleLayer.pages.currentPage.id);
            this.ad = new Pressly.Ad(this.element, {
                context: {
                    contextType: a,
                    contextId: c
                }
            })
        }
        this.updateViewportState()
    };
    b.prototype.beforeShow = function () {
        this.isLoaded() || this.hasCache() && this.setContent();
        if (this.isLoaded()) this.trimArticles(), this.calcRelativeDate(), this.initPageComponents(), this.article && this.article.beforeShow(), this.ad && this.ad.beforeShow(), this.needBeforeShow = false
    };
    b.prototype.onShow = function () {
        if (this.isLoaded()) {
            if (this.needBeforeShow) this.beforeShow(), this.needBeforeShow = true;
            this.hasViewportMismatch() && this.handleViewportChange();
            this.trimArticles();
            this.calcRelativeDate();
            if (this.article) this.article.onShow();
            if (this.ad) this.ad.onShow();
            _(this.actionBoxes).each(function (a) {
                a.onShow()
            });
            this.updateViewportState();
            this.rendered = true
        } else this.needShow = true
    };
    b.prototype.trimArticles = function () {
        if (typeof this.options.isTrimmable === "function" && this.options.isTrimmable()) {
            var a = $(this.element).find("article[data-format='trim']"),
                c = this.getViewport().toString();
            a.each(function () {
                var a = $(this);
                a.data("viewport") !== c && (Pressly.Util.trimArticle(a), a.data("viewport", c))
            })
        }
    };
    b.prototype.calcRelativeDate = function () {
        $(this.element).find(".timestamp:not(.no-timeago)").each(function () {
            Pressly.Util.timeago(this, 864E5)
        })
    };
    b.prototype.beforeHide = function () {};
    b.prototype.onHide = function () {
        if (this.isLoaded()) {
            if (this.article) this.article.onHide();
            else if ((this.isAdPage() || Pressly.Ad.pageHasBigBoxAds(this)) && this.ad) this.ad.onHide();
            _(this.actionBoxes).each(function (a) {
                a.onHide()
            })
        }
    };
    b.prototype.isRendered = function () {
        return this.rendered === true
    };
    b.prototype.isLoaded = function () {
        return this.loaded
    };
    b.prototype.isLoading = function () {
        return this.loading
    };
    b.prototype.finishedLoading = function (a) {
        if (this.destroyed !== true) {
            if (!this.hasCache()) {
                if (typeof a === "string") {
                    var c = $("<wrap></wrap>");
                    c.get(0).innerHTML = a;
                    a = c.find("div." + this.options.pageClass).attr("data-index", this.index);
                    c = c.find("div.body[data-format=textflow]");
                    _(c).each(function (a) {
                        $(a).attr("data-original-content", $(a).html());
                        $(a).html("")
                    })
                }
                this.setCache(a)
            }
            this.setContent()
        }
    };
    b.prototype.setCache = function (a) {
        b.Cache[this.options.cache ? this.id : this.pageId] = a
    };
    b.prototype.getCache = function () {
        return this.options.cache ? b.Cache[this.id] : b.Cache[this.pageId]
    };
    b.prototype.deleteCache = function () {
        (this.selector === ".page" || this.options.cache) && delete b.Cache[this.id]
    };
    b.prototype.hasCache = function () {
        return this.getCache() !== void 0
    };
    b.getCachedContent = function (a, c) {
        if (b.Cache[a]) return typeof c === "string" ? b.Cache[a].find(c) : b.Cache[a];
        else throw "Could not find cached page with id: " + a;
    };
    b.clearOrphanedCache = function () {
        if (window.issue.router && window.issue.router.articleLayer && window.issue.router.articleLayer.isActive()) {
            var a = _(window.issue.router.manifest.manifestCache).select(function (a) {
                return a.selector === ".page" && a.childrenIds.length > 0 && b.Cache.hasOwnProperty(a.id)
            }).map(function (a) {
                return a.id
            }),
                c = _(window.issue.router.articleLayer.stack).select(function (a) {
                    return a !== null
                }).map(function (a) {
                    return a.pageId
                });
            _(a).each(function (a) {
                c.indexOf(a) === -1 && delete b.Cache[a]
            })
        }
    };
    b.prototype.setContent = function () {
        var a = this.getCache().clone(true, true);
        _(this.childrenIds).each(function (c) {
            a.find("#" + c).remove()
        });
        var c = $(this.element);
        c.find(".spinner").remove();
        c.attr("class", a.attr("class"));
        if (typeof this.options.prepend === "function") {
            var b = this.options.prepend();
            b && c.prepend(b)
        }
        switch (this.selector) {
        case ".article":
            a.find("#" + this.id).find("> *").each(function (a, b) {
                c.append(b)
            });
            break;
        default:
        case ".page":
            a.find("> *").each(function (a, b) {
                c.append(b)
            })
        }
        this.attachActions();
        this.loaded = true;
        this.loading = false;
        this.trimArticles();
        if (this.needShow && window.issue.router.pageLayer.pages.currentPage === this) this.onShow();
        typeof this.callback === "function" && this.callback(this)
    };
    b.prototype.attachActions = function () {
        var a = this;
        if (!this.actionsAlreadyAttached) this.actionBoxes = [], $(this.element).find("[data-action]").each(function (c, b) {
            $(b).data("box-initialized") !== true && a.actionBoxes.push(new Pressly.Box(b, {
                page: a
            }))
        }), this.actionsAlreadyAttached = true
    };
    b.prototype.handleViewportChange = function () {
        this.isLoaded() && this.hasViewportMismatch() && $(this.element).is(":visible") && (this.trimArticles(), _(this.actionBoxes).each(function (a) {
            a.handleViewportChange()
        }), this.article && this.article.handleViewportChange(), this.ad && this.ad.handleViewportChange(), this.updateViewportState())
    };
    b.analyze = function () {
        Pressly.Util.analyze(b, "pages")
    };
    b.prototype.destroy = function () {
        this.destroyed = true;
        if (this.actionBoxes) for (var a = 0; a < this.actionBoxes.length; a++) this.actionBoxes[a].destroy();
        this.actionBoxes = void 0;
        if (this.article) this.article.destroy(), this.article = void 0;
        if (this.ad) this.ad.destroy(), this.ad = void 0;
        this.deleteCache();
        this.options = void 0;
        $(this.element).remove();
        this.element = void 0;
        a = b.pages.indexOf(this);
        a !== -1 && b.pages.splice(a, 1)
    };
    Pressly.Page = b
})();
(function () {
    function b(a, c) {
        this.defaults = {
            pageClass: "page",
            containerClass: "page",
            pageStep: 1,
            greedySwipes: false,
            touchTravelThreshold: 0.01,
            swipeTransitionTime: 400,
            pageBufferSize: 3,
            direction: "x"
        };
        this.pageSize = {
            x: 0,
            y: 0
        };
        this.currentIndex = 0;
        this.touchCoords = this.delta = this.startY = this.startX = this.oldIndex = this.targetIndex = null;
        this.syncSlaves = [];
        this.afterPageTasks = [];
        this.stack = [];
        this.locked = false;
        this.pageChangeListeners = [];
        this.beforePageChangeListeners = [];
        Pressly.Core.apply(this, arguments)
    }
    b.maxCoordinatesToSample = 2;
    b.prototype.init = function () {
        var a = this;
        this.active = this.options.active || false;
        this.pageStep = parseInt(a.options.pageStep, 10);
        this.initPages(function () {
            a.createWrapper();
            a.options.disableGestures || a.initializeGestures();
            a.transition = new Pressly.Transition(a.element, {
                property: "transform",
                vendorPrefix: true,
                transitionEnd: function (c) {
                    a.transitionEnd(c)
                }
            });
            typeof a.options.success === "function" && setTimeout(function () {
                a.options.success(a)
            }, 0);
            a.displayStack()
        })
    };
    b.prototype.transitionEnd = function (a) {
        a && a.target !== this.element || (this.displayStack(), this.executeAfterPageTasks())
    };
    b.prototype.reset = function () {
        var a = this;
        this.currentIndex = 0;
        this.targetIndex = null;
        this.initPages(function () {
            a.displayStack()
        })
    };
    b.prototype.handleViewportChange = function () {
        var a = this.getViewport();
        this.pageSize = {
            x: a.width,
            y: a.height
        };
        this.isActive() && (this.pages.eachLoaded(function (a) {
            a.handleViewportChange()
        }), this.arrangeStack(this.getStack(this.currentIndex), this.currentIndex))
    };
    b.prototype.isPageOnStack = function (a) {
        return this.stack.indexOf(a) > -1
    };
    b.prototype.addAfterPageTask = function (a) {
        this.afterPageTasks.push(a)
    };
    b.prototype.executeAfterPageTasks = function () {
        var a = this.afterPageTasks;
        this.afterPageTasks = [];
        for (var c = 0; c < a.length; c++) a[c]()
    };
    b.prototype.createWrapper = function () {
        this.wrapper = $("<div class='pressly-paging'>");
        $(this.element).wrap(this.wrapper)
    };
    b.prototype.initializeGestures = function () {
        var a = this;
        a.addGestureListener("touchstart", function (c) {
            a.onTouchStart(c)
        });
        a.addGestureListener("touchmove", function (c) {
            a.onTouchMove(c)
        });
        a.addGestureListener("touchend", function (c) {
            a.onTouchEnd(c)
        });
        if (this.options.allowVerticalScrolling === true) {
            var c = $(this.element).find(".vertical-scroll > .body").get(0);
            if (c) this.verticalScroller = new Pressly.Scroll(c, {
                wrap: false,
                snap: false,
                addListeners: false,
                frameRate: 150,
                scrollbar: true
            }), this.addGestureListener("touchmovevertical_start", function (c) {
                a.verticalScroller.onTouchStart(c)
            }), this.addGestureListener("touchmovevertical", function (c) {
                a.verticalScroller.onTouchMove(c)
            }), this.addGestureListener("touchmovevertical_end",

            function (c) {
                a.verticalScroller.onTouchEnd(c)
            }), this.addGestureListener("touchmovehorizontal_start", function (c) {
                a.onTouchStart(c)
            }), this.addGestureListener("touchmovehorizontal", function (c) {
                a.onTouchMove(c)
            }), this.addGestureListener("touchmovehorizontal_end", function (c) {
                a.onTouchEnd(c)
            })
        }
        a.createGestureListenersFromOptions(a.options);
        a.setGreedyGestures(a.options.greedySwipes);
        a.addGestureListener("singletouchcancel", function (c) {
            a.onSingleTouchCancel(c)
        })
    };
    b.prototype.getCurrentPage = function () {
        return this.currentIndex
    };
    b.prototype.initPages = function (a) {
        var c = this,
            b = $(c.element);
        (function () {
            var a = [];
            c.pages = {
                create: function (b, e) {
                    var f;
                    if (c.options.resettable) a.push(void 0);
                    else {
                        var l = {
                            pagingName: c.options.name
                        };
                        if (c.options.trimmable) l.isTrimmable = function () {
                            return c.isPageOnStack(f)
                        };
                        f = new Pressly.Page(b, e, l);
                        a.push(f)
                    }
                    return f
                },
                createAt: function (f, n, k) {
                    var l = {
                        resetable: true,
                        pagingName: c.options.name
                    };
                    if (c.options.trimmable) l.isTrimmable = function () {
                        return c.isPageOnStack(i)
                    };
                    if (typeof c.options.prepend === "function") l.prepend = c.options.prepend;
                    var i = new Pressly.Page(void 0, k, l);
                    n ? b.append(i.element) : b.prepend(i.element);
                    return a[f] = i
                },
                add: function (c) {
                    a.push(c);
                    return c
                },
                eachLoaded: function (c) {
                    for (var b = 0; b < a.length; b++) a[b] && c(a[b], b)
                },
                destroyPage: function (c) {
                    if (c !== null && typeof c !== "undefined") for (var b = 0; b < a.length; b++) if (a[b] === c) {
                        c = $(a[b].element);
                        a[b].destroy();
                        c.remove();
                        a[b] = void 0;
                        break
                    }
                },
                destroy: function () {
                    for (var c = 0; c < a.length; c++) a[c] && a[c].destroy();
                    a = void 0
                },
                get: function (c) {
                    return a[c]
                },
                getById: function (c) {
                    return _(a).detect(function (a) {
                        if (a) return a.id === c
                    })
                },
                select: function (c) {
                    return _(a).select(c)
                },
                detect: function (c) {
                    return _(a).detect(c)
                },
                collection: function () {
                    return a
                }
            };
            Object.defineProperty(c.pages, "length", {
                get: function () {
                    return a.length
                }
            });
            Object.defineProperty(c.pages, "currentPage", {
                get: function () {
                    return a[c.currentIndex]
                }
            });
            Object.defineProperty(c.pages, "currentElement", {
                get: function () {
                    return c.pages.currentPage ? c.pages.currentPage.element : void 0
                }
            });
            Object.defineProperty(c.pages, "previousPage", {
                get: function () {
                    return a[c.currentIndex - 1]
                }
            });
            Object.defineProperty(c.pages, "nextPage", {
                get: function () {
                    return a[c.currentIndex + 1]
                }
            });
            Object.defineProperty(c.pages, "all", {
                get: function () {
                    return $(_(a).map(function (a) {
                        return a.element
                    }))
                }
            })
        })();
        this.options.pages ? _(this.options.pages).each(function (a) {
            c.pages.add(a);
            b.append(a.element)
        }) : this.options.manifestItems ? _(this.options.manifestItems).each(function (a) {
            a = c.pages.create(void 0, a);
            c.options.resettable || b.append(a.element)
        }) : this.options.pageClass && b.find("." + this.options.pageClass).each(function () {
            $(this).data("content") ? c.pages.create(this, void 0, $(this).data("content")) : c.pages.create(this)
        });
        var f = this.getViewport();
        this.pageSize = {
            x: f.width,
            y: f.height
        };
        this.loadStack(this.currentIndex, a)
    };
    b.prototype.loadStack = function (a, c) {
        var b = this;
        if (typeof a !== "number") a = this.currentIndex;
        for (var f = [], h = Math.floor(this.options.pageBufferSize / 2), j = a - h; j <= a + h; j++) j > -1 && j < this.pages.length && f.push(j);
        var n = 0;
        this.options.resettable === true && this.getStack(a);
        _(f).each(function (a) {
            b.options.resettable === true && b.pages.get(a);
            b.pages.get(a).load(function () {
                n++;
                typeof b.options.progress === "function" && b.options.progress(n / f.length);
                n === f.length && typeof c === "function" && c()
            })
        })
    };
    b.prototype.getStack = function (a) {
        var c = this,
            b = function (a, b) {
                return c.isFirstPage(a + 1) || c.isLastPage(a - 1) ? null : typeof c.pages.get(a) === "undefined" ? c.pages.createAt(a, b, c.options.manifestItems[a]) : c.pages.get(a)
            };
        return this.options.resettable ? [b(a - 1, 0), b(a, 1), b(a + 1, 2)] : [this.isFirstPage(a) ? null : this.pages.get(a - 1), this.pages.get(a), this.isLastPage(a) ? null : this.pages.get(a + 1)]
    };
    b.prototype.displayStack = function () {
        var a = this.targetIndex === null ? this.currentIndex : this.targetIndex;
        $(this.element).css("-webkit-transition", "");
        $(this.element).css("-webkit-transform", "translateX(0px) translateY(0px) translateZ(0px)");
        $(this.element).css("-moz-transition", "");
        $(this.element).css("-moz-transform", "translateX(0px) translateY(0px)");
        this.arrangeStack(this.getStack(a), a);
        this.options.name === "articleLayer" && Pressly.Page.clearOrphanedCache();
        this.afterPageChange()
    };
    b.prototype.arrangeStack = function (a, c) {
        for (var b = this, f = [], h = 0; h < a.length; h++) {
            var j = a[h];
            if (j !== null) {
                for (var n = false, k = 0; k < this.stack.length; k++) j === this.stack[k] && (n = true);
                n === false && f.push(j)
            }
        }
        _(this.stack).each(function (c) {
            if (c !== null) {
                for (var f = false, h = 0; h < 3; h++) {
                    var k = a[h];
                    if (k && k === c) {
                        f = true;
                        break
                    }
                }
                f || (b.options.resettable ? b.pages.destroyPage(c) : $(c.element).hide())
            }
        });
        _(a).each(function (a) {
            a !== null && $(a.element).removeClass("current")
        });
        $(a[1].element).addClass("current");
        this.stack = a;
        _(a).each(function (a, f) {
            var h = c + (f - 1);
            if (a !== null) {
                var h = $(b.pages.get(h).element),
                    k = b.getXYTransformForPage(f - 1);
                h.show().css({
                    "-webkit-transform": k + " translateZ(0px)",
                    "-moz-transform": k,
                    "-webkit-backface-visibility": "hidden"
                });
                b.isActive() && f !== 1 && a.beforeShow()
            }
        })
    };
    b.prototype.getXYTransformForPage = function (a) {
        return this.options.direction === "x" ? "translateX(" + this.pageSize.x * a + "px) translateY(0px)" : "translateX(0px) translateY(" + this.pageSize.y * a + "px)"
    };
    b.prototype.addPageChangeListener = function (a) {
        this.pageChangeListeners.push(a)
    };
    b.prototype.addBeforePageChangeListener = function (a) {
        this.beforePageChangeListeners.push(a)
    };
    b.prototype.lock = function () {
        if (this.options.unlockable !== true) this.locked = true
    };
    b.prototype.unlock = function () {
        this.locked = false
    };
    b.prototype.nextPage = function () {
        return this.currentIndex + this.pageStep >= this.pages.length ? this.currentIndex : this.currentIndex + this.pageStep
    };
    b.prototype.previousPage = function () {
        return this.currentIndex - this.pageStep < 0 ? this.currentIndex : this.currentIndex - this.pageStep
    };
    b.prototype.gotoNextPage = function (a) {
        this.snapToPage(this.nextPage(),
        void 0, a)
    };
    b.prototype.gotoPreviousPage = function (a) {
        this.snapToPage(this.previousPage(), void 0, a)
    };
    b.prototype.snapToPage = function (a, c, b) {
        function f(c) {
            var c = c === "before" ? -1 : 1,
                b = h.pages.get(a),
                e = h.getXYTransformForPage(c * 2);
            $(b.element).show().css({
                "-webkit-transform": e + " translateZ(0)",
                "-moz-transform": e,
                "-webkit-backface-visibility": "hidden"
            });
            h.stack.push(b);
            return -(c * h.pageSize[h.options.direction] * 2)
        }
        var h = this,
            j = {
                x: 0,
                y: 0
            }, c = typeof c === "number" ? c : this.options.swipeTransitionTime;
        if (!this.locked && !(a < 0 || a > this.pages.length - 1)) typeof b === "function" && this.addAfterPageTask(b), this.targetIndex = a, this.beforePageChange(), c === 0 ? this.transitionEnd() : (j[this.options.direction] = a === this.currentIndex ? 0 : Math.abs(a - this.currentIndex) <= 1 ? a < this.currentIndex ? this.pageSize[this.options.direction] : -this.pageSize[this.options.direction] : a < this.currentIndex ? f("before") : f("after"), _(this.syncSlaves).each(function (a) {
            typeof a.beforeShow === "function" && a.beforeShow(h.currentIndex, h.targetIndex)
        }), this.animateTo(j.x,
        j.y, c))
    };
    b.prototype.animateTo = function (a, c, b) {
        this.transition.fire("translateX(" + a + "px) translateY(" + c + "px) translateZ(0px)", b)
    };
    b.prototype.beforePageChange = function () {
        var a = this.oldIndex === null;
        if (this.isActive() && (a || this.targetIndex !== this.currentIndex)) {
            (a = this.pages.get(this.targetIndex)) && a.beforeShow();
            this.loadStack(this.targetIndex);
            var c = this.currentIndex,
                b = this.targetIndex;
            _(this.beforePageChangeListeners).each(function (a) {
                typeof a === "function" && a(c, b)
            })
        }
    };
    b.prototype.afterPageChange = function () {
        var a = this;
        if (this.targetIndex === null) this.targetIndex = this.currentIndex;
        var c = this.currentIndex,
            b = this.targetIndex,
            f = this.oldIndex === null;
        this.oldIndex = this.currentIndex;
        this.currentIndex = this.targetIndex;
        this.targetIndex = null;
        this.resetTouchState();
        if (this.isActive() && (f || this.oldIndex !== this.currentIndex)) {
            if (f = this.pages.get(this.oldIndex)) f.onHide();
            this.pages.currentPage.onShow();
            _(this.pageChangeListeners).each(function (a) {
                typeof a === "function" && a(b, c)
            });
            typeof this.options.tracker === "function" && this.options.tracker(["page", "navigate", "pageObject", this.pages.currentPage])
        }
        _(this.syncSlaves).each(function (c) {
            if (typeof c.onShow === "function") c.onShow(a.currentIndex)
        })
    };
    b.prototype.beforeShow = function () {
        this.lock();
        this.arrangeStack(this.getStack(this.currentIndex), this.currentIndex);
        this.pages.currentPage.beforeShow();
        this.verticalScroller && this.verticalScroller.beforeShow()
    };
    b.prototype.onShow = function () {
        this.unlock();
        $(this.element).removeClass("events_locked");
        this.active = true;
        this.arrangeStack(this.getStack(this.currentIndex), this.currentIndex);
        this.pages.currentPage.onShow();
        if (this.verticalScroller) this.verticalScroller.onShow()
    };
    b.prototype.beforeHide = function () {
        this.lock();
        $(this.element).addClass("events_locked");
        this.stack[0] !== null && typeof this.stack[0] !== "undefined" && $(this.stack[0].element).hide();
        this.stack[2] !== null && typeof this.stack[2] !== "undefined" && $(this.stack[2].element).hide()
    };
    b.prototype.onHide = function () {
        this.lock();
        this.pages.currentPage.onHide();
        $(this.stack[1].element).hide();
        this.active = false
    };
    b.prototype.isActive = function () {
        return this.active
    };
    b.prototype.isFirstPage = function (a) {
        return (typeof a === "undefined" ? this.currentIndex : a) === 0
    };
    b.prototype.isLastPage = function (a) {
        return (typeof a === "undefined" ? this.currentIndex : a) === this.pages.length - 1
    };
    b.prototype.isEndOfSwipe = function () {
        return this.isFirstPage() || this.isLastPage()
    };
    b.prototype.isSwiping = function () {
        return this.targetIndex !== null
    };
    b.prototype.syncSlave = function (a) {
        this.syncSlaves.push(a)
    };
    b.prototype.onTouchStart = function (a) {
        var c = this;
        this.slaving = false;
        if (this.locked) return false;
        this.isSwiping() && this.snapToPage(this.targetIndex, 0);
        if (this.options.parent && this.options.parent.isSwiping()) return this.options.parent.snapToPage(this.options.parent.targetIndex, 0), false;
        this.startX = a.touches[0].clientX;
        this.startY = a.touches[0].clientY;
        this.startTime = (new Date).getTime();
        this.touchCoords = [{
            x: this.startX,
            y: this.startY,
            time: this.startTime
        }];
        _(this.syncSlaves).each(function (a) {
            a.paging.slaving = true;
            a.paging.startX = c.startX;
            a.paging.startY = c.startY;
            a.paging.startTime = c.startTime;
            a.paging.touchCoords = [{
                x: c.startX,
                y: c.startY,
                time: c.startTime
            }]
        })
    };
    b.prototype.sampleTouchCoordinates = function (a, c) {
        this.touchCoords.push({
            x: a,
            y: c,
            time: (new Date).getTime()
        });
        this.touchCoords.length > b.maxCoordinatesToSample && this.touchCoords.splice(0, 1)
    };
    b.prototype.onTouchMove = function (a) {
        var c = this;
        if (this.locked || !this.touchCoords) return false;
        if (this.isSwiping()) return false;
        if (this.options.parent && this.options.parent.isSwiping()) return false;
        var e = a.touches[0].pageX,
            f = a.touches[0].pageY;
        this.sampleTouchCoordinates(e, f);
        this.delta = this.options.direction === "x" ? e - this.startX : f - this.startY;
        _(this.syncSlaves).each(function (b) {
            if (b.toggleFunction({
                delta: c.delta,
                currentIndex: c.currentIndex,
                targetIndex: c.targetIndex
            })) b.paging.onTouchMove(a)
        });
        if (this.isFirstPage() && this.delta > 0 || this.isLastPage() && this.delta < 0) if (this.options.parent instanceof b) return;
        else this.delta *= 0.5;
        this.options.direction === "x" ? this.animateTo(this.delta, 0) : this.animateTo(0,
        this.delta)
    };
    b.prototype.onTouchEnd = function () {
        var a = this;
        if (this.locked || !this.touchCoords) return false;
        if (this.isSwiping()) return false;
        if (this.options.parent && this.options.parent.isSwiping()) return false;
        var c, e, f, h;
        if (this.touchCoords.length >= 2) {
            h = this.delta;
            e = this.touchCoords[this.touchCoords.length - 1][this.options.direction] - this.touchCoords[0][this.options.direction];
            c = this.touchCoords[this.touchCoords.length - 1].time - this.touchCoords[0].time;
            c = Math.min(850, Math.max(400, 100 + Math.abs(h / (e / c)) * 3));
            var j = this.pageSize[this.options.direction],
                n = Math.abs(e) > this.options.touchTravelThreshold * j;
            f = n ? Math.abs(h) > j / 2 && (h > 0 && e < 0 || h < 0 && e > 0) ? this.currentIndex : e > 0 ? this.previousPage() : this.nextPage() : Math.abs(h) > j / 2 ? h > 0 ? this.previousPage() : this.nextPage() : this.currentIndex;
            if (this.options.parent instanceof b) if (this.isFirstPage() && h > 0 && e < 0 || this.isLastPage() && h < 0 && e > 0) f !== this.currentIndex && (this.options.parent.resetTouchState(), this.options.parent.animateTo(0, 0));
            else if (n && (this.isFirstPage() && e > 0 || this.isLastPage() && e < 0)) {
                _(this.syncSlaves).each(function (c) {
                    if (c.toggleFunction({
                        delta: h,
                        currentIndex: a.currentIndex,
                        targetIndex: f
                    })) c.paging.onTouchEnd()
                });
                this.resetTouchState();
                this.animateTo(0, 0);
                return
            }
            _(this.syncSlaves).each(function (c) {
                if (c.toggleFunction({
                    delta: h,
                    currentIndex: a.currentIndex,
                    targetIndex: f
                })) c.paging.onTouchEnd()
            });
            this.snapToPage(f, c)
        } else this.resetTouchState()
    };
    b.prototype.resetViewport = function (a) {
        this.animateTo(0, 0, typeof a === "number" ? a : this.options.swipeTransitionTime)
    };
    b.prototype.resetSlaveViewports = function (a) {
        _(this.syncSlaves).each(function (c) {
            c.paging.resetViewport(a)
        })
    };
    b.prototype.onSingleTouchCancel = function () {
        var a = this;
        _(this.syncSlaves).each(function (c) {
            if (c.toggleFunction({
                delta: a.delta
            })) c.paging.onSingleTouchCancel()
        });
        this.resetViewport();
        this.resetTouchState()
    };
    b.prototype.resetTouchState = function () {
        this.touchCoords = this.delta = this.targetIndex = null;
        this.slaving = false
    };
    b.prototype.destroy = function () {
        if (this.pages) this.pages.destroy(), this.pages = void 0;
        if (this.transition) this.transition.destroy(), this.transition = void 0;
        typeof this.removeAllGestureListeners === "function" && this.removeAllGestureListeners();
        this.beforePageChangeListeners = this.pageChangeListeners = void 0;
        if (this.syncSlaves) this.syncSlaves = void 0;
        this.wrapper = this.stack = void 0;
        $(this.element).parent().is(".pressly-paging") ? $(this.element).parent().remove() : $(this.element).remove();
        this.verticalScroller && this.verticalScroller.destroy();
        this.options = this.element = void 0
    };
    Pressly.Paging = b
})();
(function () {
    function b(a, c) {
        this.defaults = {
            split: "sentences",
            asynchronousTimeoutLength: 25
        };
        Pressly.Core.apply(this, arguments)
    }
    function a(a, c) {
        var b = 0,
            e = function (a, c) {
                a = a.jquery ? a[0] : a;
                return _(a.childNodes).reduce(function (a, f) {
                    var h;
                    f.nodeType === Node.TEXT_NODE ? (typeof f.nodeValue === "string" && (b === 0 && (f.nodeValue += c), h = _(f.nodeValue.split(c)).reduce(function (a, e, f, h) {
                        var i = a.length === 0 ? 0 : a[a.length - 1].pos;
                        return f == h.length - 1 ? a : a.concat([{
                            textNodeIndex: b,
                            pos: i + e.length + c.length
                        }])
                    }, [])), b++) : h = e(f,
                    c);
                    return a.concat(h)
                }, [])
            }, f = e(a, c);
        f.unshift({
            textNodeIndex: 0,
            pos: 0
        });
        return f
    }
    function c(a, c, b) {
        var e = function () {
            var a = false,
                b = [],
                e = 0,
                f = function (h) {
                    if (h.nodeType === Node.TEXT_NODE && c.textNodeIndex === e && !a) h.nodeValue = h.nodeValue.substr(0, c.pos), a = true;
                    _(h.childNodes).each(function (c) {
                        a === true ? b.push(c) : f(c);
                        c.nodeType === Node.TEXT_NODE && e++
                    })
                };
            return function (a) {
                a = $(a).clone()[0];
                f(a);
                _(b).each(function (a) {
                    a.parentNode && a.parentNode.removeChild(a)
                });
                return a
            }
        }(),
            f = function () {
                var a = 0,
                    b = false,
                    e = [],
                    f = function (h) {
                        if (b === false) {
                            if (h.nodeType === Node.TEXT_NODE && c.textNodeIndex === a) {
                                h.nodeValue = h.nodeValue.substr(c.pos);
                                var i = _($(h).parents()).chain().push(h).value();
                                _(i).each(function (a) {
                                    a = _(e).indexOf(a);
                                    a > -1 && e.splice(a, 1)
                                });
                                b = true
                            }
                            _(h.childNodes).each(function (c) {
                                b !== true && (e.push(c), f(c));
                                c.nodeType === Node.TEXT_NODE && a++
                            })
                        }
                    };
                return function (a) {
                    a = $(a).clone()[0];
                    f(a);
                    _(e).each(function (a) {
                        a.parentNode && a.parentNode.removeChild(a)
                    });
                    return a
                }
            }();
        return {
            prefix: e(a.clone()[0], c),
            suffix: b ? null : f(a.clone()[0],
            c)
        }
    }
    function e(a) {
        var c;
        if (a.childNodes.length > 0) for (var b = a.childNodes.length - 1; b > -1; b--) if (a.childNodes[b].nodeType === 1) {
            c = a.childNodes[b];
            break
        }
        b = 0;
        c && (b = parseFloat(window.getComputedStyle(c)["margin-bottom"]));
        a = parseFloat(window.getComputedStyle(a)["margin-bottom"]);
        b = isNaN(b) ? 0 : b;
        a = isNaN(a) ? 0 : a;
        return Math.max(a, b)
    }
    b.getOverlay = function () {
        return $("<div class='textflow-overlay'></div>").attr("id", "overlay_" + parseInt(Math.random() * 99999, 10).toString(16))
    };
    b.prototype.init = function () {
        var a = $(this.element);
        this.options.separator = {
            sentences: ". ",
            words: " ",
            characters: ""
        }[this.options.split];
        this.schedulerId = "task_" + parseInt(Math.random() * 999999999999999, 10).toString(16);
        this.continuations = typeof this.options.continuation === "function" ? [this.options.continuation] : [];
        this.timespent = this.iterations = 0;
        this.options.content ? this.content = this.options.content : (a = a.find("[data-format='textflow']"), a.html(a.data("original-content")), this.content = a);
        this.reset()
    };
    b.prototype.fixImmediateTextNodes = function () {
        this.content.each(function (a,
        c) {
            for (var b = 0; b < c.childNodes.length; b++) if (c.childNodes[b].nodeType === Node.TEXT_NODE && $.trim(c.childNodes[b].nodeValue).length > 0) {
                var e = document.createElement("span");
                e.appendChild(c.childNodes[b].cloneNode());
                c.replaceChild(e, c.childNodes[b])
            }
        })
    };
    b.prototype.reset = function () {
        var a = this,
            c = $(this.element),
            e = c.find(".subpage");
        this.unSchedule();
        this.asyncOverlay = b.getOverlay();
        c.append(this.asyncOverlay);
        this.shouldHalt = false;
        this.busy = true;
        b.hasStoredFontPreferences() && c.attr("class", Pressly.Storage.get("textflow-font-size"));
        var f = $("<p class='measure-me'></p>");
        c.find(".body").append(f);
        this.options.fontSize = f.css("font-size");
        this.options.lineHeight = f.css("line-height");
        f.remove();
        c.find("[data-format='textflow']").hide();
        c.find(".overflow").hide();
        c.find(".textflow").html("");
        this.resizePage(e);
        this.fixImmediateTextNodes();
        for (var c = [], f = $(this.content).children(), h = 0; h < f.length; h++) c.push(f[h].cloneNode(true));
        e = $(_(e.find(".textflow")).select(function (c) {
            c = window.getComputedStyle(c);
            return c.display !== "none" && parseInt(c.height,
            10) > parseFloat(a.options.lineHeight)
        }));
        e.length > 0 ? this.continueFlow(e, c) : this.generatePage(c)
    };
    b.prototype.prepareImage = function () {
        var a = $(this.element).find(".image_container"),
            c = a.find("img[data-aspect-ratio]"),
            b = a.parents(":has(> .textflow)");
        if (c.length > 0) {
            c.hide();
            var e = a.outerHeight(true);
            c.show();
            a = b.height();
            a -= e;
            parseInt(c.data("original-width"), 10);
            var f = parseInt(c.data("original-height"), 10),
                e = c.parents("figure").width(),
                b = parseFloat(c.data("aspect-ratio"));
            if (b >= 1) a = e / b;
            else {
                var h = e / b;
                h <= a ? a = h : (a = f < a ? f : a, e = a * b)
            }
            c.width(parseInt(e, 10));
            c.height(parseInt(a, 10))
        }
    };
    b.prototype.resizePage = function (a) {
        var c = this,
            b = a.find(".textflow");
        b.css({
            height: "",
            width: ""
        });
        var e = a.find("[data-textflow-margin-fix]").not("[data-textflow-margin-fix='fixed']");
        if (e.length > 0) {
            var f = e.outerHeight(true) % parseFloat(c.options.lineHeight),
                h = parseFloat(e.css("margin-bottom")),
                h = isNaN(h) ? 0 : h,
                f = h + (f > 0 ? parseFloat(c.options.lineHeight) - f : 0);
            e.css("margin-bottom", f + "px");
            e.attr("data-textflow-margin-fix", "fixed")
        }
        e = a.find(".first-column");
        a = a.find(".second-column");
        f = e.parent().find("div.title").outerHeight(true);
        f = e.parent().height() - f;
        e.height(f);
        a.length > 0 && a.height(f);
        this.prepareImage();
        b.each(function () {
            var a = $(this),
                b = a.parent();
            a.data("margin-cleared") && a.css("margin-bottom", "");
            var e = parseInt(a.css("margin-bottom"), 10);
            typeof e !== "number" && (e = 0);
            var f = _(b.find("> *").not(".textflow")).reduce(function (a, c) {
                var b = $(c).outerHeight(true);
                return a + b
            }, e),
                b = b.height() - f;
            c.options.lineHeight && (b -= b % parseFloat(c.options.lineHeight),
            b / parseFloat(c.options.lineHeight) < 2 && (b = 0));
            b === 0 && e > 0 && (a.css("margin-bottom", "0px"), a.attr("data-margin-cleared", true));
            a.height(b)
        })
    };
    b.prototype.cleanup = function () {
        var a = $(this.element).find(".subpage").first();
        a.find(".textflow > *").remove();
        a.find("[data-textflow-margin-fix='fixed']").attr("data-textflow-margin-fix", "").css("marginBottom", "0px");
        $(this.element).find(".subpage").not(a).remove();
        if (this.asyncOverlay) this.asyncOverlay.remove(), this.asyncOverlay = void 0
    };
    b.prototype.handleViewportChange = function (a) {
        typeof a === "function" && this.continuations.push(a);
        this.cleanup();
        this.reset()
    };
    b.hasStoredFontPreferences = function () {
        return ["x-small", "small", "medium", "large", "x-large"].indexOf(Pressly.Storage.get("textflow-font-size")) > -1
    };
    b.prototype.setFontSize = function (a, c) {
        $(this.element).attr("class", a);
        this.handleViewportChange(c)
    };
    b.prototype.continueFlow = function (a, c) {
        var b = this,
            e = function () {
                c.length > 0 ? b.shouldHalt === true ? b.resetForHalt() : b.schedule(function () {
                    b.generatePage(c)
                }) : b.finished()
            },
            f = 0,
            h = function () {
                b.shouldHalt === true ? b.resetForHalt() : b.continueColumn(a.eq(f), c, b.options.separator, function (j) {
                    c = j;
                    f++;
                    f < a.length && c.length > 0 ? b.schedule(function () {
                        h()
                    }) : e()
                })
            };
        h()
    };
    b.prototype.finished = function () {
        this.shouldHalt = this.busy = false;
        this.executeContinuations();
        if (this.asyncOverlay) this.asyncOverlay.remove(), this.asyncOverlay = void 0;
        typeof this.haltCallback === "function" && this.haltCallback();
        this.releaseSchedulerId()
    };
    b.prototype.generatePage = function (a) {
        var c = $(this.element),
            b = c.find(".overflow").clone();
        b.removeClass("overflow");
        b.addClass("subpage");
        b.css({
            display: "block"
        });
        var e = b.find(".textflow");
        c.find(".subpage").last().after(b);
        this.resizePage(b);
        this.continueFlow(e, a)
    };
    b.prototype.getColumnInfo = function (a) {
        var c = window.getComputedStyle(a[0]),
            a = {
                count: parseInt(c.webkitColumnCount, 10) || void 0,
                gap: parseInt(c.webkitColumnGap, 10) || 0,
                width: parseFloat(c.webkitColumnWidth) || void 0,
                height: parseInt(c.height, 10)
            }, c = parseInt(c.width, 10);
        typeof a.count === "number" && !a.width ? a.width = Math.floor(Math.max(0, (c - (a.count - 1) * a.gap) / a.count)) : typeof columnWidth === "number" && !columnCount ? (a.count = Math.max(1, Math.floor((c + a.gap) / (a.width + a.gap))), a.width = (c + a.gap) / a.count - a.gap) : typeof columnCount === "number" && typeof columnWidth === "number" ? (a.count = Math.min(a.count, Math.floor((c + a.gap) / (a.width + a.gap))), a.width = (c + a.gap) / a.count - a.gap) : (a.count = 1, a.width = c);
        a.totalHeight = a.count * a.height;
        return a
    };
    var f = function (a, c, b) {
        var e = null,
            f = {}, h = function (j, s) {
                if (s < j) return -1;
                e = j + (s - j >> 1);
                var A = typeof f[e] == "number" ? f[e] : c(a[e], b);
                f[e] = A;
                return A === 1 ? h(j, e - 1) : A === -1 ? h(e + 1, s) : e
            }, j = h(0, a.length - 1);
        if (j === -1 && (j = f[e] === -1 ? e : e - 1, j < 0 || j == a.length)) j = e;
        return j
    };
    b.prototype.continueColumn = function (b, h, l, i) {
        function j() {
            p.iterations++;
            return parseInt((A.offset().left - z) / s.width, 10) * s.height + (A.offset().top - E)
        }
        var p = this,
            s = this.getColumnInfo(b, this),
            x = s.totalHeight,
            t = false,
            A = $("<div class='textflow-marker'>MARKER</div>");
        b.append(A);
        var z = b.offset().left,
            E = b.offset().top,
            L = function () {
                var i = h.shift();
                b[0].insertBefore(i,
                b[0].lastChild);
                if (j() > x) {
                    t = true;
                    var s = $(i).clone(),
                        A = a(i, l),
                        z = e(i),
                        E, G;
                    p.splitPointIterator ? E = p.splitPointIterator.next() : (G = f(A, function (a, b) {
                        for (var e = c(s, a, true); i.childNodes.length > 0;) i.removeChild(i.firstChild);
                        for (var f = 0; f < e.prefix.childNodes.length; f++) i.appendChild(e.prefix.childNodes[f].cloneNode(true));
                        e = j() - z;
                        if (e > b) return 1;
                        else if (e < b) return -1;
                        else if (e === b) return -1
                    }, x), E = A[G]);
                    for (E = c(s, E); i.childNodes.length > 0;) i.removeChild(i.firstChild);
                    if (G > 0) for (var q = 0; q < E.prefix.childNodes.length; q++) i.appendChild(E.prefix.childNodes[q].cloneNode(true));
                    q = false;
                    G === A.length - 1 && (q = $(E.suffix).is(":empty"));
                    q || h.unshift(E.suffix)
                }
            };
        if (typeof i === "function") {
            for (var M = 0; h.length > 0 && t === false;) L(), M++;
            A.remove();
            i(h)
        } else {
            for (; h.length > 0 && t === false;) L();
            A.remove();
            return h
        }
    };
    var h = null,
        j = [];
    b.prototype.schedule = function (a) {
        this.options.disableScheduler === true ? setTimeout(a, this.options.asynchronousTimeoutLength) : (j.push({
            id: this.schedulerId,
            task: a
        }), this.nextTask())
    };
    b.prototype.removeScheduledTasks = function () {
        var a = this;
        j = _.select(j, function (c) {
            return c.id !== a.schedulerId
        })
    };
    b.prototype.unSchedule = function () {
        this.removeScheduledTasks();
        this.releaseSchedulerId();
        this.cleanup()
    };
    b.prototype.releaseSchedulerId = function () {
        h = h === this.schedulerId ? null : h;
        this.nextTask()
    };
    b.prototype.nextTask = function () {
        if (j.length > 0) {
            var a;
            h = h === null ? j[0].id : h;
            for (var c = 0; c < j.length; c++) if (j[c].id === h) {
                a = j[c].task;
                j.splice(c, 1);
                break
            }
            typeof a === "function" && setTimeout(function () {
                a()
            }, this.options.asynchronousTimeoutLength)
        }
    };
    b.prototype.isBusy = function () {
        return this.busy === true
    };
    b.prototype.halt = function (a) {
        a()
    };
    b.prototype.resetForHalt = function () {
        this.busy = this.shouldHalt = false;
        this.unSchedule();
        typeof this.haltCallback === "function" && this.haltCallback()
    };
    b.prototype.hasContinuations = function () {
        return this.continuations.length > 0
    };
    b.prototype.executeContinuations = function () {
        if (this.hasContinuations()) for (; this.continuations.length > 0;) this.continuations.pop()()
    };
    Pressly.Textflow = b
})();
(function () {
    function b(a, c) {
        this.defaults = {
            navLinkSelector: "a.nav-link"
        };
        Pressly.Core.apply(this, arguments)
    }
    b.autoGeneratePageNav = function (a, c, b) {
        var b = typeof b == "string" ? b : "nav-link",
            f = $("<nav>").addClass(typeof c == "string" ? c : "pages");
        _($(a)).each(function (a, c) {
            var n = $(a).attr("id");
            f.append($("<a>").addClass(b).attr("id", n).attr("href", "#" + n).html(c + 1))
        });
        return f.get(0)
    };
    b.prototype.lock = function () {
        $(this.element).addClass("events_locked")
    };
    b.prototype.unlock = function () {
        $(this.element).removeClass("events_locked")
    };
    b.prototype.init = function () {
        var a = this,
            c = this.getViewport().width / $(this.element).find(this.options.navLinkSelector).eq(0).width();
        $(this.element).data("vertical") ? this.scroll = new Pressly.Scroll(this.element, {
            orientation: "vertical",
            snap: true,
            snapSelector: "a"
        }) : this.swipe = new Pressly.Swipe(this.element, {
            pageClass: "nav-link",
            pageStep: c
        });
        this.pageChanged(0);
        this.actionBoxes = [];
        $(this.element).find(this.options.navLinkSelector).each(function (c, b) {
            var h = new Pressly.Box(b);
            h.addAction(function () {
                a.navigateToPage(b)
            });
            b.addEventListener("click", function (a) {
                a.preventDefault();
                a.stopPropagation()
            }, false);
            a.actionBoxes.push(h)
        })
    };
    b.prototype.destroy = function () {
        if (this.swipe) this.swipe.destroy(), this.swipe = void 0;
        $(this.element).find(this.options.navLinkSelector).unbind();
        $(this.element).remove();
        this.element = this.options = void 0;
        _(this.actionBoxes).each(function (a) {
            a.destroy()
        });
        this.actionBoxes = void 0
    };
    b.prototype.getHeight = function () {
        return $(this.element).height()
    };
    b.prototype.navigateToPath = function (a) {
        console.log("navigateToPath(" + a + ")")
    };
    b.prototype.navigateToPage = function (a) {
        if (typeof this.options.onNavigationRequest === "function") if (a.href.indexOf(location.href) === 0) this.options.onNavigationRequest(a.href.split("#")[1]);
        else window.open(a.href)
    };
    b.prototype.pageChanged = function (a) {
        $(this.element).find(".current").removeClass("current");
        $(this.element).find(".nav-link").eq(a).addClass("current")
    };
    b.prototype.handleViewportChange = function () {
        this.swipe && this.swipe.handleViewportChange()
    };
    Pressly.Nav = b
})();
(function () {
    function b(a, b) {
        this.defaults = {
            showVideoControls: true,
            seekingMinimumInterval: 125,
            sliderNubUpdateMinimumInterval: 100,
            alwaysFullscreen: false,
            positionAndScale: false
        };
        Pressly.Core.apply(this, arguments)
    }
    var a = function (a) {
        a.stopPropagation();
        a.preventDefault()
    };
    b.prototype.init = function () {
        this.hasStartedPlayingOnce = this.warmedup = false
    };
    b.prototype.warmup = function () {
        var a = this;
        if (this.warmedup === false) this.warmedup = true, console.log("element.load()"), this.element.load(), console.log("element.play()"),
        this.play(), setTimeout(function () {
            console.log("pause()");
            a.pause();
            try {
                console.log("currentTime=0"), a.element.currentTime = 0
            } catch (b) {}
        }, this.options.seekingMinimumInterval)
    };
    b.prototype.initializeVideoElement = function () {
        var a = this;
        this.element.load();
        var b = {
            abort: "Sent when the browser stops fetching the media data before the media resource was completely downloaded.",
            canplay: "Sent when the browser can resume playback of the media data, but estimates that if playback is started now, the media resource could not be rendered at the current playback rate up to its end without having to stop for further buffering of content.",
            canplaythrough: "Sent when the browser estimates that if playback is started now, the media resource could be rendered at the current playback rate all the way to its end without having to stop for further buffering.",
            durationchange: "Sent when the duration property changes.",
            emptied: "Sent when the media element network state changes to the NETWORK_EMPTY state.",
            ended: "Sent when playback has stopped at the end of the media resource and the ended property is set to true.",
            error: "Sent when an error occurs while fetching the media data. Use the error property to get the current error.",
            loadeddata: "Sent when the browser can render the media data at the current playback position for the first time.",
            loadedmetadata: "Sent when the browser knows the duration and dimensions of the media resource.",
            loadstart: "Sent when the browser begins loading the media data.",
            pause: "Sent when playback pauses after the pause method returns.",
            play: "Sent when playback starts after the play method returns.",
            playing: "Sent when playback starts.",
            progress: "Sent when the browser is fetching the media data.",
            ratechange: "Sent when either the defaultPlaybackRate or the playbackRate property changes.",
            seeked: "Sent when the seeking property is set to false",
            seeking: "Sent when the seeking property is set to true and there is time to send this event.",
            stalled: "Sent when the browser is fetching media data but it has stopped arriving.",
            suspend: "Sent when the browser suspends loading the media data and does not have the entire media resource downloaded.",
            timeupdate: "Sent when the currentTime property changes as part of normal playback or because of some other condition.",
            volumechange: "Sent when either the volume property or the muted property changes.",
            waiting: "Sent when the browser stops playback because it is waiting for the next frame."
        }, f = function (f) {
            a.element.addEventListener(f, function () {
                console.log("[" + f + "]:" + b[f])
            }, true)
        }, h;
        for (h in b) f(h);
        if (this.options.positionAndScale) {
            f = Math.round($(this.element).parent().width() * 0.75);
            h = Math.round(Math.min($(this.element).parent().height(), f * (1 / (16 / 9))));
            var j = Math.round(($(this.element).parent().height() - h) / 2),
                n = Math.round(($(this.element).parent().width() - f) / 2);
            $(this.element).width(Math.round(f)).height(Math.round(h)).css({
                top: j + "px",
                left: n + "px"
            })
        }
    };
    b.prototype.createVideoOverlay = function () {
        var a = $(this.element);
        a.wrap($("<div class='video_wrapper'>"));
        this.wrapper = a.parent();
        this.wrapper.width(a.width()).height(a.height());
        $(this.element).position();
        $(this.element).position();
        this.wrapper.append($("<div>").addClass("video_overlay"));
        this.overlay = this.wrapper.find(".video_overlay");
        this.options.showVideoControls !== true && this.overlay.hide()
    };
    b.prototype.createVideoControls = function () {
        $(this.element);
        this.createVideoOverlay();
        this.createVideoControlButtons();
        this.createVideoSlider()
    };
    b.prototype.createVideoSlider = function () {
        var c = this;
        $(this.element);
        this.overlay.append($("<div>").addClass("video_slider").append($("<div>").addClass("video_slider_nub")));
        var b = this.overlay.find(".video_slider"),
            f = this.overlay.find(".video_slider_nub");
        f.get(0).addEventListener("touchstart", a);
        f.get(0).addEventListener("touchend", a);
        f.get(0).addEventListener("touchmove", function (h) {
            console.log("nub touchmove");
            a(h);
            var h = h.touches[0].clientX - b.offset().left,
                j = b.width() - f.width(),
                h = Math.max(0, Math.min(c.element.duration, h / j * c.element.duration));
            c.setCurrentTime(h, true)
        }, false)
    };
    b.prototype.createVideoControlButtons = function () {
        var c = this,
            b = navigator.userAgent.indexOf("Macintosh") > -1 && navigator.userAgent.indexOf("Safari") > -1 || navigator.userAgent.indexOf("Chrome") > -1,
            f = $("<div>").addClass("video_play_button").addClass("state_playbutton"),
            h = $("<div>").addClass("video_fullscreen_button"),
            j = $("<div>").addClass("video_large_play_button");
        this.overlay.append(f);
        this.overlay.append(h);
        this.wrapper.append(j);
        this.showLargePlayButton();
        var n = {
            0: "NETWORK_EMPTY The element has not yet been initialized. All attributes are in their initial states.",
            1: "NETWORK_IDLE The element's resource selection algorithm is active and has selected a resource, but it is not actually using the network at this time.",
            2: "NETWORK_LOADING The user agent is actively trying to download data.",
            3: "NETWORK_NO_SOURCE (numeric value 3)"
        }, k = function (b) {
            console.log("----------------- before play call: ---------------");
            console.log("networkState = " + n[c.element.networkState]);
            console.log("readyState = " + c.element.readyState[c.element.readyState]);
            console.log("element.paused? " + c.element.paused);
            console.log("element.played? " + c.element.played);
            console.log("element.buffered " + c.element.buffered);
            console.log("element.currentTime " + c.element.currentTime);
            console.log("element.duration " + c.element.duration);
            console.log("element.error " + c.element.error);
            a(b);
            c.element.paused !== true ? c.pause() : (c.play(), console.log("--------------- AFTER play call ----------------"),
            console.log("networkState = " + n[c.element.networkState]), console.log("readyState = " + c.element.readyState[c.element.readyState]), console.log("element.paused? " + c.element.paused), console.log("element.played? " + c.element.played), console.log("element.buffered " + c.element.buffered), console.log("element.currentTime " + c.element.currentTime), console.log("element.duration " + c.element.duration), console.log("element.error " + c.element.error))
        }, l = function (b) {
            console.log("fullscreenbutton tapped/clicked");
            a(b);
            c.enterFullScreen()
        }, i = function (b) {
            console.log("large playbutton tapped/clicked");
            a(b);
            c.element.paused === true && (c.play(), c.hideLargePlayButton())
        };
        b ? h.click(l) : (h.get(0).addEventListener("touchstart", a), h.get(0).addEventListener("touchend", l), h.get(0).addEventListener("touchmove", a));
        b ? f.click(k) : (f.get(0).addEventListener("touchstart", a), f.get(0).addEventListener("touchend", k), f.get(0).addEventListener("touchmove", a));
        b ? j.click(i) : (j.get(0).addEventListener("touchstart", a), j.get(0).addEventListener("touchend",
        i), j.get(0).addEventListener("touchmove", a))
    };
    b.prototype.reflectPlayState = function () {
        this.element.paused === true ? this.showPausedState() : this.showPlayingState()
    };
    b.prototype.createVideoPlaybackListeners = function () {
        var a = this;
        this.element.addEventListener("pause", function () {
            a.reflectPlayState()
        });
        this.element.addEventListener("play", function () {
            if (a.hasStartedPlayingOnce === false) a.hasStartedPlayingOnce = true, Pressly.track(["video", "play", "src", $(a.element).attr("src")]);
            a.hideLargePlayButton()
        });
        this.element.addEventListener("timeupdate",

        function () {
            a.updateSlider(true);
            a.hideLargePlayButton()
        });
        this.element.addEventListener("ended", function () {
            Pressly.track(["video", "watched", "src", $(a.element).attr("src")]);
            if (a.options.alwaysFullscreen) setTimeout(function () {
                a.stop(true);
                if (typeof a.options.onVideoEnd === "function") a.options.onVideoEnd()
            }, 1E3);
            else if (a.stop(), typeof a.options.onVideoEnd === "function") a.options.onVideoEnd()
        })
    };
    b.prototype.positionVideoControls = function () {
        $(this.element).position();
        $(this.element).position();
        this.wrapper.find(".video_overlay").css({});
        var a = $(this.element),
            b = this.overlay.find(".video_slider"),
            f = this.overlay.find(".video_slider_nub"),
            h = this.overlay.find(".video_play_button"),
            j = this.overlay.find(".video_fullscreen_button"),
            a = a.height() - f.height();
        b.css({
            top: a + "px",
            left: h.width() + "px"
        });
        h.css({
            top: a + "px",
            left: "0px"
        }).show();
        j.css({
            top: a + "px",
            left: b.width() + h.width() + "px"
        }).show();
        b.show()
    };
    b.prototype.showVideoControls = function () {
        this.positionVideoControls();
        this.overlay.show();
        this.overlay.find(".video_slider").show()
    };
    b.prototype.enterFullScreen = function () {
        try {
            this.element.webkitSupportsFullscreen && this.element.webkitEnterFullscreen()
        } catch (a) {}
    };
    b.prototype.exitFullScreen = function () {
        try {
            this.element.webkitSupportsFullscreen && this.element.webkitExitFullscreen()
        } catch (a) {}
    };
    b.prototype.showPlayingState = function () {
        this.overlay && this.overlay.find(".video_play_button").removeClass("state_playbutton").addClass("state_pausebutton")
    };
    b.prototype.showPausedState = function () {
        this.overlay && this.overlay.find(".video_play_button").removeClass("state_pausebutton").addClass("state_playbutton")
    };
    b.prototype.play = function () {
        this.element.play();
        this.showPlayingState();
        this.updateSlider(true)
    };
    b.prototype.pause = function () {
        this.element.pause();
        this.showPausedState();
        this.updateSlider(true)
    };
    b.prototype.stop = function () {
        this.pause();
        try {
            this.element.currentTime = 0
        } catch (a) {}
        this.showLargePlayButton();
        this.updateSlider(true)
    };
    b.prototype.hideLargePlayButton = function () {
        if (this.largePlayButtonVisible) this.wrapper.find(".video_large_play_button").hide(), this.largePlayButtonVisible = false
    };
    b.prototype.showLargePlayButton = function () {
        this.wrapper.find(".video_large_play_button");
        this.largePlayButtonVisible = true
    };
    b.prototype.autoplay = function () {
        this.element.load();
        this.play();
        this.options.alwaysFullscreen === true && this.enterFullScreen();
        this.options.showVideoControls === true && this.positionVideoControls();
        this.element.paused && this.showLargePlayButton();
        this.reflectPlayState()
    };
    b.prototype.setCurrentTime = function (a) {
        this.element.currentTime = a;
        this.updateSlider(true)
    };
    b.prototype.addTimeListener = function (a, b) {
        if (this.listeningToTimeline !== true) {
            var f = this,
                h = -Infinity;
            this.timeListeners = [];
            this.element.addEventListener("timeupdate", function () {
                var a = Math.floor,
                    c = a(f.element.currentTime);
                c != h && _(f.timeListeners).each(function (b) {
                    var e = a(b.time);
                    (e == c || e < 0 && a(f.element.duration) + e == c) && b.handler()
                });
                h = c
            });
            this.listeningToTimeline = true
        }
        this.timeListeners.push({
            handler: b,
            time: a
        })
    };
    b.prototype.updateSlider = function (a) {
        var b = this,
            f = function () {
                var a = b.overlay.find(".video_slider"),
                    c = b.overlay.find(".video_slider_nub"),
                    a = a.width() - c.width();
                a *= b.element.currentTime / b.element.duration;
                b.overlay.find(".video_slider_nub").css({
                    "-webkit-transform": "translateX(" + a + "px) translateY(0px) translateZ(0px)"
                });
                b.lastSliderUpdate = (new Date).getTime()
            };
        a === true ? (a = (new Date).getTime(), typeof b.lastSliderUpdate == "undefined" || a - b.lastSliderUpdate > this.options.sliderNubUpdateMinimumInterval ? (clearInterval(this._scheduledSliderUpdate), f()) : this._scheduledSliderUpdate = setTimeout(f, this.options.sliderNubUpdateMinimumInterval)) : f()
    };
    Pressly.Video = b
})();
(function () {
    function b(a, b) {
        this.defaults = {};
        Pressly.Core.apply(this, arguments)
    }
    b.boxes = [];
    b.clickAtElement = function (a) {
        if (a) {
            a.jquery && a.length > 0 ? (a = a[0], a.length > 1 && console.error("Box.clickAtElement: jQuery set refers to more than one element to be clicked", a)) : console.error("Box.clickAtElement: empty jQuery set supplied as el ", a);
            var c = b.findByElementOrAncestor(a);
            if (c) c.executeAction();
            else throw console.error("Box.clickAtElement: no box found at element ", a), "Box.clickAtElement: no box found at element";
        } else console.error("Box.clickAtElement: no element or undefined element supplied ")
    };
    b.findByElement = function (a) {
        for (var c = 0; c < b.boxes.length; c++) if (a === b.boxes[c].element) return b.boxes[c]
    };
    b.findByElementOrAncestor = function (a) {
        var c = b.findByElement(a);
        c || $(a).parents().each(function (a, f) {
            c || (c = b.findByElement(f))
        });
        return c
    };
    b.analyze = function () {
        Pressly.Util.analyze(b, "boxes")
    };
    b.prototype.init = function () {
        var a = this;
        if ($(this.element).data("box-initialized") === true) throw "Error: init of Pressly.Box attempted on a single element more than once";
        $(this.element).attr("data-box-initialized", true);
        this.actions = [];
        this.pageIndex = this.options.pageIndex;
        this.addGestureListener("touchtap", function (b) {
            a.executeAction(b);
            b.stopPropagation()
        });
        !Pressly.Device.isTablet() && !Pressly.Device.isPhone() && $(this.element).click(function (b) {
            a.executeAction(b);
            b.stopPropagation()
        });
        b.boxes.push(this)
    };
    b.prototype.onShow = function () {};
    b.prototype.onHide = function () {};
    b.prototype.addAction = function (a) {
        this.actions.push(a)
    };
    b.prototype.handleViewportChange = function () {};
    b.prototype.closeActiveWebview = function () {
        var a = window.issue.router;
        a.webview && (a.webview.hide(), a.hideArticleBackButton())
    };
    b.prototype.executeAction = function (a) {
        var b = $(this.element).data("action"),
            e = $(this.element).data("id");
        a && a.preventDefault();
        if (b) {
            var f = window.issue.router,
                h = window.issue.router.manifest;
            b !== "showModal" && Pressly.Modal.hideAll(true);
            f.webview && this.closeActiveWebview();
            switch (b) {
            case "show":
                switch (h.get(e).selector) {
                case ".gallery":
                    f.goTo(e, void 0, f.articleLayer.pages.currentPage.article);
                    break;
                case ".video":
                    f.goTo(e, void 0, f.articleLayer.pages.currentPage.article);
                    break;
                default:
                    f.goTo(e)
                }
                break;
            case "goto":
                f.goTo(this.element.getAttribute("data-path").replace(/#/, ""));
                break;
            case "gotoExternal":
                f = this.element.getAttribute("data-path");
                Pressly.track(["ui-event", "exit-link", f]);
                b = $(this.element).data("context");
                window.issue.router.gotoExternalLink(f, b);
                break;
            case "showNav":
                f.toggleSectionNav();
                break;
            case "showModal":
                (f = $(this.element).data("tracking-id")) && Pressly.track(["ui-event", "modal", "name", f]);
                if (this.modal && $(this.element).data("recreate") != void 0) this.modal.destroy(), this.modal = void 0;
                this.modal ? this.modal.toggle() : (this.modal = new Pressly.Modal(this.element), this.modal.show());
                break;
            case "webview":
                this.webview = new Pressly.Webview({
                    src: this.element.getAttribute("data-path")
                });
                this.webview.show();
                break;
            case "feedback":
                window.issue.feedback.toggleVisibility();
                break;
            case "close":
                if (f.articleLayer.isActive()) e = f.articleLayer.pages.currentPage, e.mediaOverlay && e.mediaOverlay.isVisible() ? e.mediaOverlay.hide() : e.article && e.article.mediaOverlay && e.article.mediaOverlay.isVisible() ? e.article.mediaOverlay.hide() : (f.hideArticleLayer(), f.hideArticleBackButton());
                break;
            case "showWidget":
                if (f.articleLayer.isActive() && (b = $(this.element).data("type"), (e = f.articleLayer.pages.currentPage) && e.article && e.article.toolbar)) switch (f = e.article.toolbar, b) {
                case "font-resize":
                    f.toggleFontSize();
                    break;
                case "sharing":
                    f.toggleSharing();
                    break;
                case "comments":
                    f.toggleComments()
                }
                break;
            case "refresh":
                Pressly.track(["ui-event", "refresh"]), window.location.reload(true)
            }
        }
        if (this.actions.length > 0) for (f = 0; f < this.actions.length; f++) this.actions[f](a);
        return false
    };
    b.prototype.destroy = function () {
        this.actions = void 0;
        typeof this.removeAllGestureListeners === "function" && this.removeAllGestureListeners();
        $(this.actionElement).remove();
        this.actionElement = void 0;
        if (this.modal) this.modal.destroy(), this.modal = void 0;
        $(this.element).remove();
        this.options = this.element = void 0;
        b.boxes.splice(b.boxes.indexOf(this), 1)
    };
    Pressly.Box = b
})();
(function () {
    function b(a, b) {
        this.defaults = {
            disableGestures: true,
            vendorPrefix: false,
            curve: "ease-out"
        };
        Pressly.Core.apply(this, arguments)
    }
    function a(a) {
        return a.charAt(0).toUpperCase() + a.slice(1)
    }
    b.transitions = [];
    b.prototype.init = function () {
        this.state = this.options.state || "off";
        this.options.transitionEnd ? this.addTransitionEndListener(this.options.transitionEnd) : this.addTransitionEndListener(function () {});
        this.property = this.options.property;
        this.prefix = "webkit";
        if (navigator.userAgent.search("Firefox") !== -1) this.prefix = "moz";
        this.vendorProperty = a(this.prefix) + a(this.property);
        this.vendorTransitionProperty = a(this.prefix) + "Transition";
        this.vendorCssProperty = "-" + this.prefix + "-" + this.property;
        this.curve = this.options.curve;
        b.transitions.push(this)
    };
    b.prototype.addTransitionEndListener = function (a) {
        var b = this,
            a = _.bind(a, b);
        this.transitionEnd = function (f) {
            if (b.state === "turning-on") b.state = "on";
            else if (b.state === "turning-off") b.state = "off";
            a(f);
            b.busy = false
        };
        $(this.element).bind("webkitTransitionEnd transitionend",
        b.transitionEnd)
    };
    b.prototype.fire = function (a, b, f) {
        this.state = f;
        this.prefix === "moz" && (a = a.replace(/\stranslateZ\(.+\)/, ""));
        this.isBusy() && this.aborted();
        this.duration = b;
        this.busy = true;
        this.element.style[this.vendorTransitionProperty] = typeof b === "number" && b > 0 ? (this.options.vendorPrefix ? this.vendorCssProperty : this.property) + " " + b + "ms " + this.curve : "";
        this.isAlreadySet(a) ? b !== void 0 ? this.transitionEnd() : this.busy = false : (this.setParams(a), b === 0 && this.transitionEnd());
        this.params = a
    };
    b.prototype.on = function (a) {
        a = a || {};
        this.fire(a.value || this.options.on || "", a.duration !== void 0 ? a.duration : this.options.duration, "turning-on")
    };
    b.prototype.off = function (a) {
        a = a || {};
        this.fire(a.value || this.options.off, a.duration !== void 0 ? a.duration : this.options.duration, "turning-off")
    };
    b.prototype.is = function (a) {
        return this.state === a
    };
    b.prototype.isBusy = function () {
        return this.busy && this.duration
    };
    b.prototype.isAlreadySet = function (a) {
        return a === (this.options.vendorPrefix ? this.element.style[this.vendorProperty] : this.element.style[this.property])
    };
    b.prototype.setParams = function (a) {
        this.options.vendorPrefix ? this.element.style[this.vendorProperty] = a : this.element.style[this.property] = a
    };
    b.prototype.aborted = function () {};
    b.analyze = function () {
        Pressly.Util.analyze(b, "transitions")
    };
    b.prototype.destroy = function () {
        $(this.element).unbind("webkitTransitionEnd transitionend", this.transitionEnd);
        b.transitions.splice(b.transitions.indexOf(this), 1)
    };
    Pressly.Transition = b
})();
(function (b, a) {
    function c(a) {
        this.defaults = {
            sectionNavSelector: "nav.links",
            jumpToPageDelay: 2E3,
            jumpToPageAfterLoad: 1,
            scrollLock: true,
            feedbackForm: false
        };
        Pressly.Core.call(this, "#issue", a)
    }
    c.prototype.init = function () {
        function a() {
            $(".non-tablet").remove();
            $("#wrapper").show();
            Pressly.Device.isPhantom() ? (console.log("Issue detected phantomjs"), b.phantom = true, delete h.options.jumpToPageAfterLoad) : Pressly.Util.readCookie("pressly_ftload") !== "true" && (Pressly.Util.createCookie("pressly_ftload", "true", 999),
            $("body").addClass("first-time-load"));
            Pressly.Lock && typeof h.options.issueKey === "string" ? Pressly.Lock.isUnlocked(document.location.search, h.options.issueKey) === true ? c() : new Pressly.Lock($("body").get(0), {
                key: h.options.issueKey,
                callback: function () {
                    c()
                }
            }) : c()
        }
        function c() {
            h.preloadFonts();
            h.router = new Pressly.Router(h.element, {
                success: function () {
                    h.cleanup()
                },
                jumpToPageAfterLoad: h.options.jumpToPageAfterLoad,
                jumpToPageDelay: h.options.jumpToPageDelay
            });
            if (h.options.feedbackForm === true) h.feedback = new Pressly.Feedback(".feedback_form", {
                recipient: h.options.feedbackRecipient
            })
        }
        var h = this;
        Pressly.Device.isStandAlone() ? $(h.element).addClass("standalone") : Pressly.Device.isWebView() && $(h.element).addClass("webview");
        b.addEventListener("message", function (a) {
            var a = a.data,
                c;
            if (issue.router.articleLayer.isActive()) try {
                c = issue.router.articleLayer.pages.currentPage.article.paging
            } catch (e) {} else c = b.issue.router.pageLayer;
            if (a && typeof c !== "undefined") switch (a.type) {
            case "touchstart":
                c.onTouchStart({
                    touches: a.touches
                });
                break;
            case "touchmove":
                c.onTouchMove({
                    touches: a.touches
                });
                break;
            case "touchend":
                c.onTouchEnd({});
                break;
            case "ready":
                (c = Pressly.Ad.dispatch[a.dispatchId]) && c.receiveMessage(a)
            }
        }, false);
        $("#loading").remove();
        if (!Pressly.Device.isSupported() && !Pressly.Device.isPhantom() && !this.isDebug()) if (Pressly.Device.isGreyListed()) Pressly.Util.readCookie("pressly_skip_greylist") === "true" ? a() : ($("#grey-list.non-tablet").show(), $("#grey-list.non-tablet .skip").bind("click", function (b) {
            b.stopPropagation();
            b.preventDefault();
            Pressly.Util.createCookie("pressly_skip_greylist", "true", 7);
            a()
        }));
        else return $("#desktop.non-tablet").show(), false;
        else a()
    };
    c.prototype.cleanup = function () {
        self.cleanUpPreloadedFonts()
    };
    c.prototype.preloadFonts = function () {
        this.options.preloadFonts && _(this.options.preloadFonts).each(function (a) {
            a = $("<div class='pressly-preloaded-font' style='position: absolute; top: -100px; left: 0px; z-index: -1; font-family: " + a + ";'>abc123</div>");
            $(document.body).append(a)
        })
    };
    c.prototype.cleanUpPreloadedFonts = function () {
        $(".pressly-preloaded-font").remove()
    };
    c.prototype.destroy = function () {
        this.router.destroy();
        this.feedback && (console.log("feedback destroy"), this.feedback.destroy());
        $(this.element).remove();
        this.options = this.element = a
    };
    b.Pressly.Issue = c
})(window);
(function () {
    var b = {
        readCookie: function (a) {
            a += "=";
            for (var b = document.cookie.split(";"), e = 0; e < b.length; e++) {
                for (var f = b[e]; f.charAt(0) == " ";) f = f.substring(1, f.length);
                if (f.indexOf(a) === 0) return f.substring(a.length, f.length)
            }
            return null
        },
        externalAsyncLink: function (a) {
            window.issue.router.gotoExternalLink(a)
        },
        getVideoTrackingTimestamp: function () {
            var a = new Date;
            return [(a.getYear() + 1900).toString(), Pressly.Util.prefixFill("0", 2, a.getMonth().toString()), Pressly.Util.prefixFill("0", 2, a.getDate().toString()),
            Pressly.Util.prefixFill("0", 2, a.getHours().toString()), Pressly.Util.prefixFill("0", 2, a.getMinutes().toString()), Pressly.Util.prefixFill("0", 2, a.getSeconds().toString())].join(".")
        },
        prefixFill: function (a, c, e) {
            return e.length === c ? e : b.prefixFill(a, c, a + e)
        },
        createCookie: function (a, b, e) {
            if (e) {
                var f = new Date;
                f.setTime(f.getTime() + e * 864E5);
                e = "; expires=" + f.toGMTString()
            } else e = "";
            document.cookie = a + "=" + b + e + "; path=/"
        },
        prettyDate: function (a) {
            var a = new Date(a),
                b = a.getHours(),
                b = b < 13 ? b : b - 12,
                b = b + ":" + a.getMinutes() + " " + (b < 12 ? "AM" : "PM") + " " + "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec".split(",")[a.getMonth()] + " " + a.getDate();
            switch (a.getDate()) {
            case 1:
            case 21:
            case 31:
                a = "st";
                break;
            case 2:
            case 22:
                a = "nd";
                break;
            case 3:
            case 23:
                a = "rd";
                break;
            default:
                a = "th"
            }
            return b + a
        },
        getHeight: function (a) {
            return parseInt(a.height, 10) + parseInt(a["margin-top"], 10) + parseInt(a["margin-bottom"], 10)
        },
        trimArticle: function (a) {
            var b = $(a);
            if (b.data("format") === "trim") {
                var a = b.height(),
                    e = b.find("p.body"),
                    f = b.find("h2"),
                    h = b.find("h3");
                h.show();
                var j = h.outerHeight(true),
                    n = parseInt(e.css("line-height"), 10),
                    k = b.find("> .image_container");
                k.data("trim-hide") && k.show();
                var l = k.width(),
                    i = k.height(),
                    b = b.find("> .image_container img"),
                    r, p, s, x = window.getMatchedCSSRules(b.get(0));
                if (x) for (var t = 0; t < x.length; t++) if (s = x[t], s.parentStyleSheet && s.parentStyleSheet.media.mediaText.indexOf("orientation") >= 0) $(b).data("original-width"), $(b).data("original-height"), r = $(b).data("aspect-ratio"), p = s.style.width, s = s.style.height, p.indexOf("%") >= 1 ? (p = l * parseInt(p,
                10) / 100, $(b).width(p), $(b).height(p / r)) : s.indexOf("%") >= 1 && (p = i * parseInt(s, 10) / 100, $(b).height(p), $(b).width(p * r));
                l = k.css("float") === "none" ? k.outerHeight(true) : 0;
                i = parseInt(e.css("margin-top").split("px")[0]);
                b = parseInt(e.css("margin-bottom").split("px")[0]);
                l = a - f.outerHeight(true) - j - l - i - b;
                l < 0 && (l + j > 0 ? h.hide() : (k.hide(), k.attr("data-trim-hide", true), l = a - f.outerHeight(true) - j));
                e.height(l - l % n)
            }
        },
        stopwatch: function () {
            var a = (new Date).getTime();
            return function () {
                return (new Date).getTime() - a
            }
        },
        timeago: function (a,
        b) {
            var e, f, h, j;
            if (typeof a === "string" || typeof a === "number") j = new Date(a);
            else if (e = true, f = $(a), f.length > 0 && f.data("timestamp")) j = $.isNumeric(f.data("timestamp")) ? new Date(parseInt(f.data("timestamp"), 10) * 1E3) : new Date(f.data("timestamp")), h = f.data("timeago");
            else return;
            if (j && !h) {
                h = {
                    seconds: "%s seconds",
                    minute: "%s minute",
                    minutes: "%s minutes",
                    hour: "%s hour",
                    hours: "%s hours",
                    day: "%s day",
                    days: "%s days"
                };
                var n = {
                    seconds: "%s secs",
                    minute: "%s min",
                    minutes: "%s mins",
                    hour: "%s hour",
                    hours: "%s hours",
                    day: "%s day",
                    days: "%s days"
                }, k = "long";
                if (e) {
                    var k = f.hasClass("short") ? "short" : "long",
                        l = $.trim(f.text());
                    f.attr("data-timeago", true);
                    f.attr("title", l)
                }
                h = k === "short" ? n : h;
                j = Math.max((new Date).getTime() - j.getTime(), 2E3);
                if (!(b && j > b)) {
                    j /= 1E3;
                    var n = j / 60,
                        k = n / 60,
                        l = k / 24,
                        i = function (a, b) {
                            return a.replace(/%s/i, b)
                        };
                    h = j < 59 && i(h.seconds, Math.round(j)) || j < 119 && i(h.minute, 1) || n < 59 && i(h.minutes, Math.round(n)) || n < 119 && i(h.hour, 1) || k < 48 && i(h.hours, Math.round(k)) || i(h.days, Math.round(l));
                    if (e) f.html([h, "ago"].join(" "));
                    else return [h, "ago"].join(" ")
                }
            }
        },
        analyze: function (a, b) {
            for (var e = a[b], f = [], h = [], j = 0; j < e.length; j++) $(e[j].element).parents().find("body").length > 0 ? h.push(e[j]) : f.push(e[j]);
            console.log("TOTAL object count: " + e.length);
            console.log("-");
            e = function (a, b) {
                console.log("=======================================================================");
                console.log("'" + a + "' count: " + b.length);
                console.log("'" + a + "' instances: ", b);
                console.log("'" + a + "' elements:");
                for (var c = 0; c < b.length; c++) console.log(b[c].element)
            };
            e("possibly-orphaned/leaky",
            f);
            e("probably OK non-orphaned, visible", _(h).select(function (a) {
                return $(a.element).is(":visible")
            }));
            e("probably OK non-orphaned, invisible", _(h).select(function (a) {
                return $(a.element).is(":visible") === false
            }))
        }
    };
    Pressly.Util = b
})();
(function () {
    function b(a) {
        a || (a = {});
        this.defaults = {
            sandbox: false,
            seamless: true
        };
        this.options = _.extend(this.defaults, a);
        this.init()
    }
    b.prototype.init = function () {
        var a = this;
        this.container = document.createElement("div");
        this.container.setAttribute("class", "iframe-container");
        this.iframe = document.createElement("iframe");
        this.iframe.setAttribute("src", this.options.src);
        this.options.sandbox ? this.iframe.setAttribute("sandbox", "") : this.iframe.setAttribute("sandbox", "allow-scripts allow-forms allow-same-origin");
        this.options.seamless && this.iframe.setAttribute("seamless", "");
        this.iframe.addEventListener("load", function () {
            var b = window.getComputedStyle(this);
            a.container.style.height = parseInt(b.height, 10) + parseInt(b.marginTop, 10) + parseInt(b.marginBottom, 10) + "px"
        });
        this.container.appendChild(this.iframe)
    };
    b.prototype.show = function () {
        window.issue.router.webview = this;
        window.issue.router.showArticleBackButton();
        window.issue.options.scrollLock = false;
        document.body.appendChild(this.container)
    };
    b.prototype.hide = function () {
        window.issue.router.webview = null;
        document.body.removeChild(this.container);
        window.issue.options.scrollLock = true
    };
    Pressly.Webview = b
})();
(function () {
    function b(a, b) {
        this.defaults = {};
        Pressly.Core.apply(this, arguments)
    }
    b.prototype.init = function () {
        var a = this;
        this.article = this.options.article;
        this.pagenumber = $(this.element).find(".pagenumber");
        this.overlay = $("<div class='toolbar-widget-overlay'></div>");
        this.overlayButton = new Pressly.Box(this.overlay);
        this.overlayButton.addAction(function () {
            a.hideAll()
        });
        this.fontButton = $(this.element).find("li.font-resize");
        this.fontSizeButtons = this.fontButton.find("> .widget > a");
        this.sharingButton = $(this.element).find("li.sharing");
        this.commentsButton = $(this.element).find("li.comments");
        this.fontSizeButtons.each(function () {
            var b = $(this);
            b.bind("click", function (e) {
                e.preventDefault();
                e.stopPropagation();
                e = b.attr("class").replace(" selected", "");
                Pressly.Storage.set("textflow-font-size", e);
                a.setSelectedFontSizeButton(e);
                a.article.setFontSize(e);
                a.article.prepareNeighbors();
                a.hideAll()
            })
        })
    };
    b.prototype.updatePageNumbering = function (a, b) {
        var e = this.pagenumber.find(".current-page"),
            f = this.pagenumber.find(".page-total");
        e.length > 0 && f.length > 0 ? (e.html(a), f.html(b)) : this.pagenumber.html("Page " + a + " of " + b).data("current", a).data("total", b)
    };
    b.prototype.toggleFontSize = function () {
        this.fontButton.is(".selected") ? this.hideAll() : (this.showOverlay(), this.setSelectedFontSizeButton(), this.fontButton.addClass("selected"), this.sharingButton.removeClass("selected"), this.commentsButton.removeClass("selected"))
    };
    b.prototype.toggleSharing = function () {
        this.sharingButton.is(".selected") ? this.hideAll() : (this.showOverlay(), $(this.element).find("li.sharing").find("a").unbind().bind("click",

        function (a) {
            var b = $(this).attr("href"),
                e = $(this).closest("li"),
                f = _(["facebook", "twitter", "email"]).detect(function (a) {
                    return e.hasClass(a)
                });
            typeof f === "string" && Pressly.track(["ui-event", "share", "name", f, issue.router.articleLayer.pages.currentPage.id]);
            window.issue.router.gotoExternalLink(b, "share-" + f);
            a.preventDefault();
            a.stopPropagation();
            return false
        }), this.sharingButton.addClass("selected"), this.fontButton.removeClass("selected"), this.commentsButton.removeClass("selected"))
    };
    b.prototype.toggleComments = function () {
        if (this.commentsButton.is(".selected")) this.hideAll();
        else {
            var a = this.commentsButton.find(".widget");
            a.html("");
            window.issue.options.scrollLock = false;
            this.gigyaCommentor = Pressly.Plugin.plugins.Gigya.prototype.getGigyaInstance(void 0, void 0, a);
            this.showOverlay();
            this.commentsButton.addClass("selected");
            this.fontButton.removeClass("selected");
            this.sharingButton.removeClass("selected")
        }
    };
    b.prototype.showOverlay = function () {
        var a = this;
        this.article.paging.lock();
        $(this.element).before(this.overlay);
        setTimeout(function () {
            a.overlay.addClass("visible")
        }, 0)
    };
    b.prototype.hideAll = function () {
        var a = this;
        window.issue.options.scrollLock = true;
        this.sharingButton.removeClass("selected");
        this.fontButton.removeClass("selected");
        this.commentsButton.removeClass("selected");
        this.article.paging.unlock();
        this.overlay.bind("webkitTransitionEnd transitionend", function () {
            a.overlay.detach();
            $(a.overlay).unbind("webkitTransitionEnd transitionend")
        });
        this.overlay.removeClass("visible");
        $("input").blur();
        document.activeElement.blur();
        this.gigyaCommentor && this.gigyaCommentor.destroy()
    };
    b.prototype.setSelectedFontSizeButton = function (a) {
        a || (a = Pressly.Textflow.hasStoredFontPreferences() ? Pressly.Storage.get("textflow-font-size") : "small");
        var b = $(_(this.fontSizeButtons).detect(function (b) {
            return $(b).is("." + a)
        }));
        this.fontSizeButtons.removeClass("selected");
        b.addClass("selected")
    };
    b.prototype.destroy = function () {
        this.overlay.remove();
        this.overlayButton.destroy()
    };
    Pressly.Toolbar = b
})();
(function () {
    function b(a, b) {
        this.defaults = {};
        this.id = a.id;
        Pressly.Core.call(this, a, b)
    }
    b.prototype.init = function () {
        this.hasTextflowableContent() ? (this.asyncOverlay = Pressly.Textflow.getOverlay(), $(this.element).append(this.asyncOverlay)) : (this.hasVerticalScrollContent(), articleBox = $(this.element).find("article").eq(0), this.initializePaging(articleBox, "subpage"));
        this.initializeMediaOverlay();
        this.toolbar = new Pressly.Toolbar($(this.element).find("footer[role=toolbar]"), {
            article: this
        })
    };
    b.prototype.beforeShow = function () {
        this.paging && this.paging.beforeShow()
    };
    b.prototype.onShow = function () {
        window.issue.router.articleLayer.isActive() && (this.paging ? (this.trackArticlePage(this.paging.currentIndex + 1), this.paging.onShow()) : this.hasTextflowableContent() && this.initializeTextflow())
    };
    b.prototype.beforeHide = function () {};
    b.prototype.onHide = function () {};
    b.prototype.hasTextflowableContent = function () {
        return $(this.element).find(".body[data-format=textflow]").length > 0
    };
    b.prototype.setFontSize = function (a) {
        var b = this;
        if (this.textflow) {
            var a = a ? a : Pressly.Storage.get("textflow-font-size"),
                e = $(this.textflow.element).attr("class");
            a && a !== e && $(this.element).is(":visible") ? (this.paging.unlock(), this.paging.snapToPage(0, 0), Pressly.track(["ui-event", "font-size", "size in px", a, b.id]), this.textflow.setFontSize(a, function () {
                b.paging.reset();
                b.toolbar.updatePageNumbering(1, b.paging.pages.length)
            })) : this.textflow.needsFontSize = e !== a
        }
    };
    b.prototype.handleViewportChange = function () {
        var a = this;
        window.issue.router.articleLayer.isActive() && (this.paging && this.paging.snapToPage(0, 0), this.mediaOverlay && this.mediaOverlay.handleViewportChange(), this.textflow && this.textflow.handleViewportChange(function () {
            a.paging && (a.paging.reset(), a.toolbar.updatePageNumbering(1, a.paging.pages.length))
        }))
    };
    b.prototype.destroy = function () {
        this.destroyed = true;
        if (this.mediaOverlay) this.mediaOverlay.destroy(), this.mediaOverlay = void 0;
        if (this.paging) this.paging.destroy(), this.paging = void 0;
        if (this.toolbar) this.toolbar.destroy(), this.toolbar = void 0
    };
    b.prototype.share = function () {
        var a = $(this.element).find("article").eq(0);
        window.open("http://twitter.com/intent/tweet?status=" + a.data("sharing-text") + "+" + a.data("original-url") + "+via+%40Pressly&url=" + a.data("original-url") + "&via=Pressly")
    };
    b.prototype.prepareNeighbors = function () {
        var a = window.issue.router.articleLayer,
            b = a.pages.previousPage,
            a = a.pages.nextPage;
        b && b.article && b.article.paging && Pressly.Textflow.hasStoredFontPreferences() && b.article.setFontSize();
        a && a.article && a.article.paging && Pressly.Textflow.hasStoredFontPreferences() && a.article.setFontSize()
    };
    b.prototype.handleContentTouchTap = function (a) {
        function b(a) {
            $(a);
            a.nodeName === "A" && (e = true)
        }
        var e = false;
        b(a.target);
        _($(a.target).parents()).each(function (a) {
            b(a)
        });
        if (e) {
            var f = $(a.target).closest("a").attr("href");
            Pressly.track(["ui-event", "exit-link", f]);
            f.indexOf("mailto") !== 0 && (window.issue.router.gotoExternalLink(f, "in-article"), a.stopPropgation && a.preventDefault && (a.stopPropgation(), a.preventDefault()))
        }
    };
    b.prototype.initializePaging = function (a, b) {
        var e = this;
        this.paging = new Pressly.Paging(a, {
            resettable: false,
            pageClass: b,
            greedySwipes: true,
            allowVerticalScrolling: true,
            name: "articlePaging",
            onDoubleswipeup: function (a) {
                window.issue.router.handleDoubleSwipeUp(a)
            },
            onDoubleswipedown: function (a) {
                window.issue.router.handleDoubleSwipeDown(a)
            },
            onTouchtap: e.handleContentTouchTap,
            onSymmetricalPinch: function () {
                window.issue.router.hideArticleLayer()
            },
            parent: window.issue.router.articleLayer
        });
        this.paging.syncSlave({
            paging: window.issue.router.articleLayer,
            toggleFunction: function (a) {
                if (e.paging.isFirstPage() && a.delta > 0 || e.paging.isLastPage() && a.delta < 0) return true;
                else if (e.paging.isEndOfSwipe() && this.paging.delta !== null) this.paging.animateTo(0, 0), this.paging.delta = null
            }
        })
    };
    b.prototype.hasVerticalScrollContent = function () {
        return $(this.element).find(".vertical-scroll").length > 0
    };
    b.prototype.initializeMediaOverlay = function () {
        var a = this;
        if (!this.mediaOverlay && $(this.element).find("[data-action='show']").length > 0) this.mediaOverlay = new Pressly.MediaOverlay(this.element, {
            onShow: function () {},
            onHide: function () {},
            onDoubleswipeup: function (b) {
                a.mediaOverlay.hide();
                window.issue.router.handleDoubleSwipeUp(b)
            },
            onDoubleswipedown: function (b) {
                a.mediaOverlay.hide();
                window.issue.router.handleDoubleSwipeDown(b)
            },
            onSymmetricalPinch: function () {
                a.mediaOverlay.hide()
            }
        })
    };
    b.prototype.trackArticlePage = function (a) {
        Pressly.track(["page", "navigate", "pageObject", void 0, a, this.paging.pages.length], window.issue.router.manifest.get(this.id))
    };
    b.prototype.afterTextflowInit = function (a, b) {
        var e = this;
        this.initializePaging(a.get(0), b);
        this.toolbar.updatePageNumbering(1, e.paging.pages.length);
        this.trackArticlePage(1);
        this.paging.addPageChangeListener(function (a, b) {
            a !== b && (e.toolbar.updatePageNumbering(a + 1, e.paging.pages.length), e.trackArticlePage(a + 1))
        });
        this.asyncOverlay && this.asyncOverlay.remove();
        this.paging.onShow()
    };
    b.prototype.initializeTextflow = function () {
        var a = this,
            b = $(this.element).find("article").eq(0);
        if (this.hasTextflowableContent() && !this.paging) a.textflow ? a.textflow.handleViewportChange() : a.textflow = new Pressly.Textflow(b, {
            split: "words",
            continuation: function () {
                if (!a.destroyed) {
                    var e = b.data("page-class");
                    a.afterTextflowInit(b, e)
                }
            }
        })
    };
    Pressly.Article = b
})();
(function () {
    function b(a, b) {
        this.defaults = {};
        Pressly.Core.apply(this, arguments)
    }
    b.dispatch = {};
    b.prototype.init = function () {
        var a = this.getAdContainer();
        a.find("iframe").attr("src", "").hide();
        $(this.element).addClass("ad_preload");
        a.hasClass("iframe-ad") && $(this.element).append($("<div class='spinner-wrapper'><img src='img/spinner.gif' class='spinner' /></div>").css({
            width: "100%",
            height: "100%",
            "z-index": "6000",
            backgroundColor: "white",
            position: "absolute",
            left: 0,
            top: 0
        }))
    };
    b.pageHasBigBoxAds = function (a) {
        return $(a.element).find(".ad-container:visible").length > 0
    };
    b.prototype.getAdContainer = function () {
        return $(this.element).find(".iframe-ad:visible, .ad-container:visible").eq(0)
    };
    b.prototype.isFullscreen = function () {
        return this.getAdContainer().hasClass("iframe-ad")
    };
    b.prototype.isBigBox = function () {
        return this.getAdContainer().hasClass("ad-container")
    };
    b.prototype.beforeShow = function () {};
    b.prototype.onShow = function () {
        var a = this,
            c = this.getAdContainer(),
            e = this.getAdContainer().find("iframe"),
            f = e.data("src") || "",
            h = Math.round(Math.random() * 9999999999),
            f = f.indexOf("?") > -1 ? f + "&rnd=" + h : f + "?rnd=" + h;
        e.show();
        e.attr("src", f);
        c.data("rendered", true);
        Pressly.track(["ui-event", "ad-impression", f, {
            src: f,
            context: this.options.context
        }]);
        this.dispatchId = "" + (new Date).getTime();
        b.dispatch[this.dispatchId] = this;
        this.readyCheckInterval = setInterval(function () {
            var b = e.get(0);
            (b = b && b.contentWindow) ? b.postMessage({
                query: "ready?",
                dispatchId: a.dispatchId
            }, "*") : a.stopReadyCheck()
        }, 300)
    };
    b.prototype.receiveMessage = function (a) {
        if (a) switch (a.type) {
        case "ready":
            this.stopReadyCheck();
            if (a.options) this.options = _.extend(this.options, a.options);
            this.ready()
        }
    };
    b.prototype.stopReadyCheck = function () {
        clearInterval(this.readyCheckInterval);
        this.readyCheckInterval = null;
        b.dispatch.hasOwnProperty(this.dispatchId) && delete b.dispatch[this.dispatchId]
    };
    b.prototype.ready = function () {
        if (!this.isBigBox() && (this.options.useNavTabs || this.options.disableTouchPropagation) && !this.nextTab && !this.prevTab) this.nextTab = $("<div />").addClass("tab next"), this.prevTab = $("<div />").addClass("tab prev"), $(this.element).find(".iframe-ad").append(this.nextTab),
        $(this.element).find(".iframe-ad").append(this.prevTab), this.nextTabBox = new Pressly.Box(this.nextTab), this.nextTabBox.addAction(function () {
            var a = window.issue.router.pageLayer.pages.nextPage.index;
            a !== void 0 && window.issue.router.pageLayer.snapToPage(a)
        }), this.prevTabBox = new Pressly.Box(this.prevTab), this.prevTabBox.addAction(function () {
            var a = window.issue.router.pageLayer.pages.previousPage.index;
            a !== void 0 && window.issue.router.pageLayer.snapToPage(a)
        });
        this.options.enableGyro && window.addEventListener("deviceorientation",

        function (a) {
            var b = iframe.get(0).contentWindow;
            if (b) a.type = "deviceorientation", b.postMessage(a, "*")
        }, false);
        $(this.element).find(".spinner-wrapper").remove();
        $(this.element).removeClass("ad_preload")
    };
    b.prototype.onHide = function () {
        this.stopReadyCheck();
        this.init()
    };
    b.prototype.handleViewportChange = function () {};
    b.prototype.destroy = function () {
        var a = this.getAdContainer();
        this.stopReadyCheck();
        a.find("iframe").remove()
    };
    Pressly.Ad = b
})();
(function () {
    function b(a, b) {
        this.defaults = {
            disableGestures: true,
            recipient: "feedback@pressly.com"
        };
        Pressly.Core.apply(this, arguments)
    }
    b.prototype.init = function () {
        var a = this;
        this.toggleButton = $(".button.feedback");
        this.toggleButton.live("click", function (b) {
            b.preventDefault();
            a.toggleVisibility()
        });
        this.rateButtons = [];
        $(".rate li", this.element).each(function (b, e) {
            var f = new Pressly.Box(e);
            f.addAction(function () {
                a.updateRating(e)
            });
            Array.prototype.push.call(a.rateButtons, f)
        });
        this.formWrapper = $(this.element).detach();
        this.formUnderlay = $("<div>", {
            "class": "feedback_underlay"
        })
    };
    b.prototype.toggleVisibility = function () {
        $(".feedback_form").hasClass("visible") === true ? this.hide() : this.show()
    };
    b.prototype.show = function () {
        $("body").append(this.formUnderlay).append(this.formWrapper);
        this.resetFeedback();
        this.attachActions();
        this.formWrapper.addClass("visible");
        this.toggleButton.addClass("selected")
    };
    b.prototype.hide = function () {
        this.detachActions();
        this.formWrapper.removeClass("confirm visible");
        this.formWrapper.detach();
        this.formUnderlay.detach();
        this.toggleButton.removeClass("selected")
    };
    b.prototype.resetFeedback = function () {
        $(".feedback_form form").find(".rate").attr("class", "rate").end().find("input[name='rating']").val("0").end().find("button").attr("disabled", "").end().get(0).reset()
    };
    b.prototype.attachActions = function () {
        this.attachUnderlayAction();
        this.attachSubmitAction();
        this.attachCommentsAction()
    };
    b.prototype.detachActions = function () {
        this.detachUnderlayAction();
        this.detachSubmitAction();
        this.detachCommentsAction()
    };
    b.prototype.attachUnderlayAction = function () {
        var a = this;
        this.formUnderlay.bind("click", function () {
            a.hide()
        })
    };
    b.prototype.detachUnderlayAction = function () {
        this.formUnderlay.unbind("click")
    };
    b.prototype.attachSubmitAction = function () {
        var a = this;
        $(".feedback_form form[name='feedback-form']").bind("submit", function (b) {
            var e = $(this),
                e = a.populateXHRData(e);
            b.preventDefault();
            a.feedbackSent();
            $.ajax({
                url: "http://services.pressly.com/feedback",
                data: e,
                dataType: "jsonp",
                error: function (a, b, c) {
                    console.error("Error sending feedback: " + c)
                }
            })
        })
    };
    b.prototype.detachSubmitAction = function () {
        this.formWrapper.find("form[name='feedback-form']").unbind("submit")
    };
    b.prototype.attachCommentsAction = function () {
        var a = this;
        this.formWrapper.find("textarea[name='comments']").bind("change", function () {
            var b = $(this),
                e = a.formWrapper.find("button");
            $.trim(b.val()) === "" && e.attr("disabled") !== "disabled" ? e.attr("disabled", "") : $.trim(b.val()) !== "" && e.attr("disabled") === "disabled" && e.removeAttr("disabled")
        })
    };
    b.prototype.detachCommentsAction = function () {
        this.formWrapper.find("textarea[name='comments']").unbind("change")
    };
    b.prototype.updateRating = function (a) {
        a = $(a);
        a.parent().removeClass().addClass("rate " + a.attr("class")).siblings("input[name='rating']").val(a.text())
    };
    b.prototype.populateXHRData = function (a) {
        return {
            issue: window.location.hostname || "an issue with no hostname",
            email: a.find("input[name='email']").val() || "user did not provide email",
            comments: a.find("textarea[name='comments']").val() || "user did not comment",
            rating: a.find("input[name='rating']").val() || "user did not rate",
            recipient: this.options.recipient
        }
    };
    b.prototype.feedbackSent = function () {
        this.formWrapper.addClass("confirm")
    };
    b.prototype.destroy = function () {
        this.hide();
        for (var a = 0; a < this.rateButtons.length; a++) this.rateButtons[a].destroy();
        $(this.element).remove();
        this.options = this.element = void 0
    };
    Pressly.Feedback = b
})();
(function () {
    var b = function (a, b) {
        Pressly.Core.apply(this, arguments)
    };
    b.prototype.init = function () {
        var a = this;
        this.loadedTests = {
            sectiontest: function (a) {
                b.startTesting();
                var c = issue.router.manifest.getPageByIndex(0);
                issue.router.goTo(c.id, function () {
                    var c = window.issue.router;
                    Pressly.Util.stopwatch();
                    var f = _.map(c.manifest.allPages(), function (a) {
                        return a.id
                    }).reverse(),
                        n = f.length,
                        k = 0,
                        l = function () {
                            if (f.length > 0) {
                                var i = f.pop();
                                c.goTo(i, function () {
                                    document.title = "at pageIndex:" + k + " / " + n;
                                    k++;
                                    setTimeout(function () {
                                        l()
                                    },
                                    1)
                                })
                            } else setTimeout(function () {
                                b.finishTesting();
                                typeof a === "function" && a()
                            }, 1E3)
                        };
                    f.pop();
                    l()
                })
            },
            sectionnavtest: function (a) {
                var b = issue.router.manifest.allArticles()[0];
                b ? window.issue.router.goTo(b.pageId, function () {
                    var b = $("header.current .button.section_nav");
                    b.length > 0 ? (Pressly.Box.clickAtElement(b), setTimeout(function () {
                        var b = _($("nav.links .nav-link").not(".current").map(function (a, b) {
                            return $(b).attr("href")
                        })).map(function (a) {
                            return a
                        }),
                            c = true,
                            f = function () {
                                if (b.length === 0) typeof a === "function" && a();
                                else {
                                    var h = b.shift(),
                                        i = $("header.current .button.section_nav");
                                    if (c === true) c = false;
                                    else if (i.length > 0) Pressly.Box.clickAtElement(i);
                                    else throw "could not find section nav button to click to bring down nav";
                                    setTimeout(function () {
                                        var a = "nav.links .nav-link[href='" + h + "']";
                                        console.log("nextSelector = ", a);
                                        a = $(a);
                                        a.length > 0 ? (Pressly.Box.clickAtElement(a), setTimeout(function () {
                                            f()
                                        }, 2E3)) : console.error("could not find button for next section")
                                    }, 1500)
                                }
                            };
                        f()
                    }, 1500)) : console.error("test failed, could not locate section nav button.")
                }) : console.error("test failed, could not locate an article.")
            },
            articletest: function (a) {
                b.startTesting();
                var c = window.issue.router,
                    h = Pressly.Util.stopwatch(),
                    j = _.map(c.manifest.allPages(), function (a) {
                        return a.id
                    }).reverse().pop(),
                    n = 0,
                    k = function () {
                        document.title = "at articleIndex:" + n + " / " + (issue.router.articleLayer.pages.length - 1) + " waiting for textflow";
                        var a = setInterval(function () {
                            var b = function (b, c) {
                                clearInterval(a);
                                document.title = "at articleIndex:" + n + " / " + (issue.router.articleLayer.pages.length - 1) + " OK";
                                n++;
                                if (b === true) setTimeout(function () {
                                    i()
                                }, 1);
                                else throw c;
                            }, c = issue.router.articleLayer.pages.currentPage;
                            if (c && c.article) if (c.article.paging && c.article.hasTextflowableContent()) {
                                var e = $(c.element).find("footer[role='toolbar'] span.pagenumber").data("total"),
                                    c = $(c.element).find(".subpage").length;
                                console.log("number of pages in article:", e, "number of .subpage elements ", c);
                                typeof e === "number" && e > 0 ? c === e ? b(true) : b(false, "count of .subpage in article does not match claimed page count") : b(false, "number of pages in article in 0 or undefined (value: " + e + ")")
                            } else b(true)
                        }, 250)
                    }, l = true,
                    i = function () {
                        n < issue.router.articleLayer.pages.length ? l === true ? (l = false, c.showArticleLayerAtPage(n, k)) : (c.articleLayer.unlock(), c.articleLayer.gotoNextPage(k)) : (c.hideArticleLayer(), setTimeout(function () {
                            c.goTo(j, function () {
                                console.log("finished article test in " + h() + "ms");
                                b.finishTesting();
                                typeof a === "function" && a()
                            })
                        }, 1500))
                    }, r = _.map(c.manifest.allArticles(), function (a) {
                        return a.id
                    }).reverse(),
                    r = c.manifest.get(r.pop()).pageId;
                c.goTo(r, function () {
                    document.title = "seeking to page containing first article";
                    setTimeout(function () {
                        i()
                    }, 1E3)
                })
            },
            gallerytest: function (a) {
                b.startTesting();
                var c = window.issue.router,
                    h = c.manifest.allGalleries();
                if (h.length > 0) {
                    var j = h.pop();
                    c.goTo(j.pageId, function () {
                        setTimeout(function () {
                            c.showArticleLayerAtPage(j.index, function () {
                                setTimeout(function () {
                                    document.title = "opening gallery";
                                    var b = $(c.articleLayer.pages.currentPage.element).find(".image_container[data-action]");
                                    console.log("galleryRefElem",
                                    b);
                                    b = b.data("id");
                                    console.log("galleryId ", b);
                                    c.goToMediaInForegroundArticle(b);
                                    setTimeout(function () {
                                        c.articleLayer.pages.currentPage.article.mediaOverlay.hide();
                                        setTimeout(function () {
                                            c.hideArticleLayer();
                                            typeof a === "function" && a()
                                        }, 2E3)
                                    }, 2E3)
                                }, 1500)
                            })
                        }, 1500)
                    })
                }
            },
            adtest: function () {
                console.log("adtest");
                window.issue.router.goTo("ad02");
                console.log("adtest going to page before ad");
                var a = window.issue.router.manifest.get("ad02");
                window.issue.router.goTo(a.index - 2)
            },
            infobutton: function (a) {
                var b = window.issue.router.manifest.allBySelector("toc");
                b.length > 0 && window.issue.router.goTo(b[0].id, function () {
                    var b = $(".button.info");
                    b.length > 0 ? (Pressly.Box.clickAtElement(b), setTimeout(function () {
                        if ($(".info.modal").length > 0) {
                            var b = $(".info.modal .close");
                            console.log("closeButton.length = ", b.length);
                            b.length > 0 ? (Pressly.Box.clickAtElement(b), setTimeout(function () {
                                typeof a === "function" && (console.log("here"), a())
                            }, 1E3)) : console.error("test failed, cannot find close button for info modal")
                        } else console.error("test failed, cannot find info modal")
                    }, 1E3)) : console.error("test failed, cannot find button which launches info modal")
                })
            },
            helpbutton: function (a) {
                var b = window.issue.router.manifest.allBySelector("toc");
                b.length > 0 && window.issue.router.goTo(b[0].id, function () {
                    var b = $(".button.help");
                    b.length > 0 ? (Pressly.Box.clickAtElement(b), setTimeout(function () {
                        if ($(".help.modal").length > 0) {
                            var b = $(".help.modal .close");
                            b.length > 0 ? (Pressly.Box.clickAtElement(b), setTimeout(function () {
                                typeof a === "function" && a()
                            }, 1E3)) : console.error("test failed, cannot find close button for help modal")
                        } else console.error("test failed, cannot find help modal")
                    },
                    1E3)) : console.error("test failed, cannot find button which launches help modal")
                })
            },
            presslybutton: function (a) {
                issue.router.goTo(window.issue.router.pageLayer.pages.get(0).id, function () {
                    var b = $("footer div.credit");
                    b.length > 0 && (Pressly.Box.clickAtElement(b), setTimeout(function () {
                        if ($(".modal.pressly").length > 0 && $(".modal.pressly").is(":visible")) {
                            var b = $(".modal.pressly .close");
                            b.length > 0 && b.is(":visible") ? (Pressly.Box.clickAtElement(b), setTimeout(function () {
                                typeof a === "function" && a()
                            }, 1E3)) : console.error("test failed, cannot find pressly info modal's close button")
                        } else console.error("test failed, cannot make pressly info modal appear")
                    },
                    1E3))
                })
            },
            fullleaktest: function () {
                a.loadedTests.fulltest(function () {
                    Pressly.destroy();
                    console.info("TRANSITION ANALYZE");
                    Pressly.Transition.analyze();
                    console.info("BOX ANALYZE");
                    Pressly.Box.analyze()
                })
            },
            bareleaktest: function () {
                setTimeout(function () {
                    Pressly.destroy();
                    console.info("TRANSITION ANALYZE");
                    Pressly.Transition.analyze();
                    console.info("BOX ANALYZE");
                    Pressly.Box.analyze()
                }, 4E3)
            },
            fulltest: function (b) {
                a.runTestSuite("pretest,presslybutton,infobutton,helpbutton,sectionnavtest,gallerytest,sectiontest,articletest".split(","),

                function () {
                    typeof b === "function" && b()
                })
            },
            pretest: function (a) {
                issue.router.goTo(window.issue.router.pageLayer.pages.get(0).id, function () {
                    typeof a === "function" && a()
                })
            }
        }
    };
    b.prototype.runTestSuite = function (a, b) {
        var f = Pressly.Util.stopwatch(),
            h = this,
            j = function () {
                if (a.length > 0) {
                    var n = a.shift();
                    console.log("running test '" + n + "'");
                    h.loadedTests[n](j)
                } else console.log("test suite finished in " + f() + "ms"), typeof b === "function" && b()
            };
        j()
    };
    var a = false;
    b.testing = function () {
        return a
    };
    b.startTesting = function () {
        a = true
    };
    b.finishTesting = function () {
        a = false
    };
    b.prototype.findTests = function () {
        for (var a = {}, b = window.location.href.slice(window.location.href.indexOf("?") + 1).split("#")[0].split("&"), f = 0; f < b.length; f++) {
            var h = b[f].split("=");
            a[h[0]] = h[1]
        }
        a.test == "true" && (a = this.loadedTests[a.name], typeof a === "function" && a())
    };
    window.Pressly.Test = b
})();
(function () {
    function b(a, b) {
        this.defaults = {
            transitionDuration: 400
        };
        Pressly.Core.apply(this, arguments)
    }
    b.Group = {};
    b.overlay = $("<div class='modal-overlay'></div>");
    b.overlayButton = new Pressly.Box(b.overlay);
    b.overlayButton.addAction(function () {
        b.hideAll(false)
    });
    b.overlayTransition = new Pressly.Transition(b.overlay, {
        property: "opacity",
        on: "1",
        off: "0",
        duration: 400
    });
    b.hideAll = function (a) {
        _(b.Group).each(function (b) {
            _(b).each(function (b) {
                b.hide(false, a)
            })
        })
    };
    b.prototype.init = function () {
        var a = this,
            c = {
                articleOptions: ".articles.current:visible .options.modal"
            },
            e = $(this.element).data("modal-location");
        this.modalElement = c.hasOwnProperty(e) ? $(document.body).find(c[e]) : $(this.element).find(".modal");
        $(this.element).data("recreate") == void 0 && this.modalElement.remove();
        if ($(this.element).data("clone") != void 0) this.modalElement = this.modalElement.clone();
        this.group = $(this.element).data("modal-group") || "none";
        this.modalBox = new Pressly.Box(this.modalElement);
        this.closeButton = new Pressly.Box(this.modalElement.find(".close"));
        this.closeButton.addAction(function () {
            a.hide()
        });
        b.Group[this.group] || (b.Group[this.group] = []);
        b.Group[this.group].push(this);
        this.modalTransition = new Pressly.Transition(this.modalElement, {
            property: "opacity",
            on: "1",
            off: "0",
            duration: a.options.transitionDuration,
            transitionEnd: function () {
                switch (this.state) {
                case "off":
                    b.overlay.detach(), a.modalElement.detach()
                }
            }
        })
    };
    b.prototype.isActive = function () {
        return !this.modalTransition.is("off")
    };
    b.prototype.hasGroup = function () {
        return this.group !== "none"
    };
    b.prototype.toggle = function () {
        return this.isActive() ? this.hide() : this.show()
    };
    b.prototype.show = function () {
        var a = this;
        this.hasGroup() && _(b.Group[this.group]).each(function (b) {
            b !== a && b.isActive() && b.hide(true, true)
        });
        $("#wrapper").append(b.overlay).append(this.modalElement);
        $(this.element).addClass("selected");
        setTimeout(function () {
            b.overlayTransition.on();
            a.modalTransition.on()
        }, 0)
    };
    b.prototype.hide = function (a, c) {
        $(this.element).removeClass("selected");
        a || b.overlayTransition.off();
        this.modalTransition.off({
            duration: c ? 0 : this.options.transitionDuration
        })
    };
    b.prototype.handleViewportChange = function () {};
    b.prototype.destroy = function () {
        this.closeButton.destroy();
        this.modalTransition.destroy();
        b.overlay.detach();
        this.modalElement.remove();
        this.modalElement = void 0;
        b.Group[this.group].splice(b.Group[this.group].indexOf(this), 1)
    };
    b.destroy = function () {
        b.overlayButton && (b.overlayButton.destroy(), delete b.overlayButton)
    };
    Pressly.Modal = b
})();
(function (b) {
    function a(a, b) {
        this.defaults = {};
        Pressly.Core.call(this, a, b)
    }
    a.isUnlocked = function (a, b) {
        if (a === null || typeof a == "undefined") return false;
        var f = _(a.substr(1).split("&")).map(function (a) {
            return {
                param: a.split("=")[0],
                value: a.split("=")[1]
            }
        });
        return (f = _(f).detect(function (a) {
            return a.param === "key"
        })) && f.value === b ? true : false
    };
    a.prototype.init = function () {
        var a = this,
            b = $("<div class='modal' style='margin: 0 0 0 0; background: white; width:1024px; height:1024px'><div style='background: white; width:100%;height:50%;text-align:center;'><span>Password:</span><input id='password' type='password' /><input id='okbutton' type='button' value='Enter'/></div></div>");
        this.modal = new Pressly.Modal(b, {});
        this.modal.show();
        b.find("#okbutton").click(function () {
            if (md5(b.find("#password").val()) === a.options.key) document.location.href = document.location.href.indexOf("?") > -1 ? document.location.href + "&key=" + a.options.key : document.location.href + "?key=" + a.options.key
        })
    };
    a.prototype.success = function () {
        this.modal.hide();
        this.options.callback();
        this.destroy()
    };
    a.prototype.destroy = function () {
        this.modal.destroy()
    };
    b.Pressly.Lock = a
})(window);
(function () {
    function b(b, k) {
        var l = b[0],
            i = b[1],
            j = b[2],
            p = b[3],
            l = c(l, i, j, p, k[0], 7, - 680876936),
            p = c(p, l, i, j, k[1], 12, - 389564586),
            j = c(j, p, l, i, k[2], 17, 606105819),
            i = c(i, j, p, l, k[3], 22, - 1044525330),
            l = c(l, i, j, p, k[4], 7, - 176418897),
            p = c(p, l, i, j, k[5], 12, 1200080426),
            j = c(j, p, l, i, k[6], 17, - 1473231341),
            i = c(i, j, p, l, k[7], 22, - 45705983),
            l = c(l, i, j, p, k[8], 7, 1770035416),
            p = c(p, l, i, j, k[9], 12, - 1958414417),
            j = c(j, p, l, i, k[10], 17, - 42063),
            i = c(i, j, p, l, k[11], 22, - 1990404162),
            l = c(l, i, j, p, k[12], 7, 1804603682),
            p = c(p, l, i, j, k[13], 12, - 40341101),
            j = c(j, p, l, i, k[14], 17, - 1502002290),
            i = c(i, j, p, l, k[15], 22, 1236535329),
            l = e(l, i, j, p, k[1], 5, - 165796510),
            p = e(p, l, i, j, k[6], 9, - 1069501632),
            j = e(j, p, l, i, k[11], 14, 643717713),
            i = e(i, j, p, l, k[0], 20, - 373897302),
            l = e(l, i, j, p, k[5], 5, - 701558691),
            p = e(p, l, i, j, k[10], 9, 38016083),
            j = e(j, p, l, i, k[15], 14, - 660478335),
            i = e(i, j, p, l, k[4], 20, - 405537848),
            l = e(l, i, j, p, k[9], 5, 568446438),
            p = e(p, l, i, j, k[14], 9, - 1019803690),
            j = e(j, p, l, i, k[3], 14, - 187363961),
            i = e(i, j, p, l, k[8], 20, 1163531501),
            l = e(l, i, j, p, k[13], 5, - 1444681467),
            p = e(p, l, i, j, k[2], 9, - 51403784),
            j = e(j, p, l, i, k[7], 14, 1735328473),
            i = e(i, j, p, l, k[12], 20, - 1926607734),
            l = a(i ^ j ^ p, l, i, k[5], 4, - 378558),
            p = a(l ^ i ^ j, p, l, k[8], 11, - 2022574463),
            j = a(p ^ l ^ i, j, p, k[11], 16, 1839030562),
            i = a(j ^ p ^ l, i, j, k[14], 23, - 35309556),
            l = a(i ^ j ^ p, l, i, k[1], 4, - 1530992060),
            p = a(l ^ i ^ j, p, l, k[4], 11, 1272893353),
            j = a(p ^ l ^ i, j, p, k[7], 16, - 155497632),
            i = a(j ^ p ^ l, i, j, k[10], 23, - 1094730640),
            l = a(i ^ j ^ p, l, i, k[13], 4, 681279174),
            p = a(l ^ i ^ j, p, l, k[0], 11, - 358537222),
            j = a(p ^ l ^ i, j, p, k[3], 16, - 722521979),
            i = a(j ^ p ^ l, i, j, k[6], 23, 76029189),
            l = a(i ^ j ^ p, l, i, k[9], 4, - 640364487),
            p = a(l ^ i ^ j, p, l, k[12], 11, - 421815835),
            j = a(p ^ l ^ i, j, p, k[15], 16, 530742520),
            i = a(j ^ p ^ l, i, j, k[2], 23, - 995338651),
            l = f(l, i, j, p, k[0], 6, - 198630844),
            p = f(p, l, i, j, k[7], 10, 1126891415),
            j = f(j, p, l, i, k[14], 15, - 1416354905),
            i = f(i, j, p, l, k[5], 21, - 57434055),
            l = f(l, i, j, p, k[12], 6, 1700485571),
            p = f(p, l, i, j, k[3], 10, - 1894986606),
            j = f(j, p, l, i, k[10], 15, - 1051523),
            i = f(i, j, p, l, k[1], 21, - 2054922799),
            l = f(l, i, j, p, k[8], 6, 1873313359),
            p = f(p, l, i, j, k[15], 10, - 30611744),
            j = f(j, p, l, i, k[6], 15, - 1560198380),
            i = f(i, j, p, l, k[13], 21, 1309151649),
            l = f(l, i, j, p,
            k[4], 6, - 145523070),
            p = f(p, l, i, j, k[11], 10, - 1120210379),
            j = f(j, p, l, i, k[2], 15, 718787259),
            i = f(i, j, p, l, k[9], 21, - 343485551);
        b[0] = h(l, b[0]);
        b[1] = h(i, b[1]);
        b[2] = h(j, b[2]);
        b[3] = h(p, b[3])
    }
    function a(a, b, c, e, f, j) {
        b = h(h(b, a), h(e, j));
        return h(b << f | b >>> 32 - f, c)
    }
    function c(b, c, e, f, h, j, s) {
        return a(c & e | ~c & f, b, c, h, j, s)
    }
    function e(b, c, e, f, h, j, s) {
        return a(c & f | e & ~f, b, c, h, j, s)
    }
    function f(b, c, e, f, h, j, s) {
        return a(e ^ (c | ~f), b, c, h, j, s)
    }
    function h(a, b) {
        return a + b & 4294967295
    }
    var j = "0123456789abcdef".split("");
    md5 = function (a) {
        var c = a;
        /[\x80-\xFF]/.test(c) && (c = unescape(encodeURI(c)));
        txt = "";
        var e = c.length,
            a = [1732584193, - 271733879, - 1732584194, 271733878],
            f;
        for (f = 64; f <= c.length; f += 64) {
            for (var h = a, p = c.substring(f - 64, f), s = [], x = void 0, x = 0; x < 64; x += 4) s[x >> 2] = p.charCodeAt(x) + (p.charCodeAt(x + 1) << 8) + (p.charCodeAt(x + 2) << 16) + (p.charCodeAt(x + 3) << 24);
            b(h, s)
        }
        c = c.substring(f - 64);
        h = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        for (f = 0; f < c.length; f++) h[f >> 2] |= c.charCodeAt(f) << (f % 4 << 3);
        h[f >> 2] |= 128 << (f % 4 << 3);
        if (f > 55) {
            b(a, h);
            for (f = 0; f < 16; f++) h[f] = 0
        }
        h[14] = e * 8;
        b(a, h);
        for (c = 0; c < a.length; c++) {
            e = a;
            f = c;
            h = a[c];
            p = "";
            for (s = 0; s < 4; s++) p += j[h >> s * 8 + 4 & 15] + j[h >> s * 8 & 15];
            e[f] = p
        }
        return a.join("")
    }
})();
(function () {
    var b = {
        plugins: {},
        registerPlugin: function (a) {
            b.plugins[a.pluginName] = a.construct;
            for (var c in a) a.hasOwnProperty(c) && c !== "construct" && c !== "pluginName" && c !== "configure" && (b.plugins[a.pluginName].prototype[c] = a[c]);
            if (typeof a.configure === "function") b.plugins[a.pluginName].configure = a.configure
        }
    };
    Pressly.Plugin = b
})();
(function () {
    var b = {};
    Pressly.Plugin.registerPlugin({
        pluginName: "Gigya",
        configure: function (a) {
            b = a
        },
        construct: function (a, c) {
            this.defaults = {};
            if (c && c.streamId && c.categoryId) this.streamId = c.streamId, this.categoryId = c.categoryId;
            else throw "The Gigya plugin has not been correctly initialized. Please ensure categoryId and streamId have been supplied";
            if (b && b.conf != null && typeof b.conf.APIKey === "string") this.conf = b.conf;
            else throw "The Gigya plugin has not been fully configured. Please ensure at least conf:{APIKey:'....'} has been supplied";
            if (typeof this.conf.maxDepth == "undefined") this.conf.maxDepth = 5;
            this.boxes = [];
            this.loggedIn = false;
            this.userObject = null;
            Pressly.Core.apply(this, arguments)
        },
        getGigyaInstance: function (a, b, e) {
            if (typeof a === "undefined" || typeof b === "undefined") {
                var f = window.issue.router.manifest.get(window.issue.router.articleLayer.pages.currentPage.id);
                if (typeof b === "undefined") b = f.gigyaStreamId;
                if (typeof a === "undefined") a = f.gigyaCategoryId
            }
            return new Pressly.Plugin.plugins.Gigya(e, {
                categoryId: a,
                streamId: b,
                success: function (a) {
                    var b = $(a.element).find(".comments");
                    a.scroll = new Pressly.Scroll(b, {
                        orientation: "vertical"
                    })
                },
                onDestroy: function () {}
            })
        },
        destroy: function () {
            for (var a = 0; a < this.boxes; a++) this.boxes[a].destroy(), this.boxes[a] = void 0;
            if (this.options && typeof this.options.onDestroy === "function") this.options.onDestroy();
            this.userObject = this.boxes = void 0
        },
        init: function () {
            var a = this,
                b = function () {
                    a.getComments(function (b) {
                        var c = a.renderComments(b);
                        a.id = "gigya_container_" + Math.round(Math.random() * 999999999).toString(16);
                        var h = $("<div class='title'></div>");
                        h.append($("<h3></h3>").text(typeof b.commentCount === "number" && b.commentCount > 0 ? b.commentCount + " comments" : "Comments"));
                        a.canComment() || (b = $("<a class='desktop' data-action='gotoExternal'>Visit full site to comment</a>"), b.attr("data-path", $(a.element).attr("data-original-url")), a.boxes.push(new Pressly.Box(b)), h.append(b));
                        $(a.element).append(h);
                        h = $("<div class='gigya_ui_wrapper'></div>").attr("id", a.id);
                        $(a.element).append(h);
                        h.append(c);
                        a.canComment() && (c = $("<div class='reply_form_container'></div>"),
                        b = a.renderReplyForm(void 0), c.append(b), h.prepend(c));
                        typeof a.options.success === "function" && a.options.success(a)
                    }, function (a) {
                        console.error("Error getting comments: " + a)
                    })
                };
            window.gigya ? b() : (window.onGigyaServiceReady = b, b = document.createElement("script"), b.src = "http://cdn.gigya.com/js/socialize.js?apikey=" + this.conf.APIKey, $("html").append(b))
        },
        postReply: function (a, b, e) {
            console.log("postReply(" + a + "), this.conf.APIKey = " + this.conf.APIKey);
            gigya.services.comments.postComment(this.conf, _.extend({
                categoryID: this.categoryId,
                streamID: this.streamId,
                commentText: a,
                callback: e
            }, typeof b != void 0 ? {
                parentID: b
            } : void 0))
        },
        renderReplyForm: function (a, b) {
            typeof b == void 0 && (b = 1);
            var e = $("<span class='reply_post_button'>Post</span>"),
                f = $("<textarea></textarea>"),
                h = $("<div class='reply_form'></div>").append(f).append(e),
                j = this,
                n = new Pressly.Box(e[0]);
            n.addAction(function () {
                document.activeElement.blur();
                $("input").blur();
                var h = e.closest("li.comment");
                h.length == 0 && (h = e.closest(".gigya_ui_wrapper").children(".vertical-scroll").children("ol.comments"));
                var l = $.trim(f.val());
                l.length > 0 && l.length < 5E3 && j.login(function () {
                    j.postReply(l, a, function (a) {
                        console.log("postReply callback, response.errorCode = " + a.errorCode);
                        if (a && a.errorCode === 0 && a.comment) {
                            var a = j.renderComment(a.comment, b),
                                e = h.is("ol.comments") ? h : h.children("ol.replies");
                            e.length == 0 && (e = h.children("ol.comments"));
                            e.is("ol.comments") ? $(".reply_form textarea").val("") : h.find(".reply_form").remove();
                            e.show().prepend(a)
                        } else console.error(a.errorMessage + " -> (" + a.errorDetails + ")")
                    })
                })
            });
            this.boxes.push(n);
            return h
        },
        renderComments: function (a) {
            var b = $("<ol class='comments root'></ol>");
            if (a && a.comments && a.comments.length > 0) for (var e = 0; e < a.comments.length; e++) {
                var f = this.renderComment(a.comments[e]);
                b.append(f)
            }
            return b
        },
        renderComment: function (a, b) {
            typeof b == "undefined" && (b = 1);
            var e = this,
                f = $("<li class='comment'></li>"),
                h = a.sender.photoURL && typeof a.sender.photoURL === "string" && a.sender.photoURL.length > 0 ? a.sender.photoURL : "./img/icons/default_avatar.gif",
                j = a.sender.profileURL && typeof a.sender.profileURL === "string" && a.sender.profileURL.length > 0 ? a.sender.profileURL : "",
                j = $("<a class='profile_image_link'></a>").attr("href", j),
                h = $("<img class='profile_image' />").attr("src", h);
            j.append(h);
            f.append(j);
            h = $("<div class='comment-body'></div>");
            h.append($("<span class='comment_text'></span>").html(a.commentText));
            j = $("<span class='name'></span>").text(a.sender.name);
            h.append(j);
            h.append($("<span class='comment_timestamp'></span>").text(Pressly.Util.timeago(a.timestamp)));
            f.append(h);
            if (n && k) {
                var j = $("<span class='votes'>"),
                    n = typeof a.posVotes === "number" ? a.posVotes : 0,
                    k = typeof a.negVotes === "number" ? a.negVotes : 0,
                    l = $("<span class='positive_votes_button " + (n === 0 ? "zero" : "") + "'></span>").text(n === 0 ? "+" : "+" + n),
                    i = new Pressly.Box(l[0]);
                i.addAction(function () {
                    l.closest("ol.comments.root");
                    e.login(function () {
                        gigya.services.comments.vote(e.conf, {
                            commentID: a.ID,
                            categoryID: e.categoryId,
                            streamID: e.streamId,
                            vote: "pos",
                            callback: function () {
                                n += 1;
                                l.text(n)
                            }
                        })
                    })
                });
                this.boxes.push(i);
                var r = $("<span class='negative_votes_button " + (k === 0 ? "zero" : "") + "'></span>").text(k === 0 ? "-" : "-" + k),
                    i = new Pressly.Box(r[0]);
                i.addAction(function () {
                    r.closest("ol.comments.root");
                    e.login(function () {
                        gigya.services.comments.vote(e.conf, {
                            commentID: a.ID,
                            categoryID: e.categoryId,
                            streamID: e.streamId,
                            vote: "neg",
                            callback: function () {
                                k += 1;
                                r.text(k)
                            }
                        })
                    })
                });
                this.boxes.push(i);
                j.append(l);
                j.append(r);
                f.append(j)
            }
            if (b < this.conf.maxDepth && e.canComment()) {
                var p = $("<div class='reply_form_container'></div>"),
                    s = $("<span class='reply_button'></span>").text("Reply"),
                    h = new Pressly.Box(s[0]);
                h.addAction(function () {
                    s.closest("ol.comments.root").find(".reply_form").each(function (a, b) {
                        $(b).parent().is("ol.comments.root") ? $(b).find("textarea").val("") : $(b).remove()
                    });
                    var f = e.renderReplyForm(a.ID, b + 1);
                    p.append(f);
                    e.scroll.calculateDimensions()
                });
                this.boxes.push(h);
                f.append(s);
                f.append(p)
            } else h.addClass("no_reply_button");
            h = $("<ol class='replies'></ol>");
            if (a.replies && a.replies.length > 0) for (j = 0; j < a.replies.length; j++) h.append(e.renderComment(a.replies[j], b + 1));
            else h.hide();
            f.append(h);
            return f
        },
        getComments: function (a, b, e, f) {
            gigya.services.comments.getComments(this.conf, {
                categoryID: this.categoryId,
                streamID: this.streamId,
                callback: function (e) {
                    e.errorCode == 0 || e.comments != null ? a(e) : b(e.errorMessage + " -> (" + e.errorDetails + ")")
                },
                threadLimit: typeof e === "number" ? e : void 0,
                start: typeof f === "number" ? f : void 0
            })
        },
        login: function (a) {
            var b = this;
            if (this.loggedIn) console.log("already logged in"), a();
            else {
                console.log("logging in first");
                var e = b.id + "_login",
                    f = $("<div class='gigya_login_container'></div>");
                f.attr("id",
                e);
                $(b.element).find(".gigya_ui_wrapper").append(f);
                gigya.services.socialize.addEventHandlers(this.conf, {
                    onLogin: function (e) {
                        console.log("onLogin");
                        f.remove();
                        console.log("Have user?" + e.user);
                        e.user && (console.log("user name = " + e.user.firstName), console.log("loggedIn? = " + e.user.isLoggedIn));
                        b.userObject = e.user;
                        b.loggedIn = true;
                        a()
                    },
                    onLogout: function () {}
                });
                gigya.services.socialize.showLoginUI(this.conf, {
                    width: f.width(),
                    height: f.height(),
                    showTermsLink: false,
                    hideGigyaLink: true,
                    buttonsStyle: "fullLogo",
                    showWhatsThis: true,
                    containerID: e,
                    cid: ""
                })
            }
        },
        canComment: function () {
            return Pressly.Device.isNamed("Apple iPad iOS 4.3+") || Pressly.Device.isStandAlone() || Pressly.Device.isWebView() ? false : true
        }
    })
})();