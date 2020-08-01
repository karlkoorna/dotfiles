// ==UserScript==
// @name         MALWatch
// @description  Watch anime from MAL.
// @author       Karl Köörna
// @version      1.0.0
// @include      /myanimelist\.net\/animelist\/[^?]+(\?status=1)?$/
// @grant        GM.xmlHttpRequest
// @grant        GM.addStyle
// @connect      anipahe.com
// @connect      twist.moe
// @connect      nyaa.si
// ==/UserScript==

async function get(url) {
	return new Promise((resolve, onerror) => GM.xmlHttpRequest({
		url,
		headers: { 'x-access-token': '1rj2vRtegS8Y60B3w3qNZm5T2Q0TN2NR' }, // For Twist
		onerror,
		onload(res) {
			resolve(res.responseText);
		}
	}));
}

async function getSchedule(shows) {
	return new Promise((resolve, reject) => GM.xmlHttpRequest({
		url: 'https://graphql.anilist.co',
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		data: JSON.stringify({
			query: `
				query ($ids: [Int]) {
					Page {
						media(idMal_in: $ids) {
							idMal nextAiringEpisode { timeUntilAiring }
						}
					}
				}
			`,
			variables: { ids: shows.map((show) => show.id) }
		}),
		onload(res) {
			resolve(Object.fromEntries(JSON.parse(res.responseText).data.Page.media.filter((show) => show.nextAiringEpisode).map((show) => {
				const s = show.nextAiringEpisode.timeUntilAiring, d = Math.floor(s / 86400), h = Math.floor(s / 3600) % 24;
				return [ show.idMal, (d ? d + ' day' + (d > 1 ? 's' : '') : '') + (h ? ' ' + h + ' hour' + (h > 1 ? 's' : ''): '') ];
			})));
		}
	}));
}

const db = {};
const sources = [
	{
		name: 'Pahe',
		async search(title, episode) {
			const shows = JSON.parse(await get(`https://animepahe.com/api?m=search&q=${title}`));
			if (!shows.total) return;
			
			const episodes = JSON.parse(await get(`https://animepahe.com/api?m=release&id=${shows.data[0].id}&sort=episode_desc`)).data;
			if (episodes.length >= episode) return `https://animepahe.com/play/${shows.data[0].session}/${episodes[episodes.length - episode].session}`;
		}
	},
	{
		name: 'Twist',
		async search(title, episode) {
			if (!db.twist) db.twist = JSON.parse(await get('https://twist.moe/api/anime'));
			
			const show = db.twist.find((show) => show.title.toLowerCase().includes(title.toLowerCase().replace(/(st|nd|rd|th) season/, '')));
			if (show && (!show.ongoing || JSON.parse(await get(`https://twist.moe/api/anime/${show.slug.slug}/sources`)).length >= episode)) return `https://twist.moe/a/${show.slug.slug}/${episode}`;
		}
	},
	{
		name: 'Nyaa',
		delay: 200,
		async search(title, episode) {
			const torrents = [ ...new DOMParser().parseFromString(await get(`https://nyaa.si/?page=rss&c=1_2&s=seeders&o=desc&q=${title.replace(/[^a-zA-Z0-9]/, ' ')} ${episode} 1080`), 'text/xml').getElementsByTagName('item') ].map((el) => Object.fromEntries(Array.from(el.children).map((el) => [ el.nodeName.replace('nyaa:', ''), isNaN(el.textContent) ? el.textContent : Number(el.textContent) ]))).filter((torrent) => torrent.seeders >= 3 && torrent.title.replace(/\[.*?\]/g, '').includes(episode) && !torrent.title.replace(/\[.*?\]/g, '').includes((episode - 1).toString().padStart(2, '0')));
			if (torrents.length) return `magnet:?xt=urn:btih:${torrents[0].infoHash}&dn=%5BMoe-Raws%5D%20THE%20GOD%20OF%20HIGH%20SCHOOL%20%2303%20%28AT-X%201280x720%20x264%20AAC%29.mp4&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce`;
		}
	}
];

setTimeout(() => {
	const shows = [ ...document.querySelectorAll('.list-item') ].map((el, index) => el.querySelector('.content-status').insertAdjacentHTML('afterend', '<span class="malwatch-links">') || {
		id: el.querySelector('.title a').href.split('/')[4],
		title: el.querySelector('.title a').innerText,
		episode: Number(el.querySelector('.progress a').innerText) || 0,
		found: false,
		links: {},
		index
	});
	
	let schedule = {};
	getSchedule(shows).then((_schedule) => { schedule = _schedule });
	for (const source of sources) (async () => {
		for (const show of shows) {
			let link = null;
			try { link = await source.search(show.title, show.episode + 1) || null; } catch (ex) { console.error(ex); }
			const el = document.querySelector(`.list-item:nth-of-type(${show.index + 2}) .malwatch-links`);
			
			show.links[source.name] = link;
			if (Object.keys(show.links).length === sources.length) {
				if (!show.found && schedule[show.id]) el.innerHTML = `<span class="malwatch-time">${schedule[show.id]}</span>`;
				el.classList.add('is-done');
			}
			
			if (!link) continue;
			show.found = true;
			
			el.innerHTML = sources.filter((source) => show.links[source.name]).map((source) => `<a class="malwatch-link" href="${show.links[source.name]}" target="_blank" rel="nofollower noreferrer">${source.name}</a>`).join(', ');
			if (source.delay) await new Promise((resolve) => setTimeout(resolve, source.delay));
		}
	})();
}, 100);

GM.addStyle(`
.malwatch-links { color: #fa58fa; font-size: 10px; }
.malwatch-links.is-done + div { font-weight: bold; }
.malwatch-links > a { color: #fa5858; }
.icon-watch { display: none; }
`);