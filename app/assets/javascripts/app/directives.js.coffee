app = angular.module('myApp.directives', [])
app.directive 'hasAnswer', ->
  return {
    restrict: 'AE',
    controller: ($scope, AnswerHelper) ->
      $scope.clearOtherChoices = (question, choice, currentAnswer)->
        angular.forEach question.choices, (c, index) ->
          if c.text != choice.text
            c.currentAnswer.value = null
            c.currentAnswer.other = null
          else
            currentAnswer.value = choice.text

    link: (scope, element, attrs) ->
  }

app.directive 'autosave', ($timeout, ResponseService) ->
  return {
    restrict: 'A',
    link: (scope, element, attrs) ->
      saveUpdates = ->
        ResponseService.saveResponse(scope.response)

      timeoutPromise = null
      debounceSave = (newVal, oldVal) ->
        # console.log "debounceSave", newVal, oldVal
        if newVal != oldVal
          if (timeoutPromise)
            $timeout.cancel(timeoutPromise)
          timeoutPromise = $timeout(saveUpdates, 500)

      dummySave = -> console.log "dummy save"

      scope.$watch((-> JSON.stringify(scope.response?.answer_bucket)), debounceSave)
  }

app.directive 'checkableInput', ->
  return {
    restrict: 'A'
    scope:
      choice: '='
    link: (scope, element, attrs) ->
      # using jQuery coz element.find doesn't work
      if scope.choice?.allow_text
        $e = $(element)
        # focus on text box --> ticking the radio/checkbox
        $e.on 'focus', ':text', ->
          $(element).find(':radio, :checkbox').prop('checked', true)

        # uncheck checkbox --> clear text box
        $e.find(':checkbox').on 'change', ->
          unless $(@).is(':checked')
            scope.choice.currentAnswer.other = null

        # click on siblings --> clear text box
        $e.siblings().find(':radio').on 'change', ->
          if $(@).is(':checked')
            scope.choice.currentAnswer.other = null


  }
