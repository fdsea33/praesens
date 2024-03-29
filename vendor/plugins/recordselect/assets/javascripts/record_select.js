Event.observe(window, 'load', function() {RecordSelect.document_loaded = true});

var RecordSelect = new Object();
RecordSelect.document_loaded = false;

RecordSelect.notify = function(item) {
  var e = Element.up(item, '.record-select-handler');
  var onselect = e.onselect || e.getAttribute('onselect');
  if (typeof onselect != 'function') onselect = eval(onselect);
  if (onselect)
  {
    try {
      onselect(item.parentNode.id.substr(2), item.innerHTML, e);
    } catch(e) {
      alert(e);
    }
    return false;
  }
  else return true;
}

RecordSelect.Abstract = Class.create();
Object.extend(RecordSelect.Abstract.prototype, {
  /**
   * obj - the id or element that will anchor the recordselect to the page
   * url - the url to run the recordselect
   * options - ??? (check concrete classes)
   */
  initialize: function(obj, url, options) {
    this.obj = $(obj);
    this.url = url;
    this.options = options;
    this.container;

    if (RecordSelect.document_loaded) this.onload();
    else Event.observe(window, 'load', this.onload.bind(this));
  },

  /**
   * Finish the setup - IE doesn't like doing certain things before the page loads
   * --override--
   */
  onload: function() {},

  /**
   * the onselect event handler - when someone clicks on a record
   * --override--
   */
  onselect: function(id, value) {
    alert(id + ': ' + value);
  },

  /**
   * opens the recordselect
   */
  open: function() {
    if (this.is_open()) return;

    new Ajax.Updater(this.container, this.url, {
      evalScripts: true,
      asynchronous: true,
      insertion: Insertion.Bottom,
      onSuccess: function() {
        this.show();
        Element.observe(document.body, 'click', this.onbodyclick.bindAsEventListener(this));
      }.bind(this)
    });
  },

  /**
   * positions and reveals the recordselect
   */
  show: function() {
    var offset = Position.cumulativeOffset(this.obj);
    this.container.style.left = offset[0] + 'px';
    this.container.style.top = (Element.getHeight(this.obj) + offset[1]) + 'px';

    this.container.show();
  },

  /**
   * closes the recordselect by emptying the container
   */
  close: function() {
    this.container.hide();
    // hopefully by using remove() instead of innerHTML we won't leak memory
    this.container.immediateDescendants().invoke('remove');
  },

  /**
   * returns true/false for whether the recordselect is open
   */
  is_open: function() {
    return (this.container.childNodes.length > 0)
  },

  /**
   * when the user clicks outside the dropdown
   */
  onbodyclick: function(ev) {
    if (!this.is_open()) return;
    var elem = $(Event.element(ev));
    var ancestors = elem.ancestors();
    ancestors.push(elem);
    if (ancestors.include(this.container) || ancestors.include(this.obj)) return;
    this.close();
  },

  /**
   * creates and initializes (and returns) the recordselect container
   */
  create_container: function() {
    new Insertion.Bottom(document.body, '<div class="record-select-container record-select-handler"></div>');
    e = document.body.childNodes[document.body.childNodes.length - 1];
    e.onselect = this.onselect.bind(this);
    e.style.display = 'none';

    return $(e);
  }
});

/**
 * Adds keyboard navigation to RecordSelect objects
 */
Object.extend(RecordSelect.Abstract.prototype, {
  current: null,

  /**
   * keyboard navigation - where to intercept the keys is up to the concrete class
   */
  onkeypress: function(ev) {
    var elem;
    switch (ev.keyCode) {
      case Event.KEY_UP:
        if (this.current && this.current.up('.record-select')) elem = this.current.previous();
        if (!elem) elem = this.container.getElementsBySelector('ol li.record').last();
        this.highlight(elem);
        break;
      case Event.KEY_DOWN:
        if (this.current && this.current.up('.record-select')) elem = this.current.next();
        if (!elem) elem = this.container.getElementsBySelector('ol li.record').first();
        this.highlight(elem);
        break;
      case Event.KEY_SPACE:
      case Event.KEY_RETURN:
        if (this.current) this.current.down('a').onclick();
        break;
      case Event.KEY_RIGHT:
        elem = this.container.down('li.pagination.next');
        if (elem) elem.down('a').onclick();
        break;
      case Event.KEY_LEFT:
        elem = this.container.down('li.pagination.previous');
        if (elem) elem.down('a').onclick();
        break;
      case Event.KEY_ESC:
        this.close();
        break;
    }
  },

  /**
   * In order for the keyboard navigation to completely work when RecordSelect is
   * inside a form, we need to stop 'enter' from submitting the form when the focus
   * is on the RecordSelect dialog.
   *
   * This method should observe the form's submit event.
   */
  disable_enter_form_submits: function(ev) {
    if (this.is_open() && this.obj == Event.element(ev)) {
      Event.stop(ev);
    }
  },

  /**
   * moves the highlight to a new object
   */
  highlight: function(obj) {
    if (this.current) this.current.removeClassName('current');
    this.current = $(obj);
    obj.addClassName('current');
  }
});

