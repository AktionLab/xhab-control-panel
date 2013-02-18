Array::remove = ( e ) -> @splice i, 1 if (i = @indexOf e) isnt -1

class @Notifications

  @instance: null

  constructor: (options) ->

    Notifications.instance = @ if Notifications.instance == null

    @parent = options.container

    @notificationTemplate = $("#template-notification").html()
    @notificationsTemplate = $("#template-notifications").html()


    @container = $(_.template(@notificationsTemplate, {bootstrapPositionClass: options.bootstrapPositionClass ? "span6 offset4"}))

    @parent.prepend(@container)

    @content = @container.find("#content #notes")


    @notificationsContainer = @container.find("#notifications")
    @dismissAllButton = @container.find("#dismiss-all")
    @dismissAllButton.bind "click", @dismissAll

    @mobileEvents()

    @notifications = []

  mobileEvents: =>
    @notificationsContainer.bind "touchstart", =>
      @notificationsContainer.addClass("active")

  @push: (options) =>
    new Notifications container: $("body"), bootstrapPositionClass: "span6 offset3" if Notifications.instance == null
    Notifications.instance.push options

  push: (options) =>
    options._dismiss = @onDismiss
    note = new Notification(@notificationTemplate, options)
    @flipIn(note.view)
    @notifications.push note

  flipIn: (view) =>
    if @notifications.length == 0
      @notificationsContainer.addClass("flipInX")
      @content.prepend(view)
    else
      @content.prepend(view)

  onDismiss: (notification, callback) =>
    @removeNotification(notification)
    callback() if callback?

  dismissAll: =>
    notification.dismiss() for notification in @notifications

  removeNotification: (notification) =>
    @notifications.remove(notification)
    notification = null
    @notificationsContainer.removeClass("flipInX active") if @notifications.length == 0
