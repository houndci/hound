import React from 'react';
import classNames from 'classnames';

import ActivationButton from './ActivationButton';
import DeactivationButton from './DeactivationButton';

const Repo = ({ repo }) => {
  const { active, name } = repo;

  return (
    <li className={classNames("repo", {"repo--active": active})}>
      <div className="repo-name">{name}</div>

      {repo.private && <span className="badge margin-left-small">Private</span>}

      <div className="repo-activation-toggle">
        <Button repo={repo}/>
      </div>
    </li>
  );
}

const Button = ({ repo }) => {
  if (repo.active) {
    return <DeactivationButton repo={repo} />
  } else {
    return <ActivationButton repo={repo} />;
  }
}

export default Repo;
