//META{"name":"MemberList"}*//

function toggle(e) {
	if (e.ctrlKey && e.key === 's') document.querySelector('[aria-label="Member List"]').click();
}

class ToggleSidebar {
	
	getName = () => 'Member List';
	getShortName = () => 'MemberList';
	getDescription = () => 'Toggle Member List with CTRL+S.';
	getAuthor = () => 'Karl Köörna';
	getVersion = () => '1.0.0';
	
	getSettingsPanel = () => '';
	
	start() {
		addEventListener('keydown', toggle);
	}
	
	stop() {
		removeEventListener('keydown', toggle);
	}
	
}
