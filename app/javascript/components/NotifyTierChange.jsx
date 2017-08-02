/*jshint esversion: 6 */

import React from 'react';

import App from './NotifyTierChange/components/App';

export default class NotifyTierChange extends React.Component {
  render() {
    return(
      <App {...this.props} />
    );
  }
}

