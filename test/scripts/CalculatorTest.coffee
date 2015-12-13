{Calculator} = require './Calculator'

calculator = undefined

describe 'Calculator', ->
  beforeEach ->
    calculator = new Calculator

  it 'should add correctly', ->
    expect(calculator.add 1, 2)
      .toEqual 3
