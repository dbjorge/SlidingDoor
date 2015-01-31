'use strict';

defaultOptions = {
  'jobResults': {
    # One of ['disabled','dim','hidden']
    'filteringStyle': 'hidden'
    'endlessMode': true
  }
}

parseOptions = -> {
  'jobResults': {
    'filteringStyle': $('#jobResultsFilteringStyle').val()
    'endlessMode': $('#jobResultsEndlessMode').is(':checked')
  }
}

saveOptions = ->
  status = $('#saveStatus')
  status.text 'Saving...'
  chrome.storage.sync.set {'options': parseOptions()}, ->
    status.text 'Saved!'
    setTimeout (-> status.text ''), 750

loadOptionsFromObject = (options) ->
  $('#jobResultsFilteringStyle').val(options.jobResults.filteringStyle)
  $('#jobResultsEndlessMode').prop('checked', options.jobResults.endlessMode)

loadOptions = ->
  status = $('#saveStatus')
  loadOptionsFromObject defaultOptions
  status.text 'Loading...'
  chrome.storage.sync.get {'options': defaultOptions}, (items) ->
    loadOptionsFromObject items.options
    $('#saveButton').click saveOptions
    status.text 'Loaded!'
    setTimeout (-> status.text ''), 750

$().ready loadOptions