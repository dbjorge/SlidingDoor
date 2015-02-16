'use strict'

findNextUrl = ->
  $('.pagingControls').last()
    .find('.next')
    .find('a')
    .uri()

sanitizeJobListings = (jobListings) ->
  jobListings.find('.searchFeedbackRequest').remove()
  jobListings.find('.jobAlertForm').remove()
  jobListings.find('.jobAlertConfirmWrapper').remove()
  # loadNextPage uses this to figure out what to load, so hide instead of remove
  jobListings.find('.pagingControls').css('display', 'none')
  return jobListings

# Normally Glassdoor does this step on its own, but we're circumventing the JS
# that would normally do so by loading new listings in isolation, so we have to
# do this ourselves.
lazyLoadImages = (rootElement) ->
  imagesToLoad = $(rootElement).find('img.lazy')
  for rawImage in imagesToLoad
    image = $(rawImage)
    image.attr('src', image.attr('data-original'))
    image.removeClass('lazy')

# Happens before injection into page
preProcessJobListings = (jobListings) ->
  sanitizeJobListings jobListings

# Happens after injection into page
postProcessJobListings = (jobListings) ->
  lazyLoadImages jobListings
  chrome.runtime.sendMessage
    'action': 'jobListingsInjection'
    'slidingDoorInjectionId': jobListings.data('slidingDoorInjectionId')

loading = false
pageLoadCount = 1
loadNextPage = ->
  if loading
    console.log "SlidingDoor Endless Mode: Skipping load request, already loading"
  else
    console.log "SlidingDoor Endless Mode: Loading next page's contents..."
    loading = true
    nextUrl = findNextUrl()
    $.get nextUrl, (nextPageContent) ->
      console.log "SlidingDoor Endless Mode: Retrieved next page's contents. Injecting..."

      pageLoadCount++
      nextPageJobListings = $(nextPageContent).find('.jobListings')
      nextPageJobListings.addClass('slidingDoorInjected')
      nextPageJobListings.attr('data-slidingDoorInjectionId', pageLoadCount)
      preProcessJobListings nextPageJobListings

      currentPageJobListings = $('.jobListings').last()
      currentPageJobListings.after nextPageJobListings
      loading = false

      console.log "SlidingDoor Endless Mode: Injected, post-processing..."
      injectedListings = $('.jobListings').last()
      postProcessJobListings injectedListings

patchInLoaderElement = ->
  loadingAnimationSource = """
    <div>
      <image
        src="#{chrome.extension.getURL('images/ajax-loader.gif')}"
        id="slidingDoorEndlessModeLoadingAnimation"
        style="display: block; margin-left: auto; margin-right: auto"
        data-appear-top-offset="600"
        />
    </div>
    """

  $('.jobListings').last().after loadingAnimationSource
  $('#slidingDoorEndlessModeLoadingAnimation').appear()
  $('#slidingDoorEndlessModeLoadingAnimation').on 'appear', loadNextPage

enableEndlessMode = ->
  # TODO: Separate sanitization into a separate, optional contentscript
  sanitizeJobListings $('.jobListings')
  patchInLoaderElement()

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