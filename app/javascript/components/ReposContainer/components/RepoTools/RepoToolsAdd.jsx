import React from 'react';

const RepoToolsAdd = (props) => (
  <div className="repo-tools-add">
    <a
      className="button repo-tools-add-button"
      href={`https://github.com/apps/${props.appName}/installations/new`}
    >
      Add GitHub repos
    </a>
  </div>
);

export default RepoToolsAdd;
