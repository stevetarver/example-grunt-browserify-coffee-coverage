uniqueValues = require('../../scripts/util.coffee').uniqueValues

describe 'Base Collection', ->

  testData = [
    (descr: 'numbers',                   value: [1,3,4,1,2,3],         expected: [1,3,4,2])
    (descr: 'strings',                   value: ['foo', 'bar', 'foo'], expected: ['foo', 'bar'])
    (descr: 'mixed numbers and strings', value: ['foo', 1, 'foo', 1],  expected: ['foo', 1])
  ]

  testData.forEach (item) ->
    it "should return unique values with an array of #{item.descr}", ->
      uniqueValues(item.value).should.eql(item.expected)

