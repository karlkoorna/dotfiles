// ==UserScript==
// @name         Tab - Toggle Media Shortcut
// @description  Toggle all media elements with CTRL+M.
// @author       Karl Köörna
// @version      1.0
// @namespace    kkttms
// @match        *://*/*
// @grant        none
// ==/UserScript==

document.body.addEventListener('keydown', (e) => {
	if (e.ctrlKey && e.key === 'm') for (const el of document.querySelectorAll('video, audio')) if (el.paused) el.play(); else el.pause();
});
