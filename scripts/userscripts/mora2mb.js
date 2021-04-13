// ==UserScript==
// @name         MORA2MB
// @description  Copy tracklist for MusicBrainz from Mora release page.
// @author       Karl Köörna
// @version      1.0.0
// @match        https://mora.jp/package/*/*
// @grant        GM.setClipboard
// @grant        GM.addStyle
// ==/UserScript==

const ARTIST_SEP = '\t';

const button = document.createElement('a');
button.id = 'mora2mb';
button.innerText = 'Copy tracks for MusicBrainz';

button.addEventListener('click', () => {
	const str = Array.from(document.querySelectorAll('#package_list tbody tr'), (el) => {
		return `${el.querySelector('.package_td1').innerText.padStart(2, '0')}. ${el.querySelector('.package_td3').innerText}${ARTIST_SEP}${el.querySelector('.package_title2').innerText} (${el.querySelector('.package_td4').innerText.split('\n')[0]})`
	}).join('\n')
	
	GM.setClipboard(str);
});

document.querySelector('#package_list').prepend(button);

GM.addStyle(`
#package_list {
	padding-top: 16px;
}
#mora2mb {
	margin-left: 13px;
	color: #ec171e;
	font-size: 12px;
	font-weight: bold;
	cursor: pointer;
}
#mora2mb:hover {
	text-decoration: underline;
}
`);
