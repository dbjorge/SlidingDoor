'use strict'

filteringMode = 'disabled'
currentMinRatingCount = 0

getInadequateRatingCountStyle = ->
  {
    'disabled': 'doNothingForInadequateRatingCount'
    'dim': 'dimForInadequateRatingCount'
    'hidden': 'hideForInadequateRatingCount'
  }[filteringMode]

updatePagingControlLinks = (rootSelector, minRatingCount) ->
  $(rootSelector).find('.pagingControls').find('a[href]').each (_, pagingControlLink) ->
    $(pagingControlLink).uri().setSearch('minRatingCount', minRatingCount)

stringEndsWithPlus = (s) -> /[+]$/.test s

sanitizeRatingCount = (ratingCountText) ->
  if stringEndsWithPlus ratingCountText
    Infinity
  else
    Number ratingCountText

getJobScopeWrapperRatingCount = (jobScopeWrapper) ->
  rawRatingCountText =
    jobScopeWrapper
      .find('.jobListingCompanyRating')
      .find('tt.notranslate')
      .text()
  sanitizeRatingCount rawRatingCountText

setJobScopeWrapperDimness = (jobScopeWrapper, shouldBeDim) ->
  jobScopeWrapper.toggleClass getInadequateRatingCountStyle(), shouldBeDim

dimResultsWithFewerRatingsThan = (rootSelector, minRatings) ->
  $(rootSelector).find('.jobScopeWrapper').each (_, jobScopeWrapper) ->
    ratingCount = getJobScopeWrapperRatingCount $(jobScopeWrapper)
    shouldBeDim = ratingCount < minRatings;
    setJobScopeWrapperDimness $(jobScopeWrapper), shouldBeDim

applyMinRatingCount = (rootSelector) ->
  console.log "Dimming filtered results"
  dimResultsWithFewerRatingsThan rootSelector, currentMinRatingCount
  console.log "Updating paging control links"
  updatePagingControlLinks rootSelector, currentMinRatingCount

updateMinRatingCount = ->
  rawNewMinRatingCount = $('#minRatingCountInput').val();
  if $.isNumeric(rawNewMinRatingCount)
    currentMinRatingCount = Number rawNewMinRatingCount
    applyMinRatingCount $('.jobListings')
  else
    console.log "Ignoring non-numeric minRatingCount: '#{rawNewMinRatingCount}'"

patchJobsPageWithMinRatingCountFilter = ->
  employerMinRatingCountSelectorSource = '''
    <div id="EmployerMinRatingCountSelector" class="jobFilter">
      <p class="filterTitle"> Minimum ratings: </p>
      <input type="text" name="minRatingCount" id="minRatingCountInput" type="number"/>
    </div>
    '''

  $('#JobFreshness').after employerMinRatingCountSelectorSource
  $('#minRatingCountInput').on 'input', updateMinRatingCount

initializeMinRatingCountFilterFromGetParameters = ->
  minRatingCountGetParameter = URI(window.location.href).search(true)['minRatingCount']
  if minRatingCountGetParameter != null
    console.log "Applying minRatingCount from GET parameters: #{minRatingCountGetParameter}"
    $('#minRatingCountInput').val(minRatingCountGetParameter)
    updateMinRatingCount()

startListeningForJobListingInjections = ->
  $('.jobListings').livequery () ->
    console.log('jobListings element added')
    applyMinRatingCount $(this)

loadSettings = (postLoadContinuation) ->
  chrome.storage.sync.get 'options', (options) ->
    # FIXME: Support the real option and default sensibly
    #filteringMode = options.jobResults.filteringMode
    filteringMode = 'hidden'
    postLoadContinuation()

$().ready ->
  loadSettings ->
    patchJobsPageWithMinRatingCountFilter()
    initializeMinRatingCountFilterFromGetParameters()
    startListeningForJobListingInjections()