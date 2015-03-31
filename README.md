# React Selector
React Selector is a [React](https://github.com/facebook/react) component that allows to filter and move item between two lists.

## How it works
ReactSelector expects two arrays of `items` (`universe` and `selected`) and a `compare` function as [props](http://facebook.github.io/react/docs/tutorial.html#using-props).

* `universe` must contain all the `items` that we can selected from.
* `selected` that contains the currently selected items.
* `compare` a compare function to be used while sorting items on both mentioned arrays.


### Defining `items`
An `item` is an object to be listed by React Selector.
It must contain an unique identifier, `id`, a React class that instructs React Selector on how it is rendered, some eventual `props` to be passed while rendering, a `onToggle` function that is triggered when the `item` is activated (through `ENTER` or click) and a `name` that is used by React Selector to compare against an eventual filter query. Here's how it should look like

````coffeescript
item = {
  id: i
  renderer: Avatar # a React class
  props: {url: "www.someavatarurl.com"}
  name: name
  onToggle: _toggleItem # a function that will be called when `item` is activated
}
````

## Example

Here's a very simple example illustrating the usage of ReactSelector to select from a list of items that consiste in an avatar and an user name.

[Here](https://github.com/jvalente/react-selector-demo) you can see a more complex demo that considers the existence of more than one type of items like a special "Select All" item.

````coffeescript
React = require('react')
ReactSelector = require('react-selector')

# Renders an avatar picture and name
Avatar = React.createClass
    render: ->
        React.DOM.div {},
            React.DOM.img {src: "#{@props.url}"}
            React.DOM.p {}, @props.name
            
            
UserPicker = React.createClass
  
  # helper method to generate some initial user items
  _seedUserItems: ->
      user_items = []
      for i in [0..9]
          name = "user #{i}"
          url = "www.avatar.com/#{i}/pic.png"
          user_item = {
              id: i
              renderer: Avatar
              props: {name: name, url: url}
              name: name
              onToggle: @_toggleUserItem
          }
          user_items.push(user_item)
      return user_items


  getInitialState: ->
    return {
        all_user_items: @_seedItems()
        selected_user_items: []
    }
  
  
  _toggleUserItem: (id) ->
    all_user_items = []
    selected_user_items = []
    
    # if user item `id` is selected, remove it from the selection
    # if user item `id` is NOT selected, ADD it selection
    
    @setState {
      all_user_items: all_items
      selected_user_items: selected_items
    }

  _compare: (a, b) ->
    # a compare function that is used to keep items in order while listing
    return 0
    
  render: ->
    React.DOM.div {},
      React.createElement(ReactSelector, {
        universe: @state.all_user_items
        selected: @state.selected_user_items
        compare: @_compare
      })
````

