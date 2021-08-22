import React from 'react';
global.React = React;

import _ from 'lodash';
global._ = _;

import classNames from 'classnames';
global.classNames = classNames;

import sinon from 'sinon';
global.sinon = sinon;

/* eslint-disable-next-line no-unused-vars */
const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "placeholder"
  }
};

// Make Enzyme functions available in all test files without importing
import Enzyme, { shallow, render, mount } from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';

Enzyme.configure({ adapter: new Adapter() });

global.shallow = shallow;
global.render = render;
global.mount = mount;

// Define window alert because jsdom no longer defines it
window.alert = _.noop;
