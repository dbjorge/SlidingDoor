'use strict'

loadOptions = (postLoadContinuation) ->
  chrome.storage.sync.get 'options', (options) ->
    # FIXME: Support the real option and default sensibly
    endlessModeOptions =
      enabled: true
    postLoadContinuation endlessModeOptions

applyEndlessModeOptions = (endlessModeOptions) ->
  console.log "Endless mode: #{endlessModeOptions.enabled}"

$().ready ->
  loadOptions applyEndlessModeOptions