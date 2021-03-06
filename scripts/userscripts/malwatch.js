// ==UserScript==
// @name         MALWatch
// @description  Watch anime from MAL.
// @author       Karl Köörna
// @version      1.0.0
// @include      /myanimelist\.net\/animelist\/[^?]+(\?status=1)?$/
// @connect      graphql.anilist.co
// @connect      nyaa.si
// @connect      animepahe.com
// @connect      www12.9anime.to
// @connect      animekisa.tv
// @grant        GM.xmlHttpRequest
// @grant        GM.addStyle
// ==/UserScript==

async function get(url, timeout = 5000) {
	return new Promise((resolve, reject) => {
		GM.xmlHttpRequest({
			url,
      		method: 'GET',
			timeout,
			onerror: reject,
			ontimeout: reject,
			onload(res) {
				resolve(res.responseText);
			}
		});
	});
}

async function getSchedule(shows) {
	return new Promise((resolve) => {
		GM.xmlHttpRequest({
			url: 'https://graphql.anilist.co',
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			data: JSON.stringify({
				query: `
					query ($ids: [Int]) {
						Page {
							media(idMal_in: $ids) {
								idMal nextAiringEpisode { episode timeUntilAiring }
							}
						}
					}
				`,
				variables: {
					ids: shows.map((show) => show.id)
				}
			}),
			onload(res) {
				const schedule = {};
				
				for (const show of JSON.parse(res.responseText).data.Page.media) {
					if (!show.nextAiringEpisode) continue;
					
					const d = Math.floor(show.nextAiringEpisode.timeUntilAiring / 86400);
					const h = Math.floor(show.nextAiringEpisode.timeUntilAiring / 3600) % 24;
					schedule[show.idMal] = {
						episode: show.nextAiringEpisode.episode,
						time: (d ? d + ' day' + (d > 1 ? 's ' : ' ') : '') + (h ? h + ' hour' + (h > 1 ? 's' : '') : '').trim()
					};
				}
				
				resolve(schedule);
			}
		});
	});
}

const sources = [
	{
		name: 'Nyaa',
		delay: 200,
		async search(title, episode) {
			const torrents = [ ...new DOMParser().parseFromString(await get(`https://nyaa.si/?page=rss&c=1_2&s=seeders&o=desc&q=${title.replace(/[^\w]/, ' ')} ${episode}`), 'text/xml').getElementsByTagName('item') ].map((el) => Object.fromEntries([ ...el.children ].map((el) => [ el.nodeName.replace('nyaa:', ''), isNaN(el.textContent) ? el.textContent : Number(el.textContent) ]))).filter((torrent) => torrent.seeders > 0 && new RegExp(`(E|- )0?${episode}(?![0-9]| ?~| ?-)`).test(torrent.title));
			if (torrents.length) return `magnet:?xt=urn:btih:${torrents[0].infoHash}&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce`;
		}
	},
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
		name: '9Anime',
		async search(title, episode) {
			const shows = new DOMParser().parseFromString(JSON.parse(await get(`https://www12.9anime.to/ajax/anime/search?keyword=${title}`)).html, 'text/html');
			const slug = [ ...shows.querySelectorAll('a:not(.more)') ].reverse().map((el, rank) => ({ rank, slug: el.getAttribute('href') })).sort((prev, next) => next.rank - prev.rank + Number(next.slug.includes('bluray')))?.[0]?.slug;
			if (!slug) return;
			return `https://www12.9anime.to${slug}/ep-${episode}`;
		}
	},
	{
		name: 'Kisa',
		async search(title, episode) {
			const shows = new DOMParser().parseFromString(await get(`https://animekisa.tv/search?q=${title}`), 'text/html');
			shows.evaluate('//*[text()="Dubbed" and @class="lisbg"]', shows, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue?.nextElementSibling?.remove();
			const slug = shows.querySelector('.similarbox a.an:not(.hidemobile)')?.getAttribute('href');
			if (!slug) return;
			if (!(await get(`https://animekisa.tv${slug}`)).includes(`-episode-${episode}"`)) return;
			return `https://animekisa.tv${slug}-episode-${episode}`;
		}
	}
];

const dispose = setInterval(async () => {
	if (!document.querySelector('.list-table > .list-item')) return;
	clearInterval(dispose);
	
	let shows = [ ...document.querySelectorAll('.list-item') ].map((refEl, i) => {
		const el = document.createElement('div');
		el.classList.add('malwatch-links');
		el.innerText = '…';
		refEl.querySelector('.content-status').insertAdjacentElement('afterend', el);
		
		return {
			el,
			id: refEl.querySelector('.title a').href.split('/')[4],
			title: refEl.querySelector('.title a').innerText,
			episode: Number(refEl.querySelector('.progress a').innerText) || 0,
			found: false,
			links: {}
		};
	});
	
	const schedule = await getSchedule(shows);
	
	shows = shows.filter((show, i) => {
		if (show.episode + 1 !== schedule[show.id]?.episode) return true;
		show.el.innerHTML = schedule[show.id].time;
	});
	
	for (const source of sources) (async () => {
		shows.forEach(async (show, i) => {
			let link = null;
			try {
				link = await source.search(show.title, show.episode + 1) || null;
			} catch (err) {
				console.error(source.name, err);
			}
			
			if (show.links[source.name] = link) {
				show.found = true;
				show.el.innerHTML = sources.filter((source) => show.links[source.name]).map((source) => `<a class="malwatch-link" href="${show.links[source.name]}" target="_blank" rel="nofollower noreferrer">${source.name}</a>`).join(', ');
			}
			
			if (source.delay) await new Promise((resolve) => setTimeout(resolve, source.delay));
		});
	})();
}, 100);

GM.addStyle(`
.malwatch-links { color: #bcb7ae; font-size: 10px; }
.malwatch-links > a { color: #fa5858; }
.icon-watch { display: none; }
`);
