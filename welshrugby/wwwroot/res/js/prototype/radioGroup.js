var RadioGroup = Class.create();
Object.extend(RadioGroup.prototype, {
  initialize: function(radioButtons, onChange) {
    if(radioButtons instanceof Array) {
      this.radioButtons = radioButtons.collect(function(rb) {
        return $(rb);
      });
    } else {
      this.radioButtons = $$(radioButtons);
    }
    this.radioButtons.each(function(rb) {
      rb.observe("click",this._click.bindAsEventListener(this));
    }.bind(this));
    this.selected = this.findSelected();
    this.onChange = onChange;
  },
  _click: function(event) {
    var element = Event.element(event);
    if(element.checked) {
      if(element != this.selected) {
        this.onChange(element, this.selected);
        this.selected = element;
      }
    } else {
      var currentSelected = this.findSelected();
      if(currentSelected) {
        this.onChange(currentSelected, this.selected);
        this.selected = currentSelected;
      }
    }
  },
  findSelected: function() {
    return this.radioButtons.find(function(rb) {
      return rb.checked;
    }.bind(this));
  }
});

/*
//USAGE
new RadioGroup("#someForm input[type=radio]",
function(newlyClicked, previouslyClicked) {
//fire bug logging
console.log(newlyClicked);
console.log(previouslyClicked);
});

//OR
new RadioGroup($(someForm).getElementsBySelector("input[type=radio]"),
function(newlyClicked, previouslyClicked) {
//fire bug logging
console.log(newlyClicked);
console.log(previouslyClicked);
});
*/