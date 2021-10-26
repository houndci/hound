import React, { useContext } from 'react';

import { ReposContext } from '../../providers/ReposProvider';

const SearchAction = () => {
  const { setSearchTerm } = useContext(ReposContext);

  return (
    <div className="repo-tools-search">
      <input
        className="repo-search-tools-input"
        placeholder={Hound.settings.searchPlaceholder}
        type="text"
        onChange={(event) => setSearchTerm(event.target.value)}
      />
    </div>
  );
};

export default SearchAction;
