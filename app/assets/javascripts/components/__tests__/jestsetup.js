import React from 'react';
import renderer from 'react-test-renderer';
import _ from 'lodash';

global.React = React;
global.renderer = renderer;
global._ = _;

const Hound = window.Hound = global.Hound = {
  settings: {
    placeholder: "meh"
  }
};


// Make Enzyme functions available in all test files without importing
import { shallow, render, mount } from 'enzyme';
global.shallow = shallow;
global.render = render;
global.mount = mount;

// Skip createElement warnings but fail tests on any other warning
console.error = message => {
    if (!/(React.createElement: type should not be null)/.test(message)) {
        throw new Error(message);
    }
};
