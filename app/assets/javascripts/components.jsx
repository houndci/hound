import EmptyRepoList from './components/empty_repo_list.js';
import NotifyTierChange from './components/notify_tier_change.js';
import Organization from './components/organization.js';
import OrganizationsList from './components/organizations_list.js';
import PopulatedRepoList from './components/populated_repo_list.js';
import Repo from './components/repo.js';
import RepoActivationButton from './components/repo_activation_button.js';
import RepoList from './components/repo_list.js';
import RepoTools from './components/repo_tools.js';
import RepoToolsPrivate from './components/repo_tools_private.js';
import RepoToolsRefresh from './components/repo_tools_refresh.js';
import RepoToolsSearch from './components/repo_tools_search.js';
import ReposContainer from './components/repos_container.js';
import ReposSyncSpinner from './components/repos_sync_spinner.js';
import ReposView from './components/repos_view.js';
import TierPlan from './components/tier_plan.js';
import UpdateAccountCreditCard from './components/update_account_credit_card.js';
import UpdateAccountEmail from './components/update_account_email.js';
import UpdateAccountEmailMessage from './components/update_account_email_message.js';
import UpgradeSubscriptionLink from './components/upgrade_subscription_link.js';

import Ajax from './lib/ajax.js';

const app = window.app = global.app = {};

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

app.Ajax = Ajax;
