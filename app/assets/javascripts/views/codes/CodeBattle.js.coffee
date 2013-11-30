class Dmtc.Views.CodeBattle extends Backbone.View
  el: '.battle'

  events:
    'keyup .own-code > textarea': 'updateCode'

  initialize: (options) ->
    @questId    = options.questId
    @userId     = options.userId
    @dispatcher = new WebSocketRails('localhost:3000/websocket')
    @dispatcher.on_open = (data) =>
      @dispatcher.trigger 'initialize_connection', {
        questId: @questId
      }, (data)  =>
          @initializeConnection(data)
       , (error) =>
          @handleConnectionError(error)
    @$(".own-code > textarea").val('')
    @$(".own-code > textarea").prop 'disabled', true
    @$(".enemy-code > textarea").val('')

  getOpponent: (battleData) ->
    users = battleData.users
    _.find users, (u) =>
      u.id != @userId

  initializeConnection: (battleData) ->
    console.log battleData
    @token = battleData.token
    @battleChannel = @dispatcher.subscribe(@token)
    @battleChannel.bind 'new_user', (battleData) =>
      @handleNewUser battleData
    @battleChannel.bind 'ready', (data) =>
      @prepareStartGame()
    @battleChannel.bind 'code_updated', (battleData) =>
      @handleCodeUpdated battleData
    @battleChannel.bind 'ready_to_start', =>
      @prepareStartGame()
    @battleChannel.bind 'need_update', =>
      @sendCode @$('.own-code > textarea').val()
    @setTexts battleData

    @dispatcher.trigger 'ready_to_start', { token: @token }
    if battleData.started_at?
      @startGame()

  setTexts: (battleData) ->
    @setOponentText battleData

  handleNewUser: (battleData) ->
    console.log battleData
    @setOponentText battleData

  prepareStartGame: ->
    textDiv = $('#game-messages')
    textDiv.text "バトルが始まる" # I18n.t('battle.will_start')
    setText = (i) -> setTimeout((-> textDiv.text(i)), (6 - i) * 1000)
    setTimeout (-> textDiv.css 'left', '48%'), 1000
    for i in [5..1]
      setText(i)
    setTimeout ->
      textDiv.css 'left', '40%'
      textDiv.text "Battle!"
    , 6000
    setTimeout (=> @startGame()), 7000
    return

  startGame: ->
    $('#game-messages').hide()
    code = @$(".own-code > textarea")
    code.prop 'disabled', false
    code.focus()

  setOponentText: (battleData) ->
    opponent = @getOpponent battleData
    if opponent?
      @setText opponent, '.enemy-code'

  setText: (user, selector) ->
    @$(selector).attr 'data-id', user.id
    @$(selector).find('.username').text(user.username)

  handleConnectionError: (error) ->
    console.log error

  handleCodeUpdated: (data) ->
    return if data.id == @userId
    @$(".code[data-id=#{data.id}] > textarea").val data.code

  sendCode: (code) ->
    data =
      id  : @userId
      code: code
    @battleChannel.trigger 'code_updated', data

  updateCode: (e) ->
    @sendCode $(e.target).val()
