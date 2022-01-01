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
			<img alt="Tagger" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACkAAAANCAMAAAADg7fkAAAAVFBMVEX////////j4+Nm/5nW1dXMzMzMy6zDw6e6ubmzs56sq6uqq5ihopOfoaSZmZmXmIyNj4WEhX17fHV2c3RmZmZaV1hVVlhMSUpDQ0M/OzwzMzMAAABK1i8nAAAAAXRSTlMAQObYZgAAAIZJREFUeNqNkdsOhCAMRHHVesEF8e74//+pbYjEfXA7KfNQToaSGlG7H3/FXLFunkL+LiYdApGGHNGQiqzR+LkX8hqGLU/GLT5C7rbDd+kl84jFN9FS14CCy9x0k5eYFZNKmZ2Fg//NTCYe57TB04N8zHm/blpY3d8ZHSodaT4zNDsSlYq9n5odFv9PkEJKAAAAAElFTkSuQmCC">
		</a>
	`);
} else {
	document.querySelector('tr').innerHTML += '<th>Tagger</th>';
	for (const el of document.querySelectorAll('th[colspan]')) el.colSpan++;
	for (const el of document.querySelectorAll('.odd, .even')) el.innerHTML += `
		<td>
			<a class="tagger-icon" href="http://127.0.0.1:8000/openalbum?id=${el.querySelector('a[href^="/release/"]').getAttribute('href').replace('/release/', '').replace('/cover-art', '')}" title="Open in tagger">
				<img alt="Tagger" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACkAAAANCAMAAAADg7fkAAAAVFBMVEX////////j4+Nm/5nW1dXMzMzMy6zDw6e6ubmzs56sq6uqq5ihopOfoaSZmZmXmIyNj4WEhX17fHV2c3RmZmZaV1hVVlhMSUpDQ0M/OzwzMzMAAABK1i8nAAAAAXRSTlMAQObYZgAAAIZJREFUeNqNkdsOhCAMRHHVesEF8e74//+pbYjEfXA7KfNQToaSGlG7H3/FXLFunkL+LiYdApGGHNGQiqzR+LkX8hqGLU/GLT5C7rbDd+kl84jFN9FS14CCy9x0k5eYFZNKmZ2Fg//NTCYe57TB04N8zHm/blpY3d8ZHSodaT4zNDsSlYq9n5odFv9PkEJKAAAAAElFTkSuQmCC">
			</a>
		</td>
	`;
}
