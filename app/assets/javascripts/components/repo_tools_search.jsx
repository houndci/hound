import React from 'react';

class RepoToolsSearch extends React.Component {
  render() {
    return (
      <div className="repo-tools-search">
        <input
          className="repo-search-tools-input"
          placeholder={Hound.settings.searchPlaceholder}
          type="text"
          onChange={(event) => this.props.onSearchInput(event.target.value)}
        />
      </div>
    );
  }
}

module.exports = RepoToolsSearch;
