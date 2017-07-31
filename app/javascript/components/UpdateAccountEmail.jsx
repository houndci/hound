/*jshint esversion: 6 */

import React from 'react'
import ReactAddonsUpdate from 'react-addons-update'

import App from './UpdateAccountEmail/components/App'

export default class UpdateAccountEmail extends React.Component {
  render() {
    return(
      <App {...this.props} />
    )
  }
}

