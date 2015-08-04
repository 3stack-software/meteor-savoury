# Savoury

Reactively show the user the status of their method call.

Just add to your template `{{> savoury mySavouryContext}}` and savoury will automatically render the right template
 based on the current status of your method calls.

## Examples

Basic bootstrap `alert-` based theme:

(Useful for Server-Only methods)
![savoury example](https://raw.githubusercontent.com/3stack-software/meteor-savoury/resources/savoury-full-example.gif)


A "light" theme, useful for methods with latency compensation, but you still want to let a user know that it's saved.

![savoury light example](https://raw.githubusercontent.com/3stack-software/meteor-savoury/resources/savoury-light-example.gif)


## Installing

`meteor add 3stack:savoury`

## Usage

Set up savoury, so that it can be called instead of directly calling a meteor method.

```js
Template.myTemplate.created = function(){
  this.savoury = new Savoury(); // pass different templates / messages,
}
Template.myTemplate.destroyed = function(){
  this.savoury = null;
}

Template.myTemplate.helpers({
  // use this in the template like `{{> savoury mySavouryContext}}`
  mySavourContext: function(){
    return Template.instance().savoury.context();
  }
});

Template.myTemplate.events({
  'click #my-action': function(e){
    e.preventDefault();
    // savoury will automatically update it's state based on the progress of the method
    Template.instance().savoury.wrapMethod('myLongRunningAction', [arg1, arg2])
  }
})

```


## API

`new Savoury(messages, autoclear=true)`

Overwrite the "messages"and templates shown for each state.

If `autoclear` is true, will return to "nil" state after being in "complete" for 3 seconds.

Default Messages/Templates:
```js
messages = {
    sending: "Saving..."
    tpl_sending: "savoury__sending"
    complete: "Saved!"
    tpl_complete: "savoury__complete"
    error: "There was an error processing your request"
    tpl_error: "savoury__error"
}
```


`Savoury.prototype.context()`
Returns a suitable data context for passing to the savoury template


`Savoury.prototype.wrapMethod(name, args, options, callback)`
Invokes a meteor method, but monitors it's state.
