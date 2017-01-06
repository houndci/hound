import EmptyRepoList from './components/empty_repo_list.jsx';
import NotifyTierChange from './components/notify_tier_change.jsx';
import Organization from './components/organization.jsx';
import OrganizationsList from './components/organizations_list.jsx';
import PopulatedRepoList from './components/populated_repo_list.jsx';
import Repo from './components/repo.jsx';
import RepoActivationButton from './components/repo_activation_button.jsx';
import RepoList from './components/repo_list.jsx';
import RepoTools from './components/repo_tools.jsx';
import RepoToolsOrganizations from './components/repo_tools_organizations.jsx';
import RepoToolsPrivate from './components/repo_tools_private.jsx';
import RepoToolsRefresh from './components/repo_tools_refresh.jsx';
import RepoToolsSearch from './components/repo_tools_search.jsx';
import ReposContainer from './components/repos_container.jsx';
import ReposSyncSpinner from './components/repos_sync_spinner.jsx';
import ReposView from './components/repos_view.jsx';
import TierPlan from './components/tier_plan.jsx';
import UpdateAccountCreditCard from './components/update_account_credit_card.jsx';
import UpdateAccountEmail from './components/update_account_email.jsx';
import UpdateAccountEmailMessage from './components/update_account_email_message.jsx';
import UpgradeSubscriptionLink from './components/upgrade_subscription_link.jsx';

import Ajax from './lib/ajax.jsx';

import React from 'react';
import ReactAddonsUpdate from 'react-addons-update';
import _ from 'lodash';
import $ from 'jquery';
import classNames from 'classnames';

const app = window.app = global.app = {};

app.React = window.React = global.React = React;
app.ReactAddonsUpdate = window.ReactAddonsUpdate = global.ReactAddonsUpdate = ReactAddonsUpdate;
app._ = window._ = global._ = _;
app.$ = window.$ = global.$ = $;
app.classNames = window.classNames = global.classNames = classNames;

app.Ajax = Ajax;

app.EmptyRepoList = EmptyRepoList;
app.NotifyTierChange = NotifyTierChange;
app.Organization = Organization;
app.OrganizationsList = OrganizationsList;
app.PopulatedRepoList = PopulatedRepoList;
app.Repo = Repo;
app.RepoActivationButton = RepoActivationButton;
app.RepoList = RepoList;
app.RepoTools = RepoTools;
app.RepoToolsPrivate = RepoToolsPrivate;
app.RepoToolsRefresh = RepoToolsRefresh;
app.RepoToolsSearch = RepoToolsSearch;
app.ReposContainer = ReposContainer;
app.ReposSyncSpinner = ReposSyncSpinner;
app.ReposView = ReposView;
app.TierPlan = TierPlan;
app.UpdateAccountCreditCard = UpdateAccountCreditCard;
app.UpdateAccountEmail = UpdateAccountEmail;
app.UpdateAccountEmailMessage = UpdateAccountEmailMessage;
app.UpgradeSubscriptionLink = UpgradeSubscriptionLink;
