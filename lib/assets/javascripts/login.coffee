class LoginManager
  constructor:(@container) ->
    @loginForm = @container.find("#login")
    @registerForm = @container.find("#register")
    @forgotForm = @container.find("#forgot")

    @loginLink = @container.find("#login-link")
    @forgotLink = @container.find("#forgot-link")
    @registerLink = @container.find("#register-link")

    @loginLink.bind "click", @showLoginForm
    @forgotLink.bind "click", @showForgotForm
    @registerLink.bind "click", @showRegisterForm

    @loginSubmit = @container.find("#login-submit")

    @loginSubmit.click (e) ->
      if $(@).closest("form").find("#email").val().length == 0
        e.preventDefault()
        wrapper = $(@).closest(".login-wrapper")
        wrapper.addClass("wobble")
        Notifications.push
          text: "<i class='icon-warning-sign'></i> invalid username or password"
          autoDismiss: 3
          class: "error"

        wrapper.bind "webkitAnimationEnd animationEnd mozAnimationEnd", ->
          wrapper.off "webkitAnimationEnd"
          wrapper.removeClass("wobble")

    action = @getParameterByName("action")

    if action == 'register'
      @showRegisterForm()
    else if action == 'forgot-password'
      @showForgotForm()
    else
      @showLoginForm()

  showLoginForm: =>
    @hideAll()
    @loginForm.show()
    @registerLink.show()
    @forgotLink.show()

  showRegisterForm: =>
    @hideAll()
    @registerForm.show()
    @loginLink.show()
    @forgotLink.show()

  showForgotForm: =>
    @hideAll()
    @forgotForm.show()
    @loginLink.show()
    @registerLink.show()

  hideAll: =>
    @loginForm.hide()
    @registerForm.hide()
    @forgotForm.hide()
    @loginLink.hide()
    @forgotLink.hide()
    @registerLink.hide()




  getParameterByName: (name) ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    regexS = "[\\?&]" + name + "=([^&#]*)";
    regex = new RegExp(regexS);
    results = regex.exec(window.location.search);
    if results == null
      return ""
    else
      return decodeURIComponent(results[1].replace(/\+/g, " "))


$ ->
  new LoginManager $("#login-manager")