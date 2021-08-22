const getCSRFfromHead = () => {
  if (process.env.NODE_ENV === 'test') {
    return 'csrf_token';
  } else {
    return document.querySelector('meta[name=csrf-token]').content;
  }
};

const getJsonHeaders = () => ({
  'Content-Type': 'application/json',
  'X-XSRF-Token': getCSRFfromHead(),
});

const fetchRepos = () => {
  return fetch('/repos.json').then((resp) => resp.json());
};

const fetchUser = () => {
  return fetch('/user.json').then((resp) => resp.json());
};

const createSync = () => {
  return fetch('/repo_syncs', { method: 'POST', headers: getJsonHeaders() });
};

const updateOwner = (id, params) => {
  return fetch(`/owners/${id}`, {
    method: 'PUT',
    headers: getJsonHeaders(),
    body: JSON.stringify({ owner: params }),
  });
};

export function createSubscription(subscriptionOptions) {
  return $.ajax({
    url: `/repos/${subscriptionOptions.repo_id}/subscription.json`,
    type: "POST",
    data: subscriptionOptions,
    dataType: "json"
  });
}

export function deleteSubscription(repo) {
  return $.ajax({
    url: `/repos/${repo.id}/subscription`,
    type: "DELETE",
    dataType: "json"
  });
}

export function deactivateRepo(repo) {
  return $.ajax({
    url: `/repos/${repo.id}/deactivation`,
    type: "POST",
    dataType: "text"
  });
}

export function activateRepo(repo) {
  return $.ajax({
    url: `/repos/${repo.id}/activation`,
    type: "POST",
    dataType: "text"
  });
}

export function upgradeSubscription(id, params) {
  return $.ajax({
    url: `/repos/${id}/subscription.json`,
    type: "PUT",
    dataType: "json",
    data: params,
    success: () => {
      document.location.href = "/repos";
    }
  });
}

export { fetchRepos, fetchUser, createSync, updateOwner };
