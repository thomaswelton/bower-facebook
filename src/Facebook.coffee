define ['EventEmitter', 'module'], (EventEmitter, module) ->
	class Facebook extends EventEmitter
		constructor: (@config) ->
			console.log 'FB constructor'
			
			@api = null
			@isIframe = top isnt self

			##Init EventEmitter
			super()

			if FB?
				@fbAsyncInit()
			else
				window.fbAsyncInit = @fbAsyncInit
				@injectFB()
			
			##facebook like tracking
			@onReady (FB) =>
				FB.Event.subscribe 'edge.create', (url) =>
					@fireEvent 'onLike', url

				FB.Event.subscribe 'edge.remove', (url) =>
					@fireEvent 'onUnlike', url

		ui: (args...) =>
			@onReady (FB) ->
				FB.ui args...

		login: (callback, scope) =>
			if @loginStatus?.status? and @loginStatus.status is 'connected'
				return callback @loginStatus
			##else
			@onReady (FB) ->
				FB.login callback, scope

		onReady: (callback) =>
			if FB?
				callback FB
			else
				@once 'fbInit', () =>
					callback FB

		fbAsyncInit: () =>
			@fbInit()
			@fbiFrameInit() if @isIframe

		fbInit: () =>
			FB.init
				appId      : @config.appId
				channelUrl : @config.channelUrl
				status     : true
				cookie     : true
				xfbml      : true
				
			FB.getLoginStatus (@loginStatus) => return

			@fireEvent 'fbInit'

		fbiFrameInit: () =>
			FB.Canvas.scrollTo 0,0
			FB.Canvas.setSize
				width: 810
				height: document.body.offsetHeight
			
			resizeInterval = () ->
				FB.Canvas.setSize
					width: 810
					height: document.body.offsetHeight

			window.setInterval resizeInterval, 500

		injectFB: () ->
			return if document.getElementById 'facebook-jssdk'

			if !document.getElementById 'fb-root'
				root = document.createElement 'div'
				root.setAttribute 'id','fb-root'

				document.body.appendChild root

			requirejs ['//connect.facebook.net/en_US/all.js']

		renderPlugins: (cb) ->
			@onReady () ->
				## Parse only unrendered plugins for browser that support querySelectorAll
				if document.querySelectorAll?
					plugins = document.body.querySelectorAll '.fb-like:not([fb-xfbml-state=rendered])'

					## Each plugin renders async, count the amount to render
					unrenderedCount = plugins.length

					cbStack = () ->
						## Decrement the unrendered count
						unrenderedCount--
						## Call the main callback once all done
						cb() if unrenderedCount is 0

					for plugin in plugins
						FB.XFBML.parse document.body, cbStack

				else
					FB.XFBML.parse document.body, cb

		## http://developers.facebook.com/docs/reference/javascript/FB.Canvas.getPageInfo/
		getCanvasInfo: (cb) ->
			@onReady (FB) ->
				FB.Canvas.getPageInfo (info) ->
					cb info

		setCanvasSize: (width, height) ->
			@onReady (FB) ->
				FB.Canvas.setSize
					width: width
					height: height
				    

	return new Facebook module.config()