/**
 * Used by link_to_record_select
 * The options hash should contain a onselect: key, with a javascript function as value
 */
RecordSelect.Dialog = Class.create();
RecordSelect.Dialog.prototype = Object.extend(new RecordSelect.Abstract(), {
  onload: function() {
    this.container = this.create_container();
    this.obj.observe('click', this.toggle.bind(this));

    if (this.onkeypress) this.obj.observe('keyup', this.onkeypress.bind(this));
  },

  onselect: function(id, value) {
    if (this.options.onselect(id, value) != false) this.close();
  },

  toggle: function() {
    if (this.is_open()) this.close();
    else this.open();
  }
});

/**
 * Used by record_select_field helper
 * The options hash may contain id: and label: keys, designating the current value
 */
RecordSelect.Single = Class.create();
RecordSelect.Single.prototype = Object.extend(new RecordSelect.Abstract(), {
  onload: function() {
    // create the hidden input
    new Insertion.After(this.obj, '<input type="hidden" name="" value="" />')
    this.hidden_input = this.obj.next();

    // transfer the input name from the text input to the hidden input
    this.hidden_input.name = this.obj.name;
    this.obj.name = '';

    // initialize the values
    this.set(this.options.id, this.options.label);

    // initialize the container
    this.container = this.create_container();
    this.container.addClassName('record-select-autocomplete');

    // attach the events to start this party
    this.obj.observe('focus', this.open.bind(this));

    // the autosearch event
    this.obj.observe('keyup', function() {
      if (!this.is_open()) return;
      this.container.down('.text-input').value = this.obj.value;
    }.bind(this));

    // keyboard navigation, if available
    if (this.onkeypress) {
      this.obj.observe('keyup', this.onkeypress.bind(this));
      this.obj.up('form').observe('submit', this.disable_enter_form_submits.bind(this));
    }
  },

  close: function() {
    // if they close the dialog with the text field empty, then delete the id value
    if (this.obj.value == '') this.set('', '');

    RecordSelect.Abstract.prototype.close.call(this);
  },

  onselect: function(id, value) {
    this.set(id, value);
    this.close();
  },

  /**
   * sets the id/label
   */
  set: function(id, label) {
    this.obj.value = label;
    this.hidden_input.value = id;
  }
});

/**
 * Used by record_multi_select_field helper.
 * Options:
 *   list - the id (or object) of the <ul> to contain the <li>s of selected entries
 *   current - an array of id:/label: keys designating the currently selected entries
 */
RecordSelect.Multiple = Class.create();
RecordSelect.Multiple.prototype = Object.extend(new RecordSelect.Abstract(), {
  onload: function() {
    // initialize the container
    this.container = this.create_container();
    this.container.addClassName('record-select-autocomplete');

    // decide where the <li> entries should be placed
    if (this.options.list) this.list_container = $(this.options.list);
    else this.list_container = this.obj.next('ul');

    // take the input name from the text input, and store it for this.add()
    this.input_name = this.obj.name;
    this.obj.name = '';

    // initialize the list
    $A(this.options.current).each(function(c) {
      this.add(c.id, c.label);
    }.bind(this));

    // attach the events to start this party
    this.obj.observe('focus', this.open.bind(this));

    // the autosearch event
    this.obj.observe('keyup', function() {
      if (!this.is_open()) return;
      this.container.down('.text-input').value = this.obj.value;
    }.bind(this));

    // keyboard navigation, if available
    if (this.onkeypress) {
      this.obj.observe('keyup', this.onkeypress.bind(this));
      this.obj.up('form').observe('submit', this.disable_enter_form_submits.bind(this));
    }
  },

  onselect: function(id, value) {
    this.add(id, value);
    this.close();
  },

  /**
   * Adds a record to the selected list
   */
  add: function(id, label) {
    // return silently if this value has already been selected
    var already_selected = this.list_container.getElementsBySelector('input').any(function(i) {
      return i.value == id
    });
    if (already_selected) return;

    var entry = '<li>'
              + '<a href="#" onclick="$(this.parentNode).remove();" class="remove">remove</a>'
              + '<input type="hidden" name="' + this.input_name + '" value="' + id + '" />'
              + '<label>' + label + '</label>'
              + '</li>';
    new Insertion.Top(this.list_container, entry);
  }
});