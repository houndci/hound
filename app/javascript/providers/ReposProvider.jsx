import React, { useState } from 'react';

const ReposContext = React.createContext({});

const ReposProvider = ({ children }) => {
  const [isSyncing, setIsSyncing] = useState(true);
  const [repos, setRepos] = useState([]);
  const [searchTerm, setSearchTerm] = useState(null);
  const providerValue = {
    repos,
    setRepos,
    isSyncing,
    setIsSyncing,
    searchTerm,
    setSearchTerm,
  };

  return (
    <ReposContext.Provider value={providerValue}>
      {children}
    </ReposContext.Provider>
  );
};

export {
  ReposProvider,
  ReposContext,
};
