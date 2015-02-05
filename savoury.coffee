#<debug>
unsupported = [
  'isSavoury',
  'isSavouryWaiting',
  'isSavourySending',
  'isSavouryError',
  'isSavouryComplete',
  'savouryDisableWhileSending',
  'defaultContext',
  'disabledWhileSending',
  'lightContext',
  'lightErrorContext'
]
_.each unsupported, (u)->
  UI.registerHelper u, ->
    try throw new Error() catch e
    Log.error("Unsupported Savoury Operation [#{u}], helper not defined on template ", e.stack)
    return null
  return
#</debug>
class Savoury

  @STATE_WAITING = null
  @STATE_SENDING = 'sending'
  @STATE_ERROR = 'error'
  @STATE_COMPLETE = 'complete'

  @DEFAULTS =
    sending: "Saving..."
    tpl_sending: "savoury__sending"
    complete: "Saved!"
    tpl_complete: "savoury__complete"
    error: "There was an error processing your request"
    tpl_error: "savoury__error"

  constructor: (options={}, @autoclear=true)->
    #<debug>
    if typeof options == 'string'
      try throw new Error() catch e
      Log.error("String passed to savoury constructor", e.stack)
    #</debug>
    @state = new ReactiveVar(null)
    @message = new ReactiveVar(null)
    @options = _.extend({}, Savoury.DEFAULTS, options)
    return

  setMessage: (state, args...)->
    unless state? and @options[state]?
      @message.set(null)
      return

    if typeof @options[state] == "string"
      @message.set(@options[state])
    else
      @message.set(@options[state].apply(null, args))
    return

  reset: =>
    @setMessage(Savoury.STATE_WAITING)
    @setState(Savoury.STATE_WAITING)
    return

  sending: ->
    @setMessage(Savoury.STATE_SENDING)
    @setState(Savoury.STATE_SENDING)
    return

  error: (err)->
    @setMessage(Savoury.STATE_ERROR, err)
    @setState(Savoury.STATE_ERROR)
    return

  complete: (result)->
    @setMessage(Savoury.STATE_COMPLETE, result)
    @setState(Savoury.STATE_COMPLETE)
    if @autoclear
      Meteor.setTimeout @reset, 3000

    return

  wrapMethod: (methodName, args, options, callback)->
    @sending()
    Meteor.apply methodName, args, options, (e, r)=>
      if e?
        console?.error?(e)
        @error(e)
      else
        @complete(r)

      if callback?
        callback(e,r)
      return
    return

  getState: -> @state.get()

  getMessage: -> @message.get()

  isState: (state)-> @state.get() == state

  isWaiting: -> @isState(Savoury.STATE_WAITING)

  isSending: -> @isState(Savoury.STATE_SENDING)

  isError: -> @isState(Savoury.STATE_ERROR)

  isComplete: -> @isState(Savoury.STATE_COMPLETE)

  setState: (state)-> @state.set(state)

  context: (override_templates={})->
    templates = _.extend
      sending: @options.tpl_sending
      error: @options.tpl_error
      complete: @options.tpl_complete
    ,
      override_templates

    state = @state.get()
    message = @message.get()
    if message? and state? and templates[state]? and templates[state] of Template
      return {
        tpl: templates[state],
        data: {
          message: message,
          state: state
        }
      }
    return null

  lightContext: =>
    return @context({
      sending: 'savoury_light__sending',
      complete: 'savoury_light__complete',
      error: null
    })

  lightErrorContext: =>
    return @context({
      sending: null,
      complete: null,
      error: 'savoury_light__error'
    })

  disabledWhileSending: ->
    state = @state.get()
    if state is 'sending'
      return {disabled: 'disabled'}
    else
      return {}

Template.savoury.helpers
  chooseTemplate: ->
    if @?.tpl?
      return Template[@tpl]
    else
      return null

@Savoury = Savoury
