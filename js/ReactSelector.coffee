React = require('react')

# Expected props:
#   universe
#   selected
#   toggle
#   component
#   compare

MOVE_UP = 38
MOVE_DOWN = 40
SELECT_ITEM = 13
SELECT_ITEM_2 = 9
REMOVE_ITEM = 8
ESCAPE = 27

ReactSelector = React.createClass


    getInitialState: ->
        query = ""
        return {
            query: query
            active_item: 0
            filtered: @_calculateFiltered(@props.universe, query)
        }

    componentWillReceiveProps: (nextProps) ->
        # adjust active_item on new universe
        query = ""
        active_item = 0
        filtered = @_calculateFiltered(nextProps.universe, query)

        @setState {
            active_item: active_item
            query: query
            filtered: filtered
        }

    _calculateFiltered: (universe, query="") ->
        filtered = []

        for item, i in universe
            component = React.createElement(@props.component, {id: item})
            component_text = @props.component.getText(item)

            # are we filtering?
            if query == "" || component_text.indexOf(query) != -1
                filtered.push(item)

        return filtered


    _getItems: (list, filter_list=false, filter="") ->
        items = []

        for item, i in list
            # check if active
            item_class_name = ""
            if filter_list && @state.active_item  == i
                item_class_name = "active"

            component = React.createElement(@props.component, {id: item})
            component_text = @props.component.getText(item)

            items.push(
                React.DOM.li({
                        ref: component_text
                        onClick: @_toggle_item.bind(null, item)
                        className: item_class_name
                    },
                    component
                )
            )
        items.sort(@props.compare)
        return items

    _toggle_item: (id) ->
        @props.toggle(id)
        clearTimeout(@_timeout)
        input = @refs.input.getDOMNode()
        input.focus()

    _processTyping: (event) ->
        key = event.keyCode
        active_item = @state.active_item

        # MOVE AROUND FILTERED ITEMS
        if key == MOVE_DOWN && active_item < @state.filtered.length - 1
            @setState {active_item: active_item + 1}
        else if key == MOVE_UP && active_item > 0
            @setState {active_item: active_item - 1}

        # MOVE ITEM TO SELECTED
        else if key == SELECT_ITEM || key == SELECT_ITEM_2
            @props.toggle(@state.filtered[active_item])
            event.preventDefault()

        # MOVE ITEM TO UNIVERSE
        else if key == REMOVE_ITEM && @state.query == ''
            @props.toggle(@props.selected[@props.selected.length - 1])

        # HIDE FILTER
        else if key == ESCAPE
            @_hideFilteredItems()


    _processText: (event) ->
        input = event.target
        query = input.value.trim()

        filtered = @_calculateFiltered(@props.universe, query)
        active_item = @state.active_item

        if active_item >= filtered.length && active_item != 0 && filtered.length > 0
            active_item = filtered.length - 1

        @setState {
            query: query
            filtered: filtered
            active_item: active_item
        }

    _showFilteredItems: ->
        if @refs.universe.getDOMNode().className.indexOf("show") == -1
            @refs.universe.getDOMNode().className += " show"

    _hideFilteredItems: ->
        @_timeout = setTimeout ( =>
            className = @refs.universe.getDOMNode().className.replace(/show/gi, '')
            @refs.universe.getDOMNode().className = className
        ), 200


    render: ->
        filtered_items = @_getItems(@state.filtered, true, @state.query)
        selected_items = @_getItems(@props.selected)

        React.DOM.div {},
            React.DOM.div {ref: "universe", className: "universe"},
                React.DOM.ul {},
                    filtered_items

            React.DOM.div {className: "selected"},
                React.DOM.ul {},
                    selected_items
                React.DOM.input {
                    ref: "input"
                    value: @state.query
                    placeholder: "Filter..."
                    onKeyDown: @_processTyping
                    onChange: @_processText
                    onFocus: @_showFilteredItems
                    onBlur: @_hideFilteredItems
                }

module.exports = ReactSelector
