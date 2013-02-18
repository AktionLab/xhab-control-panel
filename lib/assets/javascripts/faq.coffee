class @Faq
  constructor:(@container) ->
    @questionList = @container.find("> li")
    @questions = ({q: $(el).find("> h4"), a: $(el).find("> p")} for el in @container.find("li"))
    @searchInput = $("<input type='text' id='faq-search' class='fill-up' placeholder='enter keyword here...'/>")
    @container.before @searchInput
    i = 0
    @toc = ($("<li><span class='faq-number'>#{++i}</span> <a href='#faq-question-#{i}'>#{el.q.text()}</a></li>") for el in @questions)
    i = 0
    el.q.attr("id", "faq-question-#{++i}") for el in @questions
    @tocLinksContainer = $("<ol class='faq-questions'></ol>")
    @tocLinksContainer.append(link) for link in @toc
    @searchInput.after(@tocLinksContainer)

    @tocLinksContainer.find("a").click (e) ->
      #this fixes the whole window screen scrolling a little to the top when you have a lot of faq questions and you click on a question number that has the answer to the bottom
      e.preventDefault()
      link = $(@)
      scrollTo = $(link.attr("href"));
      container = $("#main")
      container.scrollTop(scrollTo.offset().top - container.offset().top + container.scrollTop())

    @tocLinksContainer.after "<hr/>"

    i = 0
    question.q.prepend("<span class='faq-number'>#{++i}</span>") for question in @questions

    @tocLinks = @tocLinksContainer.find("li")


    @searchInput.keyup =>
      val = @searchInput.val()
      if val.length > 0
        @questionList.each (index, li) =>
          el = $(li)
          pattern = new RegExp(val, 'i');
          if !pattern.test(el.text())
            el.hide()
            $(@tocLinks[index]).hide()
          else
            el.show()
            $(@tocLinks[index]).show()
      else
        @questionList.each -> $(@).show()
        @tocLinks.each -> $(@).show()

