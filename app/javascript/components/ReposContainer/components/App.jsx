import React from 'react';
import ReactAddonsUpdate from 'react-addons-update';
import _ from 'lodash';
import $ from 'jquery';

import RepoAllowance from './RepoAllowance';
import RepoTools from './RepoTools';
import ReposView from './ReposView';

import * as Ajax from '../../../modules/Ajax';
import { getCSRFfromHead } from '../../../modules/Utils';

export default class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isSyncing: false,
      isProcessingId: null,
      filterTerm: null,
      repos: [],
      organizations: [],
    };
  }

  componentDidMount() {
    $.ajaxSetup({
      headers: {
        "X-XSRF-Token": getCSRFfromHead()
      }
    });
    this.setState({isSyncing: true});
    this.fetchRepos({ syncOnEmpty: true });
  }

  fetchRepos({ syncOnEmpty }) {
    $.ajax({
      url: "/repos.json",
      type: "GET",
      dataType: "json",
      success: (data) => this.onFetchReposSuccess(data, syncOnEmpty),
      error: () => alert("Your repos failed to load.")
    });
  }

  onFetchReposSuccess(data, syncOnEmpty) {
    if (syncOnEmpty && data.length === 0) {
      this.onRefreshClicked();
    } else {
      const organizations = data.map(repo => (
        repo.owner || { name: this.orgName(repo.name) }
      ));

      this.setState({
        isSyncing: false,
        organizations: _.uniqWith(organizations, _.isEqual),
        repos: data,
      });
    }
  }

  orgName(name) {
    return _.split(name, "/")[0];
  }

  commitRepoToState(repo) {
    const repoIdx = _.findIndex(this.state.repos, {id: repo.id});

    const newRepos = ReactAddonsUpdate(
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
      this.updateSubscribedRepoCount();
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

  updateSubscribedRepoCount() {
    this.getUser().then(user => {
      const subscribedRepoCount = user.subscribed_repo_count;
      const tierAllowance = user.plan_max;

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
      document.location.href = `/plans?repo_id=${repo.id}`;
    } else {
      if (window.Intercom) {
        window.Intercom(
          "showNewMessage",
          "I cannot activate my repo. Please help!"
        );
      } else {
        alert("Oh no, activating a repo failed. Please contact us!");
      }
    }
  }

  createSubscriptionWithExistingCard(repo) {
    Ajax.createSubscription({
      repo_id: repo.id
    }).then( resp => {
      this.activateAndTrackRepoSubscription(
        repo, resp.stripe_subscription_id
      );
    }).catch(error => this.onSubscriptionError(repo, error));
  }

  activateFreeRepo(repo) {
    Ajax.activateRepo(
      repo
    ).then( resp => {
      repo.active = true;
      this.trackRepoActivated(repo);
      this.commitRepoToState(repo);
    }).catch( () => {
      if (window.Intercom) {
        window.Intercom(
          "showNewMessage",
          "I cannot activate my repo. Please help!"
        );
      } else {
        alert("Oh no, activating a repo failed. Please contact us!");
      }
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
      if (repo.price_in_cents > 0) {
        this.createSubscriptionWithExistingCard(repo);
      } else {
        this.activateFreeRepo(repo);
      }
    }

    this.setState({isProcessingId: null});
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
        setTimeout(() => this.handleSync(), 1000);
      } else {
        this.fetchRepos({ syncOnEmpty: false });
      }
    });
  }

  onRefreshClicked(event) {
    this.setState({isSyncing: true});

    $.ajax({
      url: "/repo_syncs.json",
      type: "POST",
      dataType: "text", // to trigger success() on 201 and empty response
      success: () => this.handleSync(),
      error: () => {
        this.setState({isSyncing: false});
        alert("Your repos failed to sync.");
      }
    });
  }

  onSearchInput(event) {
    this.setState({filterTerm: event.target.value});
  }

  trackRepoActivated(repo) {
    let eventName = null, price = null;

    if (repo.private) {
      eventName = "Private Repo Activated";
      price = repo.price_in_cents / 100;
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
    return (
      <div>
        <RepoTools
          appName={this.props.appName}
          hasRepos={!_.isEmpty(this.state.repos)}
          isSyncing={this.state.isSyncing}
          onRefreshClicked={(event) => this.onRefreshClicked(event)}
          onSearchInput={(event) => this.onSearchInput(event)}
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
