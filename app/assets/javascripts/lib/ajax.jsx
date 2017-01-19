import $ from 'jquery';

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

export function upgradeSubscription(id) {
  return $.ajax({
    dataType: "json",
    type: "PUT",
    url: `/repos/${id}/subscription.json`,
    success: () => {
      document.location.href = "/repos";
    }
  });
}

