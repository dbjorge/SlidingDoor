'use strict';

applyOptions = ->
  chrome.storage.sync['options'] = parseOptions()
  return
  
parseOptions = -> {
  'jobResults': {
    # One of ['disabled','dim','hidden']
    'filteringStyle': $('#jobResultsFilteringStyle').val(),
    
    # Boolean
    'endlessMode': $('#jobResultsEndlessMode').is(':checked')
  }
}

$('#saveButton').on 'click', applyOptions