// ==UserScript==
// @name         AniBud
// @description  Display budget on AnimeBytes.
// @author       Karl Köörna
// @version      1.0.0
// @match        https://animebytes.tv/user.php*
// ==/UserScript==

function format(bytes) {
	const exp = Math.floor(Math.log(Math.abs(bytes)) / Math.log(1024));
	return (bytes / Math.pow(1024, exp)).toFixed(2) + ' ' + [ 'B', 'KiB', 'MiB', 'GiB', 'TiB' ][exp];
}

const up = document.querySelector('.userstatsright dd:nth-of-type(1) > span').title;
const down = document.querySelector('.userstatsright dd:nth-of-type(2) > span').title;

document.querySelector('.userstatsright dd:nth-of-type(3)').insertAdjacentHTML('afterend', [ 3, 2, 1, 10 ].map((ratio) => {
	const budget = Math.floor(up / ratio - down);
	return budget <= 0 ? '' : `<dt style="padding: 2px 0; padding-left: 15px; font-weight: normal;">Budget until ${ratio}</dt><dd style="padding: 2px 0;"><span title="${budget}">${format(budget)}</span></dd>`;
}).join(''));
