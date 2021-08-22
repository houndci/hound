import React from 'react';

import Repo from './Repo';

const Repos = ({ repos, searchTerm }) => {
  const isDisplayed = (repo) => {
    if (searchTerm === null) {
      return true;
    } else {
      const repoName = repo.name.toLowerCase();
      return repoName.indexOf(searchTerm.toLowerCase()) !== -1;
    }
  };
  const displayedRepos = repos.filter(isDisplayed);

  return (
    <ul className="repos">
      {displayedRepos.map((repo) => <Repo repo={repo} key={repo.id} />)}
    </ul>
  );
}

export default Repos;
