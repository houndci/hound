import React, { useState } from 'react';

import { activateRepo, createSubscription } from '../../../modules/api';

const ActivationButton = ({ repo, setRepo }) => {
  const { admin, id } = repo;
  const [isProcessing, setProcessing] = useState(false);

  if (admin) {
    return (
      <button
        className="repo-toggle"
        onClick={() => onClick({ repo, setProcessing, setRepo })}
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

const onClick = ({ repo, setProcessing, setRepo}) => {
  const activateRepo = repo.private ? activatePrivateRepo : activatePublicRepo;

  setProcessing(true);
  activateRepo(repo)
    .then((repo) => {
      setProcessing(false);
      setRepo(repo);
    });
};

const activatePrivateRepo = (repo) => {
  return createSubscription(repo.id)
    .then((resp) => {
      const updatedRepo = {
        ...repo,
        active: true,
        stripe_subscription_id: resp.stripe_subscription_id,
      };
      trackRepoActivation(updatedRepo);
      return updatedRepo;
    })
    .catch((error) => onSubscriptionError(repo, error));
};

const activatePublicRepo = (repo) => {
  return activateRepo(repo)
    .then((resp) => {
      const updatedRepo = { ...repo, active: true };
      trackRepoActivation(updatedRepo);
      return updatedRepo;
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
