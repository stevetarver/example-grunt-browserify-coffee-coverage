# Simple, testable functionality
_ = require 'underscore'


Util =
  # Use underscore to eliminate duplicates
  uniqueValues: (array) ->
    _.uniq(array)


module.exports = Util