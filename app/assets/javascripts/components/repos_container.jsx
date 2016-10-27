import React from 'react';
import update from 'react-addons-update';

import RepoTools from './repo_tools';
import ReposView from './repos_view';
import * as Ajax from '../lib/ajax';

import $ from 'jquery';

class ReposContainer extends React.Component {
  fetchReposAndOrgs() {
    $.ajax({
      url: "/repos.json",
      type: "GET",
      dataType: "json",
      success: data => {
        this.onFetchReposAndOrgsSuccess(data);
      },
      error: () => {
        alert("Your repos failed to load.");
      }
    });
  }

  onFetchReposAndOrgsSuccess(data) {
    if (data.length == 0) {
      this.onRefreshClicked();
    } else {
      this.setState({repos: data});

      const organizations = data.map( repo => {
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

  state = {
    isSyncing: false,
    isProcessingId: null,
    filterTerm: null,
    repos: [],
    organizations: []
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

  commitRepoToState(repo) {
    var repoIdx = _.findIndex(this.state.repos, {id: repo.id});

    const newRepos = update(
      this.state.repos, {
        [repoIdx]: {$set: repo}
      }
    );
    this.setState({repos: newRepos});
  }

  deactivateSubscribedRepo(repo) {
    Ajax.deleteSubscription(repo).then( () => {
      repo.active = false;
      repo.stripe_subscription_id = null;
      this.commitRepoToState(repo);
    }).catch( () => {
      alert("Your repo could not be disabled.");
    });
  }

  deactivateUnsubscribedRepo(repo) {
    Ajax.deactivateRepo(repo).then( () => {
      repo.active = false;
      this.commitRepoToState(repo);
    }).catch( () => {
      alert("Your repo could not be disabled.");
    });
  }

  activatePaidRepo(repo) {
    if (this.props.userHasCard) {
      this.createSubscriptionWithExistingCard(repo);
    } else {
      this.showCreditCardForm(
        repo,
        (token) => this.createSubscriptionWithNewCard(repo, token)
      );
    }
  }

  activateAndTrackRepoSubscription(repo, stripeSubscriptionId) {
    repo.active = true;
    repo.stripe_subscription_id = stripeSubscriptionId;
    this.trackRepoActivated(repo);

    this.commitRepoToState(repo);
  }

  onSubscriptionError(repo, error) {
    if (error.status === 402) {
      document.location.href = `/pricing?repo_id=${repo.id}`;
    } else {
      alert("Your subscription could not be activated.");
    }
  }

  createSubscriptionWithExistingCard(repo) {
    Ajax.createSubscription({
      repo_id: repo.id
    }).then( resp => {
      this.activateAndTrackRepoSubscription(
        repo, resp.stripe_subscription_id
      );
    }).catch( error => this.onSubscriptionError(repo, error));
  }

  createSubscriptionWithNewCard(repo, stripeToken) {
    Ajax.createSubscription({
      repo_id: repo.id,
      card_token: stripeToken.id,
      email_address: stripeToken.email
    }).then( resp => {
      this.activateAndTrackRepoSubscription(
        repo, resp.stripe_subscription_id
      );
    }).catch( error => this.onSubscriptionError(repo, error));
  }

  activateFreeRepo(repo) {
    Ajax.activateRepo(
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
    let repo = _.find(this.state.repos, {id: id});

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

  handleSync() {
    $.ajax({
      url: "/user.json",
      type: "GET",
      dataType: "json",
      success: data => {
        if (data.refreshing_repos) {
          setTimeout(() => { this.handleSync() }, 1000);
        } else {
          this.fetchReposAndOrgs();
        }
      }
    });
  }

  onRefreshClicked(event) {
    this.setState({isSyncing: true});

    $.ajax({
      url: "/repo_syncs.json",
      type: "POST",
      dataType: "text", // to trigger success() on 201 and empty response
      success: () => {
        this.handleSync();
      },
      error: () => {
        this.setState({isSyncing: false});
        alert("Your repos failed to sync.");
      }
    });
  }

  onPrivateClicked(event) {
    $.post("/auth/github?access=full");
  }

  onSearchInput(term) {
    this.setState({filterTerm: term});
  }

  trackRepoActivated(repo) {
    if (repo.private) {
      var eventName = "Private Repo Activated";
      var price = repo.price_in_dollars;
    } else {
      var eventName = "Public Repo Activated";
      var price = 0.0;
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
          onSearchInput={(event) => this.onSearchInput(event)}
          onRefreshClicked={(event) => this.onRefreshClicked(event)}
          onPrivateClicked={(event) => this.onPrivateClicked(event)}
          isSyncing={this.state.isSyncing}
        />
        <ReposView
          isSyncing={this.state.isSyncing}
          organizations={this.state.organizations}
          repos={this.state.repos}
          filterTerm={this.state.filterTerm}
          onRepoClicked={(event) => this.onRepoClicked(event)}
          isProcessingId={this.state.isProcessingId}
         />
      </div>
    );
  }
}

module.exports = ReposContainer;
