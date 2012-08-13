###

# log

`log` is an alternative to the standard `console.log`. It adds logging levels and
timestamps to the messages. Logging can be enabled or disabled, sent directly to
the console, or (soon) redirected to Sentry through Raven.js.

## Log levels

The log level is set by window.log_level. Any log calls that are below the set
level will be ignored. To set the log level, assign it to a level defined in
Logging, eg `window.log_level = Logging.DEBUG`. It can also be a String name
of the level, eg `window.log_level = 'error'`. This is useful when using the
localStorage overrides.

The levels, in order, are:

* DEBUG
* INFO
* WARNING
* ERROR
* CRITICAL


## Example usage

    > log 'message'
    > log.debug 'message'
    2012-08-06T22:32:17.227Z [DEBUG]     message

    > log.info 'message'
    2012-08-06T22:32:17.227Z [INFO]      message

    > log.warning 'message'
    2012-08-06T22:32:17.227Z [WARNING]   message

    > log.error 'message'
    2012-08-06T22:32:17.227Z [ERROR]     message

    > log.critical 'message'
    2012-08-06T22:32:17.227Z [CRITICAL]  message


## Overrides

The level can be overridden from a localStorage value. This is useful for
debugging in production, in cases where the level needs to be set before the
page loads.

The overrides are `log_to_console` and `log_level`. To set them, store the
desired value in localStorage under those keys:

    localStorage.setItem('log_level', 'debug')
    localStorage.setItem('log_to_console', true)

Using the above, the log will output at the debug level to the console, even
if the page specifies otherwise.

###


# The logging levels, in order.
window.Logging =
    DEBUG       : [0, 'debug']
    INFO        : [1, 'info']
    WARNING     : [2, 'warning']
    ERROR       : [3, 'error']
    CRITICAL    : [4, 'critical']

# Allow for overriding the settings using localStorage, helpful for debugging on
# production.
if localStorage?
    log_to_console_override = localStorage.getItem('log_to_console')
    log_level_override      = localStorage.getItem('log_level')
    if log_to_console_override?
        window.log_to_console = log_to_console_override
    if log_level_override?
        window.log_level = log_level_override

# Default log_level is CRITICAL.
if not window.log_level?
    window.log_level = window.Logging.CRITICAL

# Do not log to console by default.
if not window.log_to_console?
    window.log_to_console = false

# Convert log levels that are just the string name to the log level enumeration.
if _(window.log_level).isString()
    window.log_level = window.Logging[window.log_level.toUpperCase()]

# Convert log_to_console from string (if coming from localStorage)
if window.log_to_console is 'false'
    window.log_to_console = false
else if window.log_to_console is 'true'
    window.log_to_console = true

# If not logging to the console, send all thrown errors to `log.error` for
# routing to Sentry.
if not window.log_to_console
    window.onerror = (args...) ->
        log.error(args...)



# Public: The base logging function. `log` by itself will default to debug.
#
#         The actual logging functions are:
#               log.debug
#               log.info
#               log.warning
#               log.error
#               log.critical
#
#         All take the same arguments and return the same value. The effect
#         depends on the value of `window.log_level`. If the `log_level` is
#         higher than the level of the function, nothing happens. If the
#         `log_level` is less-than or equal-to the level of the function, the
#         message is logged. If `window.log_to_console` is true, the message is
#         displayed in the console; if it's false, nothing happens (for now).
#
# args - Any number/type of arguments to be joined by a space and logged.
#        If not log_to_console, all arguments are converted to their
#        `.toString()` form.
#
# Returns `true` if the message was logged, `false` if not.
window.log = (args...) ->
    # Calls to log directly are passed through to log.debug for convenience.
    return window.log.debug(args...)

# Add the different levels to log. 
_(window.Logging).each (level) ->
    window.log[level[1]] = (args...) ->
        return doLog(level, args...)



# Public: A function wrapper for executing functions only if in debug mode. A
#         useful scenario: automatically "clicking" a certain tab while working
#         on the tab's panel, so when the page reloads with livereload, you
#         don't have to click the tab every time.
#
# fn - A Function to be executed if the `log_level` is Logging.DEBUG.
#
# Returns nothing.
window.debug = (fn) ->
    if window.log_level[0] is 0
        log 'debug fn:', fn.toString().replace(/\n/g, ' ')
        fn()
    return



# Private: The actual logging implementation. Logs the message with its level
#          and the current Zulu-time in ISO format.
#
# level     - A Logging level to log the message at.
# log_args  - Zero or more arguments to output to the log.
#
# Returns `true` if the message was logged, `false` if not.
doLog = (level, log_args...) ->
    was_logged = false
    if level[0] >= window.log_level[0]
        # Prepare ISO-formatted timestamp and level name.
        now = new Date()
        timestamp = now.toISOString()
        level_string = level[1].toUpperCase()

        # Adjust the spacing to line the message of different levels up.
        spacing = (' ' for i in [2..11-level_string.length]).join('')

        message_prepend = "#{ timestamp } [#{ level_string }]#{ spacing }"

        if window.log_to_console
            # Pass the log arguments through, allowing the console to display
            # objects in an expandable way.
            console.log(message_prepend, log_args...)
            was_logged = true
        # else
            # Join the log arguments into a single string.
            # message_string = (arg.toString() for arg in args).join(' ')

    return was_logged