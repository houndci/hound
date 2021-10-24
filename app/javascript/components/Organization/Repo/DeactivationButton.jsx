import React, { useState } from 'react';

import { deactivateRepo, deleteSubscription } from '../../../modules/api';

const DeactivationButton = ({ repo, setRepo }) => {
  const { admin, id } = repo;
  const [isProcessing, setProcessing] = useState(false);
  const [buttonText, setButtonText] = useState("Active");
  const onMouseOver = () => setButtonText("Deactivate");
  const onMouseOut = () => setButtonText("Active");

  if (admin) {
    return (
      <button
        className="repo-toggle"
        disabled={isProcessing}
        onClick={() => onClick({ repo, setProcessing, setRepo })}
        onMouseOut={onMouseOut}
        onMouseOver={onMouseOver}
      >
        {buttonText}
      </button>
    );
  } else {
    return (
      <div className="repo-restricted">
        Only repo admins can activate
      </div>
    );
  }
}

const onClick = ({ repo, setProcessing, setRepo }) => {
  const deactivate = repo.stripe_subscription_id ?
    deleteSubscription :
    deactivateRepo;

  setProcessing(true);
  deactivate(repo)
    .then(() => {
      const updatedRepo = {
        ...repo,
        active: false,
        stripe_subscription_id: null,
      };
      setProcessing(false);
      setRepo(updatedRepo);
    })
    .catch(() => {
      setProcessing(false);
      alert('Your repo could not be disabled.');
    });
}

export default DeactivationButton;
