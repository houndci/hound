class RepoTools extends React.Component {
  render() {
    const {
      onSearchInput,
      showPrivateButton,
      isSyncing,
      onRefreshClicked,
    } = this.props;

    return (
      <div className="repo-tools">
        <RepoToolsSearch onSearchInput={(evt) => onSearchInput(evt)} />
        { showPrivateButton ? <RepoToolsPrivate /> : null }
        <RepoToolsRefresh
          isSyncing={isSyncing}
          onRefreshClicked={onRefreshClicked}
        />
      </div>
    );
  }
}
