// a is action (swap|add|remove|check)
// o is for the object for which the action will be carried out
// c1 is the name of class 1
// c2 is the name of class 2 for 'remove' purposes
function cssChange(a,o,c1,c2) {
	switch (a) {
		case 'swap':
			o.className= !cssChange('check',o,c1)?o.className.replace(c2,c1): o.className.replace(c1,c2);
		break;
		case 'add':
			if(!cssChange('check',o,c1)) {
				o.className += o.className?' '+c1:c1;
			}
		break;
		case 'remove':
			var rep=o.className.match(' '+c1)?' '+c1:c1;
			o.className=o.className.replace(rep,'');
		break;
		case 'check':
			return new RegExp('\\b'+c1+'\\b').test(o.className)
		break;
	}
}
