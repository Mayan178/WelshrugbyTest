Event.observe(window, 'load', function() {
	var objs = document.getElementsByTagName("textarea");
	var oi = 0; //oi is object index
	var thisObj;
	
	for (oi=0;oi<objs.length;oi++) {
		elementName = objs[oi].readAttribute('name'); 
		thisElement = $(elementName);

		Event.observe($(thisElement), "keyup", function() {
			try {
				maxlength = this.readAttribute("maxlength");
				if (maxlength>0 && this.value.length>maxlength)
					this.value=this.value.substring(0,maxlength);
			} catch(e) {
			}
		})
	}
});