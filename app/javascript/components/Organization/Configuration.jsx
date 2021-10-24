import React, { useState } from 'react';
import classNames from 'classnames';

import { updateOwner } from '../../modules/api';

const Configuration = ({ orgId, enabled, repos, repo }) => {
  const switchId = `toggle-config-${orgId}`;
  const [configEnabled, setConfigEnabled] = useState(enabled);
  const [selectedRepo, setSelectedRepo] = useState(repo || '');
  const toggle = (event) => {
    const isEnabled = !configEnabled;
    const params = { config_enabled: isEnabled };

    setConfigEnabled(isEnabled);
    updateOwner(orgId, params);
  };

  return (
    <div className="organization-header-config">
      <div className="organization-header-toggle">
        <span className="organization-header-label">
          Use org-wide config
        </span>

        <input
          id={switchId}
          checked={configEnabled}
          className="organization-header-toggle-input"
          onChange={toggle}
          type="checkbox"
          name="toggle"
        />
        <label className="toggle-switch" htmlFor={switchId} />
      </div>

      {configEnabled &&
        <RepoSelect
          orgId={orgId}
          repos={repos}
          repo={selectedRepo}
          setRepo={setSelectedRepo} />}
    </div>
  );
};

const RepoSelect = ({ orgId, repos, repo, setRepo }) => {
  const [configUpdated, setConfigUpdated] = useState(false);
  const updateRepo = (event) => {
    const newRepo = event && event.target.value;
    const params = { config_repo: newRepo };

    setRepo(newRepo);
    setConfigUpdated(false);
    updateOwner(orgId, params).then(() => setConfigUpdated(true));
  };

  return (
    <div className="organization-header-source">
      <span className="organization-header-label">Use .hound.yml from</span>
      <select
        className="organization-header-select"
        onChange={updateRepo}
        value={repo}
      >
        <RepoOptions repos={repos} selectedRepo={repo} />
      </select>
      <div className="inline-flash--success config-enabled">
        {configUpdated && <span data-role="config-saved">&#10004;</span>}
      </div>
    </div>
  );
};

const RepoOptions = ({ repos, selectedRepo }) => {
  let repoNames = repos.map(({ name }) => name);

  if (!repoNames.includes(selectedRepo)) {
    repoNames = [selectedRepo, ...repoNames];
  }

  return (
    <>
      {repoNames.map((name) =>
        <option key={name} value={name}>{name}</option>
      )}
    </>
  );
};

export default Configuration;
