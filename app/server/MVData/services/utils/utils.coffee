"use strict"

###*
 * Decrements a long number as a string
 * @param  {String}  number  the long number to decrement
 * @param  {Number=} amount  amount te decrement by
 * @return {String}          the new string number
###
exports.decrement = (number, amount = 1) ->
    String(number).slice(0, -10) + String(+number.slice(-10) - amount)

###*
 * Increments a long number as a string
 * @param  {String}  number  the long number to increment
 * @param  {Number=} amount  amount te increment by
 * @return {String}          the new string number
###
exports.increment = (number, amount = 1) ->
    String(number).slice(0, -10) + String(+number.slice(-10) + amount)