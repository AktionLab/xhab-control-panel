class @Notification

  constructor: (@template, @options) ->
    @item = {}
    @item.imagePath = @options.imagePath
    @item.imageClass = "img"
    if @options.fillImage == true
      @item.imageClass += " fill"
    else
      @item.imageClass += " border"

    @item.text = @options.text
    @item.time = @options.time

    @item.itemClass = " no-image" unless @options.imagePath?

    @view = $(_.template(@template, item: @item))

    @view.addClass options.class if options.class?

    @hideButton = @view.find(".hide")

    @hideButton.bind "click touchend", @dismiss

    if @options.autoDismiss?
      setTimeout =>
        @dismiss()
      , @options.autoDismiss*1000


  dismiss: =>
    @view.slideUp().queue =>
      @options._dismiss(@, @options.dismiss)
      @view.remove()