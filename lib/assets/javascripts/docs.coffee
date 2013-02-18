#calendar events.
#this is a simple wrapper over the fullcalendar events list that enables events creation and edit
# -> it does not persist anything, I wrote it just for demo purposes
# -> it doesn't have any written tests and it might have bugs, feel free to use it however you wish :)

class CalendarEvent
  constructor: (@container, add) ->
    @container.bind "dblclick", @handleDoubleClick

    if add?
      input = @container.find("input")
      input.focus()
      input.bind "keyup", @handleInputKeyup
      input.bind "blur", @handleInputBlur
    else
      @makeFullCalendarEventObject()

  handleInputKeyup: (e) =>
    input = $(e.target)
    if e.keyCode == 13
      if input.val().length == 0
        @container.remove()
      else
        @finalizeEvent(input.val())

  handleInputBlur: (e) =>
    input = $(e.target)
    if input.val().length == 0
      @container.remove()
    else
      @finalizeEvent(input.val())

  finalizeEvent: (val) =>
    @container.find("a").html(val)
    @makeFullCalendarEventObject()

  handleDoubleClick: (e) =>
    input = $("<input type='text'>")
    link = $(e.target)
    oldval = link.text()
    input.val(oldval)
    link.html(input)
    input.focus()

    input.bind "keyup", (e) =>
      if e.keyCode == 13
        if input.val().length > 0
          link.html(input.val())
          @makeFullCalendarEventObject()
        else
          link.html(oldval)

    input.bind "blur", (e) =>
      if input.val().length > 0
        link.html(input.val())
        @makeFullCalendarEventObject()
      else
        link.html(oldval)

  makeFullCalendarEventObject: =>
    link = $(@container)
    eventObject = title: $.trim(link.text())
    link.data('eventObject', eventObject);
    link.draggable
      zIndex: 999
      revert: true
      revertDuration: 0

class CalendarEvents
  constructor:(@container) ->
    @addLink = @container.find("#add-event")
    @container.find("a.external-event").each -> new CalendarEvent($(@))
    @template = "<li><a class='external-event'><input type='text'></a></li>"
    @addLink.bind "click", @handleAddLink

  handleAddLink: =>
    view = $(@template)
    view.insertBefore @addLink.parent()
    new CalendarEvent(view, true)


#a small js wrapper for a confirm box with a checkbox
#see it in action in the dashboard/tabbable component, when you hit the delete stats button
#it's not meant for production, it's just an example of what it can be done

class ConfirmAction
  constructor: (@container) ->
    @link = @container.find("a[rel='action']")
    @confirm = @container.find("[rel='confirm-action']")
    @link.click => @confirm.fadeIn()
    @cancelLink = @container.find("a[rel='confirm-cancel']")
    @confirmLink = @container.find("a[rel='confirm-do']")
    @confirmLink.hide()
    @confirmLink.click => @container.slideUp()

    @confirmCheck = @container.find("[rel='confirm-check']")

    @cancelLink.click =>

      @confirm.fadeOut()
      @confirmCheck.removeAttr("checked")
      @confirmLink.hide()

    @confirmCheck.change =>
      if @confirmCheck.attr("checked") == "checked"
        @confirmLink.fadeIn()
      else
        @confirmLink.fadeOut()

$ ->

  #generic stuff. you should set these up accordingly to your app needs

  #jquery has touchstart enabled by default, but it messes up bs-dropdowns
  $("html, body").off("touchstart");

  #initializing modal links that open.. a modal
  $("#modal-link").click -> $('#modal').modal()

  #initializing bootstrap tooltip
  $('.input-error').tooltip()

  ##initializing the chosen plugin for select boxes
  $(".chzn-select").chosen()

  #initializing the textarea tag convert plugin
  $('textarea.tagme').tagify()

  #initializing the faq list plugin
  new Faq($(".faq-list"))

  #initializing the jquery datepicker
  $('#datetimepicker').datepicker()

  #initializing the confirm checkbox (see it in dashboard/tabbable component)
  new ConfirmAction($("#fix-stats"))
  new ConfirmAction($("#fix-stats2"))

  #initializing calendar events for full calendar
  new CalendarEvents($('#external-events'))

  #initializing data table
  $('.data-table').dataTable
    "bJQueryUI": true,
    "sPaginationType": "full_numbers",
    "sDom": '<""l>t<"F"fp>'

  #initializing full calendar
  $("#calendar").fullCalendar
    header:
      left: 'prev,next today'
      center: 'title'
      right: 'month,agendaWeek,agendaDay'
    editable: true
    droppable: true
    drop: (date, allDay) ->
      originalEventObject = $(@).data('eventObject')
      copiedEventObject = $.extend({}, originalEventObject)
      copiedEventObject.start = date
      copiedEventObject.allDay = allDay
      $("#calendar").fullCalendar('renderEvent', copiedEventObject, true)
      if $("#drop-remove").is(":checked")
        $(@).remove()


