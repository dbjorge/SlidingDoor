'use strict'

findNextUrl = ->
  $('.pagingControls').last()
    .find('.next')
    .find('a')
    .uri()

loadNextPage = ->
  nextUrl = findNextUrl()
  $.get nextUrl, (nextPageContent) ->
    currentPageJobListings = $('.jobListings')
    nextPageJobListings = $(nextPageContent).find('.jobListings')
    currentPageJobListings.after nextPageJobListings

patchJobsPageWithLoadNextPageButton = ->
  loadNextPageButtonSource = '''
    <button
      type="button"
      id="loadNextPageButton"
      class="tight gd-btn gd-btn-button gd-btn-1 gd-btn-med gradient"
      >
      <span>Load Next Page</span>
    </button>
    '''

  $('.jobAlertButton').last().after loadNextPageButtonSource
  $('#loadNextPageButton').click loadNextPage

enableEndlessMode = ->
  patchJobsPageWithLoadNextPageButton()

applyEndlessModeOptions = (endlessModeOptions) ->
  console.log "Endless mode: #{endlessModeOptions.enabled}"
  if endlessModeOptions.enabled
    enableEndlessMode()

loadOptions = (postLoadContinuation) ->
  chrome.storage.sync.get 'options', (options) ->
    # FIXME: Support the real option and default sensibly
    endlessModeOptions =
      enabled: true
    postLoadContinuation endlessModeOptions

$().ready ->
  loadOptions applyEndlessModeOptions