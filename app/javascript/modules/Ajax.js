import $ from 'jquery'

export function createSubscription(subscriptionOptions) {
  return $.ajax({
    url: `/repos/${subscriptionOptions.repo_id}/subscription.json`,
    type: "POST",
    data: subscriptionOptions,
    dataType: "json"
  })
}

export function deleteSubscription(repo) {
  return $.ajax({
    url: `/repos/${repo.id}/subscription`,
    type: "DELETE",
    dataType: "json"
  })
}

export function deactivateRepo(repo) {
  return $.ajax({
    url: `/repos/${repo.id}/deactivation`,
    type: "POST",
    dataType: "text"
  })
}

export function activateRepo(repo) {
  return $.ajax({
    url: `/repos/${repo.id}/activation`,
    type: "POST",
    dataType: "text"
  })
}

export function updateOwner(id, params) {
  $.ajax({
    url: `/owners/${id}`,
    type: "PUT",
    dataType: "json",
    data: { owner: params }
  })
}

export function upgradeSubscription(id, params) {
  return $.ajax({
    url: `/repos/${id}/subscription.json`,
    type: "PUT",
    dataType: "json",
    data: params,
    success: () => {
      document.location.href = "/repos"
    }
  })
}

