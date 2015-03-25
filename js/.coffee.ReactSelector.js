var ESCAPE, MOVE_DOWN, MOVE_UP, REMOVE_ITEM, React, ReactSelector, SELECT_ITEM, SELECT_ITEM_2;

React = require('react');

MOVE_UP = 38;

MOVE_DOWN = 40;

SELECT_ITEM = 13;

SELECT_ITEM_2 = 9;

REMOVE_ITEM = 8;

ESCAPE = 27;

ReactSelector = React.createClass({
  getInitialState: function() {
    var query;
    query = "";
    return {
      query: query,
      active_item: 0,
      filtered: this._calculateFiltered(this.props.universe, query)
    };
  },
  componentWillReceiveProps: function(nextProps) {
    var active_item, filtered, query;
    query = "";
    active_item = 0;
    filtered = this._calculateFiltered(nextProps.universe, query);
    return this.setState({
      active_item: active_item,
      query: query,
      filtered: filtered
    });
  },
  _calculateFiltered: function(universe, query) {
    var component, component_text, filtered, i, item, j, len;
    if (query == null) {
      query = "";
    }
    filtered = [];
    for (i = j = 0, len = universe.length; j < len; i = ++j) {
      item = universe[i];
      component = React.createElement(this.props.component, {
        id: item
      });
      component_text = this.props.component.getText(item);
      if (query === "" || component_text.indexOf(query) !== -1) {
        filtered.push(item);
      }
    }
    return filtered;
  },
  _getItems: function(list, filter_list, filter) {
    var component, component_text, i, item, item_class_name, items, j, len;
    if (filter_list == null) {
      filter_list = false;
    }
    if (filter == null) {
      filter = "";
    }
    items = [];
    for (i = j = 0, len = list.length; j < len; i = ++j) {
      item = list[i];
      item_class_name = "";
      if (filter_list && this.state.active_item === i) {
        item_class_name = "active";
      }
      component = React.createElement(this.props.component, {
        id: item
      });
      component_text = this.props.component.getText(item);
      items.push(React.DOM.li({
        ref: component_text,
        onClick: this._toggle_item.bind(null, item),
        className: item_class_name
      }, component));
    }
    items.sort(this.props.compare);
    return items;
  },
  _toggle_item: function(id) {
    var input;
    this.props.toggle(id);
    clearTimeout(this._timeout);
    input = this.refs.input.getDOMNode();
    return input.focus();
  },
  _processTyping: function(event) {
    var active_item, key;
    key = event.keyCode;
    active_item = this.state.active_item;
    if (key === MOVE_DOWN && active_item < this.state.filtered.length - 1) {
      return this.setState({
        active_item: active_item + 1
      });
    } else if (key === MOVE_UP && active_item > 0) {
      return this.setState({
        active_item: active_item - 1
      });
    } else if (key === SELECT_ITEM || key === SELECT_ITEM_2) {
      this.props.toggle(this.state.filtered[active_item]);
      return event.preventDefault();
    } else if (key === REMOVE_ITEM && this.state.query === '') {
      return this.props.toggle(this.props.selected[this.props.selected.length - 1]);
    } else if (key === ESCAPE) {
      return this._hideFilteredItems();
    }
  },
  _processText: function(event) {
    var active_item, filtered, input, query;
    input = event.target;
    query = input.value.trim();
    filtered = this._calculateFiltered(this.props.universe, query);
    active_item = this.state.active_item;
    if (active_item >= filtered.length && active_item !== 0 && filtered.length > 0) {
      active_item = filtered.length - 1;
    }
    return this.setState({
      query: query,
      filtered: filtered,
      active_item: active_item
    });
  },
  _showFilteredItems: function() {
    if (this.refs.universe.getDOMNode().className.indexOf("show") === -1) {
      return this.refs.universe.getDOMNode().className += " show";
    }
  },
  _hideFilteredItems: function() {
    return this._timeout = setTimeout(((function(_this) {
      return function() {
        var className;
        className = _this.refs.universe.getDOMNode().className.replace(/show/gi, '');
        return _this.refs.universe.getDOMNode().className = className;
      };
    })(this)), 200);
  },
  render: function() {
    var filtered_items, selected_items;
    filtered_items = this._getItems(this.state.filtered, true, this.state.query);
    selected_items = this._getItems(this.props.selected);
    return React.DOM.div({}, React.DOM.div({
      ref: "universe",
      className: "universe"
    }, React.DOM.ul({}, filtered_items)), React.DOM.div({
      className: "selected"
    }, React.DOM.ul({}, selected_items), React.DOM.input({
      ref: "input",
      value: this.state.query,
      placeholder: "Filter...",
      onKeyDown: this._processTyping,
      onChange: this._processText,
      onFocus: this._showFilteredItems,
      onBlur: this._hideFilteredItems
    })));
  }
});

module.exports = ReactSelector;
