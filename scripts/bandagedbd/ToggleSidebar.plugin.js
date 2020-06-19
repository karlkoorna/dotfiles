//META{"name":"ToggleSidebar"}*//

let isVisible = BdApi.getData('ToggleSidebar', 'visible');

function toggle(e) {
	if (!e.ctrlKey || e.key !== 's') return;
	
	const el = document.querySelector('[class^="membersWrap"]');
	[ isVisible, el.style.width ] = el.clientWidth ? [ false, 0 ] : [ true, '240px' ];
	BdApi.saveData('ToggleSidebar', 'visible', el.clientWidth !== 0);
}

class ToggleSidebar {
	
	getName = () => 'Toggle Sidebar';
	getShortName = () => 'ToggleSidebar';
	getDescription = () => 'Toggle members sidebar with CTRL+S.';
	getAuthor = () => 'Karl Köörna';
	getVersion = () => '1.0.0';
	
	getSettingsPanel = () => '';
	
	start() {
		addEventListener('keydown', toggle);
		BdApi.injectCSS('ToggleSidebar', `
			[class^="membersWrap"] {
				width: 240px;
				min-width: 0;
				overflow: hidden;
			}
			[class^="membersWrap"]:not(.is-hidden) {
				transition: width .15s ease-in-out;
			}
		`);
	}
	
	stop() {
		removeEventListener('keydown', toggle);
		BdApi.clearCSS('ToggleSidebar');
	}
	
	observer(e) {
		if (isVisible || !e.addedNodes.length || !e.addedNodes[0].className || e.addedNodes[0].className.slice(0, 12) !== 'membersGroup') return;
		
		const el = document.querySelector('[class^="membersWrap"]');
		el.classList.add('is-hidden');
		el.style.width = 0;
		setTimeout(() => {
			el.classList.remove('is-hidden');
		}, 0);
	}
	
}
