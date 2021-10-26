import React, { useState, useContext } from 'react';
import classNames from 'classnames';

import { ReposContext } from '../../../providers/ReposProvider';
import ActivationButton from './ActivationButton';
import DeactivationButton from './DeactivationButton';

const Repo = ({ repo: passedRepo }) => {
  const [repo, setRepo] = useState(passedRepo);
  const { active, name } = repo;

  return (
    <li className={classNames('repo', { 'repo--active': active })}>
      <div className="repo-name">{name}</div>

      {repo.private && <span className="badge margin-left-small">Private</span>}

      <div className="repo-activation-toggle">
        <Button repo={repo} setRepo={setRepo} />
      </div>
    </li>
  );
}

const Button = (props) => {
  if (props.repo.active) {
    return <DeactivationButton {...props} />
  } else {
    return <ActivationButton {...props} />;
  }
}

export default Repo;
