import AccountCreditCardUpdater from './components/account_credit_card_updater';
import AccountEmailUpdater from './components/account_email_updater';
import AccountEmailUpdaterMessage from './components/account_email_updater_message';
import EmptyRepoList from './components/empty_repo_list';
import Organization from './components/organization';
import OrganizationsList from './components/organizations_list';
import PopulatedRepoList from './components/populated_repo_list';
import Repo from './components/repo';
import RepoActivationButton from './components/repo_activation_button';
import RepoList from './components/repo_list';
import RepoTools from './components/repo_tools';
import RepoToolsPrivate from './components/repo_tools_private';
import RepoToolsRefresh from './components/repo_tools_refresh';
import RepoToolsSearch from './components/repo_tools_search';
import ReposContainer from './components/repos_container';
import ReposSyncSpinner from './components/repos_sync_spinner';
import ReposView from './components/repos_view';
import TierChangeNotifier from './components/tier_change_notifier';
import TierPlan from './components/tier_plan';

import Ajax from './lib/ajax';

// Setup a global app scope
const app = window.app = global.app = {};

// Expose components to global scope
app.AccountCreditCardUpdater = AccountCreditCardUpdater;
app.AccountEmailUpdater = AccountEmailUpdater;
app.AccountEmailUpdaterMessage = AccountEmailUpdaterMessage;
app.EmptyRepoList = EmptyRepoList;
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
app.TierChangeNotifier = TierChangeNotifier;
app.TierPlan = TierPlan;

app.Ajax = Ajax;
