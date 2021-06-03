// ==UserScript==
// @name         OTO2MB
// @description  Copy tracklist for MusicBrainz from Ototoy release page.
// @author       Karl Köörna
// @version      1.0.0
// @match        https://ototoy.jp/_/default/p/*
// @grant        GM.setClipboard
// @grant        GM.addStyle
// ==/UserScript==

const ARTIST_SEP = '\t';

const button = document.createElement('a');
button.id = 'oto2mb';
button.innerText = 'Copy tracks for MusicBrainz';

button.addEventListener('click', () => {
	const str = Array.from(document.querySelectorAll('#tracklist tr:not(:first-child)'), (el) => {
		const info = el.querySelector('button[trackcode]');
		return `${info.getAttribute('tn').toString().padStart(2, '0')}. ${info.getAttribute('artist').replace(/ \(.*\)$/, '')}${ARTIST_SEP}${info.getAttribute('title')} (${el.children[2].innerText})`;
	}).join('\n');
	
	GM.setClipboard(str);
});

document.querySelector('.tracklist tr > th:nth-child(2)').appendChild(button);

GM.addStyle(`
#oto2mb {
	margin-left: 13px;
	color: #0e9af1;
	font-size: 12px;
	font-weight: bold;
	cursor: pointer;
}
#oto2mb:hover {
	text-decoration: underline;
}
`);
