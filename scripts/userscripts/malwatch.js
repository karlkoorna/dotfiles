// ==UserScript==
// @name         MALWatch
// @description  Watch anime from MAL.
// @author       Karl Köörna
// @version      1.0.0
// @include      /myanimelist\.net\/animelist\/[^?]+(\?status=1)?$/
// @grant        GM.xmlHttpRequest
// @grant        GM.addStyle
// ==/UserScript==

async function req(url, opts = {}) {
	return new Promise((resolve, reject) => {
		GM.xmlHttpRequest({
			url,
      		method: 'GET',
			timeout: 3000,
			...opts,
			onerror: reject,
			ontimeout: reject,
			onload(res) {
				resolve(res.responseText);
			}
		});
	});
}

const sources = [
	{
		name: 'Nyaa',
		delay: 100,
		async search(title, episode) {
			const torrents = Array.from(new DOMParser().parseFromString(await req(`https://nyaa.si/?page=rss&c=1_2&s=seeders&o=desc&q=${title.replace(/[^\w]/, ' ')} ${episode}`), 'text/xml').getElementsByTagName('item')).map((el) => Object.fromEntries([ ...el.children ].map((el) => [ el.nodeName.replace('nyaa:', ''), isNaN(el.textContent) ? el.textContent : Number(el.textContent) ]))).filter((torrent) => torrent.seeders > 0 && new RegExp(`(E|- )0?${episode}(?![0-9]| ?~| ?-)`).test(torrent.title));
			if (torrents.length) return `magnet:?xt=urn:btih:${torrents[0].infoHash}&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce`;
		}
	},
	{
		name: 'Twist',
		delay: 100,
		async search(title, episode) {
			const reqOpts = { headers: { 'X-Access-Token': '0df14814b9e590a1f26d3071a4ed7974' } };
			window.twist = window.twist || JSON.parse(await req('https://twist.moe/api/anime', reqOpts));
			const show = twist.find((show) => show.title.toLowerCase().includes(title.toLowerCase().replace(/(st|nd|rd|th) season/, '')));
			if (show && (!show.ongoing || JSON.parse(await req(`https://twist.moe/api/anime/${show.slug.slug}/sources`, reqOpts)).length >= episode)) return `https://twist.moe/a/${show.slug.slug}/${episode}`;
	}
	},
	{
		name: 'Pahe',
		async search(title, episode) {
			const show = JSON.parse(await req(`https://animepahe.com/api?m=search&q=${title}`))?.data?.[0];
			if (!show) return;
			const episodes = JSON.parse(await req(`https://animepahe.com/api?m=release&id=${show.id}&sort=episode_desc`)).data;
			if (episode > episodes.length) return;
			return `https://animepahe.com/play/${show.session}/${episodes[episodes.length - episode].session}`;
		}
	},
	{
		name: '9Anime',
		delay: 100,
		async search(title, episode) {
			const shows = new DOMParser().parseFromString(await req(`https://9anime.to/search?keyword=${title}`), 'text/html');
			const show = shows.querySelector('.anime-list .poster');
			
			if (!show) return;
			if (episode > Number(show.querySelector('.tag.ep').innerText.split('/')[0].replace('Ep', ' ').replace('Full', '1'))) return;
			return `https://9anime.to${show.getAttribute('href')}/ep-${episode}`;
		}
	},
	{
		name: 'Kisa',
		async search(title, episode) {
			const shows = new DOMParser().parseFromString(await req(`https://animekisa.tv/search?q=${title}`), 'text/html');
			shows.evaluate('//*[text()="Dubbed" and @class="lisbg"]', shows, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue?.nextElementSibling?.remove();
			const slug = shows.querySelector('.similarbox a.an:not(.hidemobile)')?.getAttribute('href');
			if (!slug) return;
			if (!(await req(`https://animekisa.tv${slug}`)).includes(`-episode-${episode}"`)) return;
			return `https://animekisa.tv${slug}-episode-${episode}`;
		}
	}
];

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
								idMal
								nextAiringEpisode {
									episode
									timeUntilAiring
								}
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

function getLinks(shows, schedule) {
	const scheduledShows = shows.filter((show) => {
		if (show.episode + 1 < (schedule[show.id]?.episode || 999_999)) return true;
		show.el.innerHTML = `Ep. ${schedule[show.id].episode} in ${schedule[show.id].time}`;
	});
	
	for (const source of sources) (async () => {
		for (const show of scheduledShows) {
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
		}
	})();
}

const dispose = setInterval(async () => {
	if (!document.querySelector('.list-table > .list-item')) return;
	clearInterval(dispose);
	
	const shows = Array.from(document.querySelectorAll('.list-item')).map((refEl, i) => {
		const el = document.createElement('div');
		el.classList.add('malwatch-links');
		el.innerText = '…';
		refEl.querySelector('.content-status').insertAdjacentElement('afterend', el);
		
		return {
			el,
			refEl,
			id: refEl.querySelector('.title a').href.split('/')[4],
			title: refEl.querySelector('.title a').innerText,
			episode: Number(refEl.querySelector('.progress a').innerText) || 0,
			found: false,
			links: {}
		};
	});
	
	const schedule = await getSchedule(shows);
	
	for (const show of shows) {
		new MutationObserver((mutations) => {
			if (mutations.length !== 1) return;
			
			show.found = false;
			show.links = {};
			show.episode = Number(show.refEl.querySelector('.progress a').innerText) || 0;
			
			getLinks([ show ], schedule);
		}).observe(show.refEl.querySelector('.progress span'), { subtree: true, childList: true, characterData: true });
	}
	
	getLinks(shows, schedule);
}, 100);

GM.addStyle(`
.malwatch-links { color: #bcb7ae; font-size: 10px; }
.malwatch-links > a { color: #fa5858; }
.icon-watch { display: none; }
`);
