import React from 'react';

const AddAction = ({ appName }) => (
  <div className="repo-tools-add">
    <a
      className="button repo-tools-add-button"
      href={`https://github.com/apps/${appName}/installations/new`}
    >
      Add GitHub repos
    </a>
  </div>
);

export default AddAction;
