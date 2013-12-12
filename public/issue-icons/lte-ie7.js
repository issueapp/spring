/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

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
			'icon-link' : '&#xe00a;',
			'icon-comment' : '&#xe00b;',
			'icon-cog' : '&#xe00c;',
			'icon-arrow-left' : '&#xe00d;',
			'icon-arrow-right' : '&#xe00e;',
			'icon-pictures' : '&#xe011;',
			'icon-music' : '&#xe013;',
			'icon-shop' : '&#xe01b;',
			'icon-ccw' : '&#xe01e;',
			'icon-info' : '&#xe01f;',
			'icon-question' : '&#xe020;',
			'icon-user' : '&#xe02a;',
			'icon-search' : '&#xe019;',
			'icon-stream' : '&#xe021;',
			'icon-play' : '&#xe022;',
			'icon-gauge' : '&#xe023;',
			'icon-eye' : '&#xe024;',
			'icon-statistics' : '&#xe025;',
			'icon-brush' : '&#xe026;',
			'icon-archive' : '&#xe027;',
			'icon-plus' : '&#xe028;',
			'icon-cross' : '&#xe029;',
			'icon-list' : '&#xf0c9;',
			'icon-rss' : '&#xe014;',
			'icon-profile' : '&#xe003;',
			'icon-off' : '&#xf011;',
			'icon-edit' : '&#xf044;',
			'icon-minus' : '&#xf068;',
			'icon-ellipsis' : '&#xe005;',
			'icon-plus-2' : '&#xe009;',
			'icon-arrow-left-2' : '&#xe00f;',
			'icon-arrow-right-2' : '&#xe010;',
			'icon-grid' : '&#xe015;',
			'icon-books' : '&#xe016;',
			'icon-books-2' : '&#xe017;',
			'icon-stack' : '&#xe01d;',
			'icon-play-2' : '&#xe012;',
			'icon-menu' : '&#xe006;',
			'icon-tag' : '&#xe018;',
			'icon-cart' : '&#xe01a;',
			'icon-tshirt' : '&#xe02b;',
			'icon-checkmark-circle' : '&#xe02c;',
			'icon-clock' : '&#xe02d;',
			'icon-book' : '&#xe01c;',
			'icon-resize-enlarge' : '&#xe02e;',
			'icon-bold' : '&#xf032;',
			'icon-italic' : '&#xf033;',
			'icon-code' : '&#xe02f;',
			'icon-palette' : '&#xe030;',
			'icon-list-ul' : '&#xf0ca;',
			'icon-list-ol' : '&#xf0cb;',
			'icon-microphone' : '&#xe031;'
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