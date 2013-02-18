class PlastiqueDocumentation
  constructor: (@container) ->
    @menu = @container.find("#documentation-menu")
    @listLinks = @menu.find("li")
    @links = @menu.find("a")
    @links.bind "click", @menuSelected
    @title = @container.find("#docs-title")
    @sections = @container.find("section")
    @sections.hide()
    @links.first().trigger("click")

  menuSelected: (e) =>
    link = $(e.target)
    id = link.attr("data-link")
    title= link.text()
    @sections.hide()
    @container.find("##{id}").show()
    @title.html(title)
    @listLinks.removeClass("active")
    link.parent().addClass("active")

$ ->
  new PlastiqueDocumentation($("#plastique-documentation"))