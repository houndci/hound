class RepoTools extends React.Component {
  render() {
    const {
      onSearchInput,
      showPrivateButton,
      isSyncing,
      onRefreshClicked,
    } = this.props;

    if (showPrivateButton) {
      var privateButton = <RepoToolsPrivate />;
    } else {
      var privateButton = null;
    }

    return (
      <div className="repo-tools">
        <RepoToolsSearch onSearchInput={(event) => onSearchInput(event)} />
        {privateButton}
        <RepoToolsRefresh
          isSyncing={isSyncing}
          onRefreshClicked={onRefreshClicked}
        />
      </div>
    );
  }
}
