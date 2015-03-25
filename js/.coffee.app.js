var App, DummyComponent, React, ReactSelector;

React = require('react');

ReactSelector = require('./.coffee.ReactSelector');

DummyComponent = React.createClass({
  statics: {
    getText: function(id) {
      var text;
      switch (id) {
        case 1:
          return text = "first";
        case 2:
          return text = "second";
        case 3:
          return text = "third";
        case 4:
          return text = "forth";
        case 5:
          return text = "fifth";
      }
    }
  },
  render: function() {
    return React.DOM.p({}, DummyComponent.getText(this.props.id));
  }
});

App = React.createClass({
  getInitialState: function() {
    return {
      universe: [1, 2, 3, 4, 5],
      selected: []
    };
  },
  _toggle: function(id) {
    var index, selected, universe;
    universe = this.state.universe.slice(0);
    selected = this.state.selected.slice(0);
    index = universe.indexOf(id);
    if (index !== -1) {
      universe.splice(index, 1);
      selected.push(id);
      this.setState({
        universe: universe,
        selected: selected
      });
      return;
    }
    index = selected.indexOf(id);
    if (index !== -1) {
      selected.splice(index, 1);
      universe.push(id);
      this.setState({
        universe: universe,
        selected: selected
      });
    }
  },
  _compare: function(a, b) {
    return a.ref > b.ref;
  },
  render: function() {
    return React.DOM.div({}, React.createElement(ReactSelector, {
      universe: this.state.universe,
      selected: this.state.selected,
      toggle: this._toggle,
      compare: this._compare,
      component: DummyComponent
    }));
  }
});

React.render(React.createElement(App, {}), document.getElementById("container"));
