class ReposContainer extends React.Component {
  state = {
    isSyncing: false,
    isProcessingId: null,
    filterTerm: null,
    repos: [],
    organizations: [],
    userHasCard: this.props.userHasCard
  }

  fetchReposAndOrgs() {
    $.ajax({
      url: "/repos.json",
      type: "GET",
      dataType: "json",
      success: this.onFetchReposAndOrgsSuccess.bind(this),
      error: () => {
        alert("Your repos failed to load.");
      }
    });
  }

  onFetchReposAndOrgsSuccess(data) {
    if (data.length === 0) {
      this.onRefreshClicked();
    } else {
      this.setState({repos: data});

      organizations = data.map( repo => {
        return (repo.owner || {
          name: this.orgName(repo.name)
        });
      });
      this.setState({
        organizations: _.uniqWith(organizations, _.isEqual)
      });

      this.setState({isSyncing: false});
    }
  }

  orgName(name) {
    return _.split(name, "/")[0];
  }

  componentWillMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": this.props.authenticity_token
      }
    });
    this.setState({isSyncing: true});
    this.fetchReposAndOrgs();
  }

  createSubscription(subscriptionOptions) {
    return $.ajax({
      url: `/repos/${subscriptionOptions.repo_id}/subscription.json`,
      type: "POST",
      data: subscriptionOptions,
      dataType: "json"
    });
  }

  deleteSubscription(repo) {
    return $.ajax({
      url: `/repos/${repo.id}/subscription`,
      type: "DELETE",
      dataType: "json"
    });
  }

  deactivateRepo(repo) {
    return $.ajax({
      url: `/repos/${repo.id}/deactivation`,
      type: "POST",
      dataType: "text"
    });
  }

  activateRepo(repo) {
    return $.ajax({
      url: `/repos/${repo.id}/activation`,
      type: "POST",
      dataType: "text"
    });
  }

  commitRepoToState(repo) {
    const repoIdx = _.findIndex(this.state.repos, {id: repo.id});

    const newRepos = React.addons.update(
      this.state.repos, {
        [repoIdx]: {$set: repo}
      }
    );
    this.setState({repos: newRepos});
  }

  deactivateSubscribedRepo(repo) {
    this.deleteSubscription(repo).then( () => {
      repo.active = false;
      repo.stripe_subscription_id = null;
      this.commitRepoToState(repo);
      this.updateSubscribedRepoCount();
    }).catch( () => {
      alert("Your repo could not be disabled.");
    });
  }

  deactivateUnsubscribedRepo(repo) {
    this.deactivateRepo(repo).then( () => {
      repo.active = false;
      this.commitRepoToState(repo);
    }).catch( () => {
      alert("Your repo could not be disabled.");
    });
  }

  activatePaidRepo(repo) {
    if (this.state.userHasCard) {
      this.createSubscriptionWithExistingCard(repo);
    } else {
      this.showCreditCardForm(
        repo,
        (token) => this.createSubscriptionWithNewCard(repo, token)
      );
    }
  }

  updateSubscribedRepoCount() {
    this.getUser().then(user => {
      const subscribedRepoCount = user.subscribed_repo_count;
      const tierAllowance = user.tier_allowance;

      if (subscribedRepoCount === 0) {
        $("[data-role='allowance-container']").remove();
      } else if (subscribedRepoCount === 1 && $(".allowance").length === 0) {
        ReactDOM.render(
          <RepoAllowance
            subscribedRepoCount={subscribedRepoCount}
            tierAllowance={tierAllowance}
          />,
          $("[data-role='account-actions']")
            .prepend("<li data-role='allowance-container'></li>")
            .children()[0]
        );
      } else {
        $("[data-role='subscribed-repo-count']").text(subscribedRepoCount);
        $("[data-role='tier-allowance']").text(tierAllowance);
      }
    });
  }

  activateAndTrackRepoSubscription(repo, stripeSubscriptionId) {
    repo.active = true;
    repo.stripe_subscription_id = stripeSubscriptionId;
    this.trackRepoActivated(repo);
    this.commitRepoToState(repo);
    this.updateSubscribedRepoCount();
  }

  onSubscriptionError(repo, error) {
    if (error.status === 402) {
      document.location.href = `/pricings?repo_id=${repo.id}`;
    } else {
      alert("Your subscription could not be activated.");
    }
  }

  createSubscriptionWithExistingCard(repo) {
    this.createSubscription({
      repo_id: repo.id
    }).then( resp => {
      this.activateAndTrackRepoSubscription(
        repo, resp.stripe_subscription_id
      );
    }).catch(error => this.onSubscriptionError(repo, error));
  }

  createSubscriptionWithNewCard(repo, stripeToken) {
    this.createSubscription({
      repo_id: repo.id,
      card_token: stripeToken.id,
      email_address: stripeToken.email
    }).then( resp => {
      this.activateAndTrackRepoSubscription(
        repo, resp.stripe_subscription_id
      );
    }).then( () => {
      this.setState({ userHasCard: true });
    }).catch(error => this.onSubscriptionError(repo, error));
  }

  activateFreeRepo(repo) {
    this.activateRepo(
      repo
    ).then( resp => {
      repo.active = true;
      this.trackRepoActivated(repo);
      this.commitRepoToState(repo);
    }).catch( () => {
      alert("Your repo could not be enabled.");
    });
  }

  onRepoClicked(id) {
    this.setState({isProcessingId: id});
    const repo = _.find(this.state.repos, {id: id});

    if (repo.active) {
      if (repo.stripe_subscription_id) {
        this.deactivateSubscribedRepo(repo);
      } else {
        this.deactivateUnsubscribedRepo(repo);
      }
    } else {
      if (repo.price_in_dollars > 0) {
        this.activatePaidRepo(repo);
      } else {
        this.activateFreeRepo(repo);
      }
    }

    this.setState({isProcessingId: null});
  }

  showCreditCardForm(options, successCallback) {
    StripeCheckout.configure({
      key: Hound.settings.stripePublishableKey,
      image: Hound.settings.iconPath,
      token: successCallback
    }).open({
      name: options.full_plan_name,
      amount: options.price_in_cents,
      email: Hound.settings.userEmailAddress,
      panelLabel: options.buttonText || "{{amount}} per month",
      allowRememberMe: false
    });
  }

  getUser() {
    return $.ajax({
      url: "/user.json",
      type: "GET",
      dataType: "json",
    });
  }

  handleSync() {
    this.getUser().then(data => {
      if (data.refreshing_repos) {
        setTimeout(this.handleSync.bind(this), 1000);
      } else {
        this.fetchReposAndOrgs();
      }
    });
  }

  onRefreshClicked(event) {
    this.setState({isSyncing: true});

    $.ajax({
      url: "/repo_syncs.json",
      type: "POST",
      dataType: "text", // to trigger success() on 201 and empty response
      success: this.handleSync.bind(this),
      error: () => {
        this.setState({isSyncing: false});
        alert("Your repos failed to sync.");
      }
    });
  }

  onPrivateClicked(event) {
    $.post("/auth/github?access=full");
  }

  onSearchInput(event) {
    this.setState({filterTerm: event.target.value});
  }

  trackRepoActivated(repo) {
    let eventName = null, price = null;

    if (repo.private) {
      eventName = "Private Repo Activated";
      price = repo.price_in_dollars;
    } else {
      eventName = "Public Repo Activated";
      price = 0.0;
    }

    window.analytics.track(eventName, {
      properties: {
        name: repo.name,
        revenue: price
      }
    });
  }

  render() {
    const { has_private_access } = this.props;

    return (
      <div>
        <RepoTools
          showPrivateButton={!has_private_access}
          onSearchInput={this.onSearchInput.bind(this)}
          onRefreshClicked={this.onRefreshClicked.bind(this)}
          onPrivateClicked={this.onPrivateClicked}
          isSyncing={this.state.isSyncing}
        />
        <ReposView
          isSyncing={this.state.isSyncing}
          organizations={this.state.organizations}
          repos={this.state.repos}
          filterTerm={this.state.filterTerm}
          onRepoClicked={this.onRepoClicked.bind(this)}
          isProcessingId={this.state.isProcessingId}
         />
      </div>
    );
  }
}
