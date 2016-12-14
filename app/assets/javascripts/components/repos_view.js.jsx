import ReposSyncSpinner from './repos_sync_spinner.js';
import OrganizationsList from './organizations_list.js';

class ReposView extends React.Component {
  render() {
    const {
      isSyncing,
      organizations,
      repos,
      filterTerm,
      onRepoClicked,
      isProcessingId
    } = this.props;

    if (isSyncing) {
      return (
        <ReposSyncSpinner/>
      );
    } else {
      return (
        <OrganizationsList
          organizations={organizations}
          repos={repos}
          filterTerm={filterTerm}
          onRepoClicked={onRepoClicked}
          isProcessingId={isProcessingId}
        />
      );
    }
  }
}

module.exports = ReposView;
