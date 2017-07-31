/*jshint esversion: 6 */

import React from 'react'
global.React = React

import _ from 'lodash'
global._ = _

import $ from 'jquery'
global.$ = $

import classNames from 'classnames'
global.classNames = classNames

import sinon from 'sinon'
global.sinon = sinon

const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "placeholder"
  }
}

// Make Enzyme functions available in all test files without importing
import { shallow, render, mount } from 'enzyme'
global.shallow = shallow
global.render = render
global.mount = mount

// Skip createElement warnings but fail tests on any other warning
console.error = message => {
  if (!/(React.createElement: type should not be null)/.test(message)) {
    throw new Error(message)
  }
}
