React = require('react')
ReactSelector = require('./.coffee.ReactSelector')

DummyComponent = React.createClass
    statics: {
        getText: (id) ->
            switch id
                when 1
                    text = "first"
                when 2
                    text = "second"
                when 3
                    text = "third"
                when 4
                    text = "forth"
                when 5
                    text = "fifth"
    }

    render: ->
        React.DOM.p {}, DummyComponent.getText(@props.id)


App = React.createClass
    getInitialState: ->
        return {
            universe: [1,2,3,4,5]
            selected: []
        }

    _toggle: (id) ->
        universe = @state.universe.slice(0)
        selected = @state.selected.slice(0)
        index = universe.indexOf(id)
        if index != -1
            universe.splice(index, 1)
            selected.push(id)
            @setState {universe: universe, selected: selected}
            return

        index = selected.indexOf(id)
        if index != -1
            selected.splice(index, 1)
            universe.push(id)
            @setState {universe: universe, selected: selected}

        return

    _compare: (a, b) ->
        return a.ref > b.ref

    render: ->
        React.DOM.div {},
            React.createElement(ReactSelector, {
                universe: @state.universe
                selected: @state.selected
                toggle: @_toggle
                compare: @_compare
                component: DummyComponent
            })

React.render(React.createElement(App, {}), document.getElementById("container"))
