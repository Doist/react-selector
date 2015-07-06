##
#
#   ReactSelector moves items between lists (universe and selected)
#   and offers the possibility to filter the universe by quering it
#   through an input field.
#
# # Expects props:
#   - @filtered_items_on_top (optional)     true if the filtered items should appear on top of the filter input
#   - @universe:                            An array with all the items we can select from
#   - @selected:                            An array with the selected items.
#   - @compare:                             A compare function that is used to order items.
#
# # Anathomy of an item.
#   universe and selected array must be populated with `items` that respect
#   the following format:
#   item  {
#       id:            An unique identifier for the item
#       renderer:      A react class that react selector will use to render the item
#       props:         pros that will be passed to renderer
#       name:          The item name to be used for filtering purposes
#       onToggle:      A function that will be tiggered each time we activate
#                      (via click, enter, wtv.) the item.
#   }
#
##
React = require('react')

ARROW_UP = 38
ARROW_DOWN = 40
ENTER = 13
BACKSPACE = 8
ESCAPE = 27

ReactSelector = React.createClass
    #
    # @return {
    #   query:                the filter query
    #   active_item_index:    the active item on the filter list
    #   filtered:             the list of items to be displayed on the filter list
    # }
    #
    getInitialState: ->
        query = ""
        return {
            filtered_items_on_top: @props.filtered_items_on_top || false
            show_filtered_items: false
            query: query
            active_item_index: 0
            filtered: @_calculateFiltered(@props.universe, @props.selected, query)
            selected: [].concat(@props.selected).sort(@props.compare)
        }

    #
    # When receiving new props, will:
    #   - reset query and.
    #   - reset active item.
    #   - recalculate filtered items.
    #   - updated selected items state.
    #
    componentWillReceiveProps: (nextProps) ->
        query = ""
        active_item_index = 0
        selected = nextProps.selected
        filtered = @_calculateFiltered(nextProps.universe, selected, query)

        @setState {
            active_item_index: active_item_index
            query: query
            filtered: filtered
            selected: selected.sort(@props.compare)
        }


    #
    # Moves the active item on filter list into view
    #
    componentDidUpdate: ->
        if @refs.active
            @refs.active.getDOMNode().scrollIntoView(false)


    #
    # Given two arrays (universe and selected), produces
    # returns a new ordered (with @props.compare) array containing:
    #
    # filtered = universe [minus] selected [minus] items_excluded_by_query
    #
    _calculateFiltered: (universe, selected, query) ->
        filtered = []

        for item in universe
            if !@__arrayContainsObject(selected, item)
                if item.name.toLowerCase().trim().indexOf(query.toLowerCase().trim()) != -1
                    filtered.push(item)

        filtered.sort(@props.compare)
        return filtered


    #
    # Auxiliar method to verify if array contains object based on ID
    # shouldn't probably be here
    #
    __arrayContainsObject: (array, object) ->
        for o in array
            if object.id == o.id
                return true
        return false


    #
    # given a list of items, returns them sorted based on @props.compare()
    # and ready to be rendered by react. (in this case, gets them DIV wrapped)
    #
    _getItems: (list, filtering=false) ->
        items = []

        for item, i in list
            item_class_name = "item"
            is_active_item = @state.active_item_index == i

            if filtering && is_active_item
                item_class_name += " active"

            item_component = React.createElement(item.renderer, item.props)

            items.push(
                React.DOM.div({
                        ref: "active" if is_active_item
                        key: item.id
                        onClick: @_onItemToggle.bind(null, item)
                        className: item_class_name
                    },
                    item_component
                )
            )

        return items


    #
    # when an item gets activated (through click, enter, backspace, etc…)
    # will trigger a call to item.onToggle and clear @_timeout
    # since the
    #
    _onItemToggle: (item) ->
        item.onToggle(item.id)
        clearTimeout(@_timeout) # to avoid hidding the filter list while
                                # input loses focus
        input = @refs.input.getDOMNode()
        input.focus()


    #
    # on onKeyDown React keyboard event, detects relevant keys
    # and acts accordingly before analysing the filter query
    #
    _processActions: (event) ->
        key = event.keyCode
        active_item_index = @state.active_item_index
        filtered = @state.filtered
        selected = @state.selected

        if key == ARROW_DOWN
            @_showFilteredItems()
            if active_item_index < filtered.length - 1
                @setState {active_item_index: active_item_index + 1}

        else if key == ARROW_UP
            @_showFilteredItems()
            if active_item_index > 0
                @setState {active_item_index: active_item_index - 1}

        else if key == ENTER
            active_item = filtered[active_item_index]
            @_onItemToggle(active_item) if active_item
            event.preventDefault()

        else if key == BACKSPACE && @state.query == '' && selected.length > 0
            @_onItemToggle(selected[selected.length - 1])

        else if key == ESCAPE
            @_hideFilteredItems()


    #
    # on onChange React form event, updates the query.
    # since the query changes, it also recalculates de filtered items
    # and updates active_item_index in case it overflows.
    #
    _processQuery: (event) ->
        @_showFilteredItems()
        input = event.target
        query = input.value

        return if query == @state.query

        filtered = @_calculateFiltered(@props.universe, @state.selected, query)
        active_item_index = @state.active_item_index

        if active_item_index >= filtered.length && filtered.length > 0
            active_item_index = filtered.length - 1

        @setState {
            query: query
            filtered: filtered
            active_item_index: active_item_index
        }


    #
    # on input onFocus React focus event, will display the filter list.
    # (it is hidden by default, this should be configurable)
    #
    _showFilteredItems: ->
        @props.onFocus() if @props.onFocus
        @setState { show_filtered_items: true }

    #
    # on input onBlur React focus event, will hide the filter list.
    # the timeout nouance is to avoid hidding the filter list
    # when clicking items.
    #
    _hideFilteredItems: ->
        @_timeout = setTimeout ( =>
            @props.onBlur() if @props.onBlur
            @setState { show_filtered_items: false }
        ), 0

    #
    #
    #
    render: ->
        filtered_items = @_getItems(@state.filtered, true)
        selected_items = @_getItems(@state.selected)

        filtered_items_section =
            React.DOM.div {className: "universe"},
                React.DOM.div {className: "container"},
                    filtered_items

        React.DOM.div {},
            if @state.show_filtered_items && @state.filtered_items_on_top
                filtered_items_section

            React.DOM.div {className: "selected"},
                React.DOM.div {className: "container"},
                    selected_items
                    React.DOM.input {
                        ref: "input"
                        value: @state.query
                        placeholder: @props.placeholder
                        onKeyDown: @_processActions
                        onChange: @_processQuery
                        onFocus: @_showFilteredItems
                        onBlur: @_hideFilteredItems
                    }

            if @state.show_filtered_items && !@state.filtered_items_on_top
                filtered_items_section

module.exports = ReactSelector
