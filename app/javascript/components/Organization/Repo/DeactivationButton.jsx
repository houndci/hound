import React, { useState } from 'react';

const DeactivationButton = ({ repo }) => {
  const { admin, id } = repo;
  const [isProcessing, setProcessing] = useState(false);
  const [buttonText, setButtonText] = useState("Active");
  const onMouseOver = () => setButtonText("Deactivate");
  const onMouseOut = () => setButtonText("Activate");

  if (admin) {
    return (
      <button
        className="repo-toggle"
        disabled={isProcessing}
        onClick={() => onClick(repo, setProcessing)}
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

const onClick = (repo, setProcessing) => {
  setProcessing(true);

  if (repo.stripe_subscription_id) {
    deactivateSubscribedRepo(repo).finally(() => setProcessing(false));
  } else {
    deactivateUnsubscribedRepo(repo).finally(() => setProcessing(false));
  }
}

const deactivateSubscribedRepo = (repo) => {
  return Ajax.deleteSubscription(repo)
    .then(() => {
      repo.active = false;
      repo.stripe_subscription_id = null;
      // commitRepoToState(repo);
    }).catch(() => {
      alert("Your repo could not be disabled.");
    });
}

const deactivateUnsubscribedRepo = (repo) => {
  return Ajax.deactivateRepo(repo)
    .then(() => {
      repo.active = false;
      // commitRepoToState(repo);
    }).catch(() => {
      alert("Your repo could not be disabled.");
    });
}

export default DeactivationButton;
