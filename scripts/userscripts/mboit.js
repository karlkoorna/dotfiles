// ==UserScript==
// @name         MB OIT
// @description  Always show "Open in tagger" button on MusicBrainz release pages.
// @author       Karl Köörna
// @version      1.0.0
// @match        https://musicbrainz.org/release/*
// @match        https://musicbrainz.org/release-group/*
// @match        https://musicbrainz.org/search*type=release*
// ==/UserScript==

if (document.querySelector('.tagger-icon')) return;

if (location.pathname.startsWith('/release/')) {
	document.querySelector('.releaseheader').insertAdjacentHTML('afterbegin', `
		<a class="tagger-icon" href="http://127.0.0.1:8000/openalbum?id=${location.pathname.slice(9)}" title="Open in tagger">
			<img alt="Tagger" src="https://staticbrainz.org/MB/mblookup-tagger-b8fe559.png">
		</a>
	`);
} else {
	document.querySelector('tr').innerHTML += '<th>Tagger</th>';
	for (const el of document.querySelectorAll('th[colspan]')) el.colSpan++;
	for (const el of document.querySelectorAll('.odd, .even')) el.innerHTML += `
		<td>
			<a class="tagger-icon" href="http://127.0.0.1:8080/openalbum?id=${el.querySelector('a[href^="/release/"]').href.replace('/release/', '').replace('/cover-art', '')}" title="Open in tagger">
				<img alt="Tagger" src="https://staticbrainz.org/MB/mblookup-tagger-b8fe559.png">
			</a>
		</td>
	`;
}
