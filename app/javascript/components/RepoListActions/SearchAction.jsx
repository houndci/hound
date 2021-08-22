import React from 'react';

const SearchAction = ({ setSearchTerm }) => (
  <div className="repo-tools-search">
    <input
      className="repo-search-tools-input"
      placeholder={Hound.settings.searchPlaceholder}
      type="text"
      onChange={(event) => setSearchTerm(event.target.value)}
    />
  </div>
);

export default SearchAction;
