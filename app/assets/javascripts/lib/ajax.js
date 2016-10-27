import $ from 'jquery';

export function createSubscription(options) {
  return $.ajax({
    url: `/repos/${options.repo_id}/subscription.json`,
    type: "POST",
    data: options,
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

