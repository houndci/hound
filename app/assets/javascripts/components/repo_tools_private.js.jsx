class RepoToolsPrivate extends React.Component {
  render() {
    const { onPrivateClicked } = this.props;

    return (
      <div className="repo-tools-private">
        <form className="button_to" method="post" action="/auth/github?access=full">
          <button
            className="repo-tools-private-button"
            type="submit"
            onClick={onPrivateClicked}
          >
            <span>Include private repos</span>
          </button>
        </form>
      </div>
    );
  }
}
