import React, { useEffect, useContext } from 'react';

import { fetchRepos, fetchUser, createSync } from '../../modules/api';
import { ReposContext } from '../../providers/ReposProvider';

let pollInterval;

const RefreshAction = () => {
  const { syncingButtonText, syncNowButtonText } = Hound.settings;
  const { repos, setRepos, isSyncing, setIsSyncing } = useContext(ReposContext);
  const buttonText = isSyncing ? syncingButtonText : syncNowButtonText;
  const getRepos = () => fetchRepos().then((repos) => {
    setRepos(repos);
    setIsSyncing(false);
    return repos;
  });

  useEffect(() => {
    setIsSyncing(true);
    getRepos().then((repos) => {
      if (repos.length === 0) {
        syncRepos({ setIsSyncing, getRepos });
      }
    })
    .catch(() => {
      setIsSyncing(false);
      alert('Your repos failed to load.');
    });
  }, []);

  return (
    <div className="repo-tools-refresh">
      <button
        className="repo-tools-refresh-button"
        disabled={isSyncing ? "disabled" : null}
        onClick={() => syncRepos({ setIsSyncing, getRepos })}
      >
        <span>{buttonText}</span>
      </button>
    </div>
  );
};


const syncRepos = ({ setIsSyncing, getRepos }) => {
  setIsSyncing(true);

  createSync()
    .then(() => {
      return new Promise((resolve) => {
        pollInterval = setInterval(() => pollSync(resolve), 1000);
      });
    })
    .then(() => {
      clearInterval(pollInterval);
      getRepos();
    })
    .catch((err) => {
      setIsSyncing(false);
      alert('Your repos failed to sync.');
    });
}

const pollSync = (resolve) => {
  fetchUser().then((user) => {
    if (!user.refreshing_repos) {
      resolve();
    }
  });
}

export default RefreshAction;
