/* Use this script if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'issue-icons\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-export' : '&#xe000;',
			'icon-heart' : '&#xe001;',
			'icon-earth' : '&#xe002;',
			'icon-docs' : '&#xe004;',
			'icon-twitter' : '&#xe007;',
			'icon-facebook' : '&#xe008;',
			'icon-googleplus' : '&#xe005;',
			'icon-pinterest' : '&#xe009;',
			'icon-camera' : '&#xe006;',
			'icon-link' : '&#xe00a;',
			'icon-comment' : '&#xe00b;',
			'icon-cog' : '&#xe00c;',
			'icon-arrow-left' : '&#xe00d;',
			'icon-arrow-right' : '&#xe00e;',
			'icon-arrow-left-2' : '&#xe00f;',
			'icon-arrow-right-2' : '&#xe010;',
			'icon-pictures' : '&#xe011;',
			'icon-video' : '&#xe012;',
			'icon-music' : '&#xe013;',
			'icon-plus' : '&#xe015;',
			'icon-minus' : '&#xe016;',
			'icon-read' : '&#xe017;',
			'icon-shop' : '&#xe01b;',
			'icon-book' : '&#xe01c;',
			'icon-ccw' : '&#xe01e;',
			'icon-info' : '&#xe01f;',
			'icon-question' : '&#xe020;',
			'icon-user' : '&#xe02a;',
			'icon-tag' : '&#xe018;',
			'icon-search' : '&#xe019;',
			'icon-stackoverflow' : '&#xe01a;',
			'icon-stream' : '&#xe021;',
			'icon-play' : '&#xe022;',
			'icon-gauge' : '&#xe023;',
			'icon-eye' : '&#xe024;',
			'icon-statistics' : '&#xe025;',
			'icon-brush' : '&#xe026;',
			'icon-archive' : '&#xe027;',
			'icon-plus-2' : '&#xe028;',
			'icon-cross' : '&#xe029;',
			'icon-grid' : '&#xf009;',
			'icon-list' : '&#xf0c9;',
			'icon-rss' : '&#xe014;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; i < els.length; i += 1) {
		el = els[i];
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};