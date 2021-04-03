// ==UserScript==
// @name         Ototoy to MusicBrainz tracklist
// @description  Copy MusicBrainz tracklist from Ototoy release page with CTRL+C.
// @author       Karl Köörna
// @version      1.0.0
// @match        https://ototoy.jp/_/default/p/*
// @grant        GM.setClipboard
// ==/UserScript==

const ARTIST_SEP = '---';

addEventListener('keydown', (e) => {
	if (!e.ctrlKey || e.key !== 'c') return;
	if (getSelection().focusOffset !== 0) return;
	
	GM.setClipboard(Array.from(document.querySelectorAll('.tracklist tr:not(:first-child)')).map((el) => {
		const elPlay = el.querySelector('button[trackcode]');
		return `${elPlay.getAttribute('tn').toString().padStart(2, '0')}. ${elPlay.getAttribute('artist')} ${ARTIST_SEP} ${elPlay.getAttribute('title')} (${el.children[2].innerText})`
	}).join('\n'));
});
