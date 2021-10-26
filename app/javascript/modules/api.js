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

const activateRepo = (repo) => {
  return fetch(
    `/repos/${repo.id}/activation`,
    { method: 'POST', headers: getJsonHeaders() },
  );
}

const deactivateRepo = (repo) => {
  return fetch(`/repos/${repo.id}/deactivation`, {
    method: 'POST',
    headers: getJsonHeaders(),
  });
}

const updateOwner = (id, params) => {
  return fetch(`/owners/${id}`, {
    method: 'PUT',
    headers: getJsonHeaders(),
    body: JSON.stringify({ owner: params }),
  });
};

const createSubscription = (repoId) => {
  return fetch(`/repos/${repoId}/subscription`, {
    method: 'POST',
    headers: getJsonHeaders(),
  });
}

const deleteSubscription = (repo) => {
  return fetch(`/repos/${repo.id}/subscription`, {
    method: 'DELETE',
    headers: getJsonHeaders(),
  });
}

const updateCustomerCreditCard = (stripeToken) => {
  return fetch('/credit_card', {
    method: 'PUT',
    headers: getJsonHeaders(),
    body: JSON.stringify({ card_token: stripeToken }),
  });
}

const updateCustomerEmail = (email) => {
  return fetch('/account', {
    method: 'PUT',
    headers: getJsonHeaders(),
    body: JSON.stringify({ billable_email: email }),
  });
};

const upgradeSubscription = (id, params) => {
  return fetch(`/repos/${id}/subscription`, {
    method: 'PUT',
    headers: getJsonHeaders(),
    body: JSON.stringify(params),
  });
}

export {
  fetchRepos,
  fetchUser,
  createSync,
  createSubscription,
  deleteSubscription,
  updateOwner,
  activateRepo,
  deactivateRepo,
  updateCustomerCreditCard,
  updateCustomerEmail,
  upgradeSubscription,
};
