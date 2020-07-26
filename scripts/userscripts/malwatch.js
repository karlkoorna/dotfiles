// ==UserScript==
// @name         MALWatch
// @description  Watch anime from MAL.
// @author       Karl Köörna
// @version      1.0.0
// @include      /myanimelist\.net\/animelist\/[^?]+(\?status=1)?$/
// @grant        GM.xmlHttpRequest
// @grant        GM_addStyle
// @connect      anipahe.com
// @connect      twist.moe
// @connect      nyaa.si
// ==/UserScript==

async function get(url) {
    return new Promise((resolve) => GM.xmlHttpRequest({
        url,
        headers: url.includes('twist.moe') ? { 'x-access-token': '1rj2vRtegS8Y60B3w3qNZm5T2Q0TN2NR' } : {},
        onload(res) {
            return resolve(res.responseText);
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
        delay: 300,
        async search(title, episode) {
            const torrents = [ ...new DOMParser().parseFromString(await get(`https://nyaa.si/?page=rss&c=1_2&s=seeders&o=desc&q=${title.replace(/[^a-zA-Z0-9]/, ' ')} ${episode} 1080`), 'text/xml').getElementsByTagName('item') ].map((el) => Object.fromEntries(Array.from(el.children).map((el) => [ el.nodeName.replace('nyaa:', ''), isNaN(el.textContent) ? el.textContent : Number(el.textContent) ]))).filter((torrent) => torrent.seeders >= 3 && torrent.title.replace(/\[.*?\]/g, '').includes(episode) && !torrent.title.replace(/\[.*?\]/g, '').includes((episode - 1).toString().padStart(2, '0')));
            if (torrents.length) return `magnet:?xt=urn:btih:${torrents[0].infoHash}&dn=%5BMoe-Raws%5D%20THE%20GOD%20OF%20HIGH%20SCHOOL%20%2303%20%28AT-X%201280x720%20x264%20AAC%29.mp4&tr=http%3A%2F%2Fnyaa.tracker.wf%3A7777%2Fannounce&tr=udp%3A%2F%2Fopen.stealth.si%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969%2Fannounce&tr=udp%3A%2F%2Fexodus.desync.com%3A6969%2Fannounce`;
        }
    }
];

setTimeout(() => {
    const shows = [ ...document.querySelectorAll('.list-item') ].map((el, index) => el.querySelector('.content-status').insertAdjacentHTML('afterend', '<span class="content-watch">') || {
        title: el.querySelector('.title a').innerText,
        episode: Number(el.querySelector('.progress a').innerText) || 0,
        links: {},
        index
    });

    for (const source of sources) (async () => {
        for (const show of shows) {
            const link = await source.search(show.title, show.episode + 1);
            const el = document.querySelector(`.list-item:nth-of-type(${show.index + 2}) .content-watch`);
            el.setAttribute('data-show', (Number(el.getAttribute('data-show')) || 0) + 1);
            if (!link) continue;

            show.links[source.name] = link;
            el.innerHTML = sources.filter((source) => show.links[source.name]).map((source) => `<a class="note" href="${show.links[source.name]}" target="_blank" rel="nofollower noreferrer">${source.name}</a>`).join(', ');
            if (source.delay) await new Promise((resolve) => setTimeout(resolve, source.delay));
        }
    })();
}, 100);

GM_addStyle(`
.content-watch[data-show="${sources.length}"] + div { font-weight: bold; }
.note { color: red; font-size: 10px; }
.icon-watch { display: none; }
`);
