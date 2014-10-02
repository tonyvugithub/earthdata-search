//= require typeahead-0.10.2/typeahead.bundle

do ($=jQuery, currentPage = window.edsc.models.page.current) ->

  $(document).ready ->
    $placenameInputs = $('.autocomplete-placenames')

    engine = new Bloodhound
      name: 'placenames'
      local: []
      remote: '/placenames?q=%QUERY'
      datumTokenizer: -> Bloodhound.tokenizers.whitespace(d.val)
      queryTokenizer: Bloodhound.tokenizers.whitespace

    engine.initialize()

    uiOpts =
      hint: true
      highlight: true
      minLength: 1
    dsOpts =
      name: 'keywords'
      source: engine.ttAdapter()
    $placenameInputs.typeahead(uiOpts, dsOpts)

    currentSpatial = null

    # When the user selects a typeahead value,
    # TODO: Upgrade to typeahead-0.10 when available and verify that typeahead:cursorchanged triggers with arrow keys
    $placenameInputs.on 'typeahead:autocompleted typeahead:selected', (event, datum) ->
      {placename, spatial, value} = datum
      currentPage.query.keywords(value)

      currentPage.query.placename(null)
      currentPage.query.spatial(spatial)
      currentPage.query.placename(placename)
      currentSpatial = spatial

      points = spatial.split(':')
      if points[0] == 'point'
        p1 = points[1].split(',').reverse()
        p2 = p1
      else if points[0] == 'bounding_box'
        p1 = points[1].split(',').reverse()
        p2 = points[2].split(',').reverse()
      $('#map').data('map').map.fitBounds([p1,p2])

    $('.autocomplete-placenames').on 'keyup', ->
      newValue = $(this).typeahead('val')
      query = currentPage.query
      currentValue = query.keywords()
      unless newValue == currentValue
        query.keywords(newValue)
        placename = query.placename()
        if placename? && newValue.indexOf(placename) == -1
          query.placename(null)
          query.spatial(null)

    readKeywords = (newValue) ->
      $keywords = $('#keywords')
      currentValue = $keywords.typeahead('val')
      unless newValue == currentValue
        $keywords.typeahead('val', newValue ? "")

    readSpatial = (newValue) ->
      currentPlacename = currentPage.query.placename.peek()
      for input in $('.autocomplete-placenames')
        if input.value.indexOf(currentPlacename) != -1 && currentSpatial != null && newValue != currentSpatial
          currentKeywords = currentPage.query.keywords.peek()
          currentPage.query.keywords(currentKeywords.replace(currentPlacename, ''))
          currentPage.query.placename('')
        else if currentSpatial == null
          currentSpatial = newValue

    readKeywords(currentPage.query.keywords())
    readSpatial(currentPage.query.spatial())

    currentPage.query.keywords.subscribe readKeywords
    currentPage.query.spatial.subscribe readSpatial
