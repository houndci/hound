import React, { useState } from 'react';

const ActivationButton = ({ repo }) => {
  const { admin, id } = repo;
  const [isProcessing, setProcessing] = useState(false);

  if (admin) {
    return (
      <button
        className="repo-toggle"
        onClick={() => onClick(repo, setProcessing)}
        disabled={isProcessing}
      >
        Activate
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

  if (repo.private) {
    activatePrivateRepo(repo).finally(() => setProcessing(false));
  } else {
    activatePublicRepo(repo).finally(() => setProcessing(false));
  }
};

const activatePrivateRepo = (repo) => {
  return Ajax.createSubscription({ repo_id: repo.id })
    .then((resp) => {
      repo.active = true;
      repo.stripe_subscription_id = resp.stripe_subscription_id;
      trackRepoActivation(repo);
      // commitRepoToState(repo);
    })
    .catch((error) => onSubscriptionError(repo, error))
};

const activatePublicRepo = (repo) => {
  return Ajax.activateRepo(repo)
    .then((resp) => {
      repo.active = true;
      trackRepoActivation(repo);
      // commitRepoToState(repo);
    })
    .catch(handleError);
};

const onSubscriptionError = (repo, error) => {
  if (error.status === 402) {
    document.location.href = `/plans?repo_id=${repo.id}`;
  } else {
    handleError();
  }
};

const handleError = () => {
  if (window.Intercom) {
    window.Intercom("showNewMessage", "I can't activate my repo. Please help!");
  } else {
    alert("Oh no, activating a repo failed. Please contact us!");
  }
}

const trackRepoActivation = (repo) => {
  const eventName = repo.private ? "Private Repo Activated" : "Public Repo Activated";

  window.analytics.track(eventName, { properties: { name: repo.name } });
};

export default ActivationButton;
