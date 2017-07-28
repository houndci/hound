import React from 'react'

export default class ReposSyncSpinner extends React.Component {
  render() {
    return (
      <div className="repos-syncing">
        <div className="dot"></div>
        <div className="dot"></div>
        <div className="dot"></div>
      </div>
    );
  }
}
