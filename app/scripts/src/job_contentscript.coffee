'use strict'

filteringMode = 'disabled'

getInadequateRatingCountStyle = ->
  {
    'disabled': 'doNothingForInadequateRatingCount'
    'dim': 'dimForInadequateRatingCount'
    'hidden': 'hideForInadequateRatingCount'
  }[filteringMode]

updatePagingControlLinks = (minRatingCount) ->
  $('.pagingControls').find('a[href]').each (_, pagingControlLink) ->
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

dimResultsWithFewerRatingsThan = (minRatings) ->
  $('.jobScopeWrapper').each (_, jobScopeWrapper) ->
    ratingCount = getJobScopeWrapperRatingCount $(jobScopeWrapper)
    shouldBeDim = ratingCount < minRatings;
    setJobScopeWrapperDimness $(jobScopeWrapper), shouldBeDim

updateMinRatingCount = ->
  rawNewMinRatingCount = $('#minRatingCountInput').val();
  unless $.isNumeric(rawNewMinRatingCount)
    console.log "Ignoring non-numeric minRatingCount: #{newMinRatingCount}"
    return

  newMinRatingCount = Number rawNewMinRatingCount
  console.log "Applying new minRatingCount: #{newMinRatingCount}"
  console.log "Dimming filtered results"
  dimResultsWithFewerRatingsThan newMinRatingCount
  console.log "Updating paging control links"
  updatePagingControlLinks newMinRatingCount

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