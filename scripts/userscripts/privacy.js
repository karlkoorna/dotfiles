// ==UserScript==
// @name         Privacy
// @description  Hige privacy sensitive elements on pages.
// @author       Karl Köörna
// @version      1.0.0
// @run-at       document-start
// @match        <all_urls>
// @grant        GM.addStyle
// ==/UserScript==

GM.addStyle(`

/* General */

#credential_picker_container {
	display: none;
}

/* Spotify */

a[href*="playlist/"] + div, /* Playlist authors on playlist pages. */
a[href*="user/"], /* Playlist authors on user lists. */
[data-testid="user-widget-link"] { /* Profile picture and account name in top-right corner. */
	display: none;
}

/* Google */

#footcnt .fbar:first-of-type, /* Location in footer. */
a[aria-label^="Google Account:"] { /* Profile picture in top-right corner. */
	display: none;
}

/* YouTube */

ytd-masthead #avatar-btn { /* Profile picture in top-right corner. */
	filter: brightness(100) brightness(0.4);
}

ytd-multi-page-menu-renderer a[href*="yourdata/youtube"], /* Your Data item in settings dropdown. */
ytd-multi-page-menu-renderer #header ytd-active-account-header-renderer, /* Account info in settings dropdown. */
ytd-comment-simplebox-renderer { /* Comment box below videos. */
	display: none;
}

/* GitHub */

header img.avatar { /* Profile picture in top-right corner. */
	filter: brightness(100) brightness(0.4);
}

`);
