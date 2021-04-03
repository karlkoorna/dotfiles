// ==UserScript==
// @name         MB OIT
// @description  Always show "Open in tagger" button on MusicBrainz release pages.
// @author       Karl Köörna
// @version      1.0.0
// @match        https://musicbrainz.org/release/*
// ==/UserScript==

if (!document.querySelector('.releaseheader > .tagger-icon')) {
	document.querySelector('.releaseheader').insertAdjacentHTML('afterbegin', `
		<a class="tagger-icon" href="http://127.0.0.1:8000/openalbum?id=${location.href.slice(9)}" title="Open in tagger">
			<img alt="Tagger" src="https://staticbrainz.org/MB/mblookup-tagger-b8fe559.png">
		</a>
	`);
}
