require ['Facebook', 'mootools', 'domReady!'], (Facebook) ->
	console.log 'main init'

	$('logout').addEvent 'click', (event) ->
		 Facebook.logout () -> console.log 'logged out'

	$$('[data-fb-login]').addEvent 'click', (event) ->
		scope = this.getProperty 'data-fb-login'

		Facebook.login
			scope: scope
			onLogin: (authResponse) -> console.log 'logged in', authResponse
			onCancel: () -> console.log 'login canceled'

	Facebook.addEvent 'onAuthChange', (loggedIn) ->
		if loggedIn
			console.log 'do logged in stuff'

			Facebook.getUserInfo ['name','hometown'], (response) ->
				console.log 'I did logged in stuff', response
		else
			console.log 'do logged out stuff'

	$$('form.permissions')[0].addEvent 'submit', (event) ->
		form = event.target
		resultsOutput = form.getElement 'textarea'

		event.preventDefault()

		## Get the checked fields
		checked = form.getElements 'input:checked'
		requestedFields = (el.getProperty('value') for el in checked)

		## Use the fields array to get data from Facebook
		Facebook.requireUserInfo requestedFields, (response) ->
			console.log response
			resultsOutput.innerText = JSON.encode response






